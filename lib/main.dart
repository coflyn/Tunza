import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

bool isBackgroundInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.tunza.music.channel.audio.v3',
      androidNotificationChannelName: 'Tunza Music Playback',
      androidNotificationOngoing: true,
    );
    isBackgroundInitialized = true;
  } catch (e, stackTrace) {
    debugPrint('JustAudioBackground init error: $e');
    debugPrint('StackTrace: $stackTrace');
    Fluttertoast.showToast(
      msg: "Audio BG Error: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
    );
    isBackgroundInitialized = true;
  }

  runApp(const TunzaApp());
}

class TunzaApp extends StatelessWidget {
  const TunzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tunza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DB954),
          secondary: Color(0xFF1DB954),
          surface: Color(0xFF121212),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final List<String> lyrics;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.lyrics,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _lyricsScrollController = ScrollController();

  List<Track> _allTracks = [];
  List<Track> _filteredTracks = [];
  bool _isLoading = true;
  bool _isPlayerOpen = false;
  bool _showLyrics = false;

  List<Track> _playbackQueue = [];
  List<int> _shuffledIndices = [];
  Track? _playingTrack;
  int _currentIndex = 0;

  final Set<String> _favoriteTrackIds = {};
  String _searchQuery = '';
  String _selectedFilter = 'Songs';
  String? _selectedArtistDetail;
  String? _selectedAlbumDetail;
  String? _selectedPlaylistDetail;

  late PageController _pageController;
  int _currentPageIndex = 0;

  List<String> _lastPlayedTrackIds = [];
  Map<String, int> _playCounts = {};
  final TextEditingController _searchController = TextEditingController();

  bool _isPlaying = false;
  bool _isShuffle = false;
  int _repeatMode = 0;
  double _volume = 0.8;
  ProcessingState _processingState = ProcessingState.idle;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _requestPermissionAndScan();
    _setupAudioStreams();
  }

  void _setupAudioStreams() {
    AudioSession.instance.then((session) async {
      await session.configure(const AudioSessionConfiguration.music());
    });

    _audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (mounted) setState(() => _processingState = state);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_repeatMode == 2) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_repeatMode == 1) {
          _playNext();
        } else {
          _audioPlayer.pause();
          _audioPlayer.seek(Duration.zero);
        }
      }
    });
  }

  Future<void> _requestPermissionAndScan() async {
    setState(() => _isLoading = true);
    try {
      bool permissionGranted = await _audioQuery.permissionsStatus();
      if (!permissionGranted) {
        permissionGranted = await _audioQuery.permissionsRequest();
      }

      await Permission.notification.request();

      if (permissionGranted) {
        final List<SongModel> songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        if (songs.isNotEmpty) {
          _allTracks = songs.map((song) {
            String safeUri = (song.uri != null && song.uri!.isNotEmpty)
                ? song.uri!
                : 'content://media/external/audio/media/${song.id}';

            return Track(
              id: song.id.toString(),
              title: song.title,
              artist: song.artist ?? 'Unknown Artist',
              album: song.album ?? 'Unknown Album',
              url: safeUri,
              lyrics: [
                "Playing '${song.title}'...",
                "Brought to you by Tunza Music,",
                "Your premium local audio choice.",
                "Feel the deep rhythm in your soul.",
                "Let the notes carry you away,",
                "Into the beautiful flow of the day.",
                "Pure high fidelity local sound.",
              ],
            );
          }).toList();
        }
      }
    } catch (e) {
      _allTracks = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (_allTracks.isNotEmpty) {
          _playbackQueue = List.from(_allTracks);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? lastTrackId = prefs.getString('last_playing_track_id');
          List<String>? favs = prefs.getStringList('favorite_track_ids');
          List<String>? lastPlayed = prefs.getStringList(
            'last_played_track_ids',
          );
          String? playCountsStr = prefs.getString('play_counts');

          if (favs != null) {
            _favoriteTrackIds.clear();
            _favoriteTrackIds.addAll(favs);
          }
          if (lastPlayed != null) _lastPlayedTrackIds = lastPlayed;
          if (playCountsStr != null) {
            try {
              Map<String, dynamic> decoded = jsonDecode(playCountsStr);
              _playCounts = decoded.map((k, v) => MapEntry(k, v as int));
            } catch (e) {
              _playCounts = {};
            }
          }

          int startIndex = 0;
          if (lastTrackId != null) {
            final index = _allTracks.indexWhere((t) => t.id == lastTrackId);
            if (index != -1) startIndex = index;
          }

          _playingTrack = _allTracks[startIndex];
          _playTrack(startIndex, playImmediately: false);
        }
      }
    }
  }

  void _filterSongs() {
    setState(() {});
  }

  Future<void> _playTrack(
    int index, {
    bool playImmediately = true,
    List<Track>? sourceList,
  }) async {
    final listToPlay = sourceList ?? _playbackQueue;
    if (listToPlay.isEmpty || index < 0 || index >= listToPlay.length) return;

    bool queueMatches = _playbackQueue.length == listToPlay.length;
    if (queueMatches && sourceList != null) {
      for (int i = 0; i < _playbackQueue.length; i++) {
        if (_playbackQueue[i].id != listToPlay[i].id) {
          queueMatches = false;
          break;
        }
      }
    }

    if (!queueMatches && sourceList != null) {
      setState(() {
        _playbackQueue = List.from(listToPlay);
        if (_isShuffle) {
          _shuffledIndices = List.generate(_playbackQueue.length, (i) => i);
          _shuffledIndices.shuffle();
        }
      });
    }

    final track = _playbackQueue[index];

    setState(() {
      _currentIndex = index;
      _playingTrack = track;
      if (_isShuffle && !queueMatches && sourceList != null) {
        _shuffledIndices.remove(_currentIndex);
        _shuffledIndices.insert(0, _currentIndex);
      }

      _lastPlayedTrackIds.remove(track.id);
      _lastPlayedTrackIds.insert(0, track.id);
      if (_lastPlayedTrackIds.length > 100) _lastPlayedTrackIds.removeLast();
      _playCounts[track.id] = (_playCounts[track.id] ?? 0) + 1;
    });

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_playing_track_id', track.id);
      prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      prefs.setString('play_counts', jsonEncode(_playCounts));
    });

    try {
      final parsedUri = track.url.startsWith('/')
          ? Uri.file(track.url)
          : (Uri.tryParse(track.url) ?? Uri.parse(''));

      final source = AudioSource.uri(
        parsedUri,
        tag: MediaItem(
          id: track.id,
          album: track.album,
          title: track.title,
          artist: track.artist,
        ),
      );

      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.setVolume(_volume);

      if (playImmediately) {
        _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing song: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _processingState = ProcessingState.idle;
      });
    }
  }

  void _playNext() {
    if (_playbackQueue.isEmpty) return;

    int nextIndex;
    if (_isShuffle && _shuffledIndices.isNotEmpty) {
      int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffledPos + 1 < _shuffledIndices.length) {
        nextIndex = _shuffledIndices[currentShuffledPos + 1];
      } else {
        if (_repeatMode == 1) {
          nextIndex = _shuffledIndices[0];
        } else {
          return;
        }
      }
    } else {
      nextIndex = _currentIndex + 1;
      if (nextIndex >= _playbackQueue.length) {
        if (_repeatMode == 1) {
          nextIndex = 0;
        } else {
          return;
        }
      }
    }
    _playTrack(nextIndex);
  }

  void _playPrevious() {
    if (_playbackQueue.isEmpty) return;

    if (_audioPlayer.position.inSeconds > 3) {
      _audioPlayer.seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (_isShuffle && _shuffledIndices.isNotEmpty) {
      int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffledPos - 1 >= 0) {
        prevIndex = _shuffledIndices[currentShuffledPos - 1];
      } else {
        if (_repeatMode == 1) {
          prevIndex = _shuffledIndices.last;
        } else {
          prevIndex = _shuffledIndices.first;
        }
      }
    } else {
      prevIndex = _currentIndex - 1;
      if (prevIndex < 0) {
        if (_repeatMode == 1) {
          prevIndex = _playbackQueue.length - 1;
        } else {
          prevIndex = 0;
        }
      }
    }
    _playTrack(prevIndex);
  }

  void _toggleFavorite(String trackId) {
    setState(() {
      if (_favoriteTrackIds.contains(trackId)) {
        _favoriteTrackIds.remove(trackId);
      } else {
        _favoriteTrackIds.add(trackId);
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('favorite_track_ids', _favoriteTrackIds.toList());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _lyricsScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildFilterCapsules(),
                      Expanded(child: _buildBodyContent()),
                      if (_playingTrack != null) const SizedBox(height: 72),
                    ],
                  ),
          ),

          if (_playingTrack != null) _buildMiniPlayer(_playingTrack!),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuint,
            top: _isPlayerOpen ? 0 : MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: _playingTrack != null
                ? _buildFullScreenPlayer(_playingTrack!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final showBackButton =
        (_currentPageIndex == 1 && _selectedPlaylistDetail != null) ||
        (_currentPageIndex == 2 && _selectedArtistDetail != null) ||
        (_currentPageIndex == 3 && _selectedAlbumDetail != null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentPageIndex == 0
                  ? 'Library'
                  : _currentPageIndex == 1
                  ? (_selectedPlaylistDetail ?? 'Playlists')
                  : _currentPageIndex == 2
                  ? (_selectedArtistDetail ?? 'Artists')
                  : (_selectedAlbumDetail ?? 'Albums'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: Colors.white,
              ),
            ),
            if (showBackButton)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white54,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _selectedPlaylistDetail = null;
                    _selectedArtistDetail = null;
                    _selectedAlbumDetail = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (val) {
          _searchQuery = val;
          _filterSongs();
        },
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, or albums...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterSongs();
                  },
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildFilterCapsules() {
    final filters = ['Songs', 'Playlists', 'Artists', 'Albums'];
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: SizedBox(
        height: 32,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _currentPageIndex == index;
            return GestureDetector(
              onTap: () {
                _pageController.jumpToPage(index);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_allTracks.isEmpty) {
      return _buildEmptyState();
    }

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: [
        _buildSongsTab(),
        _buildPlaylistsTab(),
        _buildArtistsTab(),
        _buildAlbumsTab(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
              child: Icon(
                Icons.music_note_outlined,
                size: 40,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Local Songs Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Copy some audio files to your device storage and refresh the page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.15)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: _requestPermissionAndScan,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text(
                'Refresh Library',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsTab() {
    List<Track> songs = List<Track>.from(_allTracks);
    if (_searchQuery.isNotEmpty) {
      songs = songs
          .where(
            (t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.album.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return _buildSongList(songs);
  }

  Widget _buildPlaylistsTab() {
    if (_selectedPlaylistDetail != null) {
      List<Track> playlistSongs = [];
      if (_selectedPlaylistDetail == 'Favourites') {
        playlistSongs = _allTracks
            .where((t) => _favoriteTrackIds.contains(t.id))
            .toList();
      } else if (_selectedPlaylistDetail == 'Recently Added') {
        playlistSongs = List.from(_allTracks);
      } else if (_selectedPlaylistDetail == 'Last Played') {
        playlistSongs = _lastPlayedTrackIds
            .map(
              (id) => _allTracks.firstWhere(
                (t) => t.id == id,
                orElse: () => _allTracks[0],
              ),
            )
            .where((t) => _lastPlayedTrackIds.contains(t.id))
            .toList();
      } else if (_selectedPlaylistDetail == 'Most Played') {
        playlistSongs = List.from(_allTracks);
        playlistSongs.sort(
          (a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
        );
        playlistSongs = playlistSongs
            .where((t) => (_playCounts[t.id] ?? 0) > 0)
            .toList();
      }

      if (_searchQuery.isNotEmpty) {
        playlistSongs = playlistSongs
            .where(
              (t) =>
                  t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.artist.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      return _buildSongList(playlistSongs);
    }

    final favorites = _allTracks
        .where((t) => _favoriteTrackIds.contains(t.id))
        .toList();
    final recentlyAdded = List<Track>.from(_allTracks);
    final lastPlayed = _lastPlayedTrackIds
        .map(
          (id) => _allTracks.firstWhere(
            (t) => t.id == id,
            orElse: () => _allTracks[0],
          ),
        )
        .where((t) => _lastPlayedTrackIds.contains(t.id))
        .toList();
    var mostPlayed = List<Track>.from(_allTracks);
    mostPlayed.sort(
      (a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
    );
    mostPlayed = mostPlayed.where((t) => (_playCounts[t.id] ?? 0) > 0).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildPlaylistCard(
          'Favourites',
          favorites,
          const Color(0xFFE91E63),
          Icons.favorite,
        ),
        _buildPlaylistCard(
          'Recently Added',
          recentlyAdded,
          const Color(0xFF2196F3),
          Icons.new_releases,
        ),
        _buildPlaylistCard(
          'Last Played',
          lastPlayed,
          const Color(0xFFFF9800),
          Icons.history,
        ),
        _buildPlaylistCard(
          'Most Played',
          mostPlayed,
          const Color(0xFFF44336),
          Icons.local_fire_department,
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(
    String title,
    List<Track> songs,
    Color color,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      onTap: () {
        setState(() {
          _selectedPlaylistDetail = title;
        });
      },
      leading: _buildStackedArtwork(songs, color, icon, title == 'Favourites'),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        '${songs.length} songs',
        style: const TextStyle(fontSize: 13, color: Colors.white54),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white24, size: 20),
    );
  }

  Widget _buildStackedArtwork(
    List<Track> tracks,
    Color color,
    IconData fallbackIcon,
    bool isFavorites,
  ) {
    final displayTracks = tracks.take(3).toList();

    if (displayTracks.isEmpty && !isFavorites) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(fallbackIcon, color: color, size: 24),
      );
    }

    Widget topmostWidget;
    if (isFavorites) {
      topmostWidget = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFE91E63), Color(0xFF9C27B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 28),
      );
    } else {
      topmostWidget = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
          color: color.withOpacity(0.1),
        ),
        child: ClipOval(
          child: QueryArtworkWidget(
            id: int.tryParse(displayTracks.first.id) ?? 0,
            type: ArtworkType.AUDIO,
            keepOldArtwork: true,
            artworkWidth: 56,
            artworkHeight: 56,
            artworkFit: BoxFit.cover,
            nullArtworkWidget: Icon(fallbackIcon, color: color, size: 24),
          ),
        ),
      );
    }

    int totalItems = displayTracks.length;
    if (isFavorites) {
      totalItems = min(3, displayTracks.length + 1);
    }

    return SizedBox(
      width: 56 + (totalItems - 1) * 16.0,
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: List.generate(totalItems, (index) {
          final reversedIndex = totalItems - 1 - index;

          if (reversedIndex == 0) {
            return Positioned(left: 0, child: topmostWidget);
          }

          final track =
              displayTracks[isFavorites ? reversedIndex - 1 : reversedIndex];

          return Positioned(
            left: reversedIndex * 16.0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                color: const Color(0xFF161616),
              ),
              child: ClipOval(
                child: QueryArtworkWidget(
                  id: int.tryParse(track.id) ?? 0,
                  type: ArtworkType.AUDIO,
                  keepOldArtwork: true,
                  artworkWidth: 56,
                  artworkHeight: 56,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildArtistsTab() {
    if (_selectedArtistDetail != null) {
      List<Track> artistSongs = _allTracks
          .where((t) => t.artist == _selectedArtistDetail)
          .toList();
      if (_searchQuery.isNotEmpty) {
        artistSongs = artistSongs
            .where(
              (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }
      return _buildSongList(artistSongs);
    }

    final artists = _allTracks.map((t) => t.artist).toSet().toList();
    if (_searchQuery.isNotEmpty) {
      artists.retainWhere(
        (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        final songCount = _allTracks.where((t) => t.artist == artist).length;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedArtistDetail = artist;
            });
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF161616),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white38),
          ),
          title: Text(
            artist,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '$songCount songs',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
            size: 14,
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    if (_selectedAlbumDetail != null) {
      List<Track> albumSongs = _allTracks
          .where((t) => t.album == _selectedAlbumDetail)
          .toList();
      if (_searchQuery.isNotEmpty) {
        albumSongs = albumSongs
            .where(
              (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }
      return _buildSongList(albumSongs);
    }

    final albums = _allTracks.map((t) => t.album).toSet().toList();
    if (_searchQuery.isNotEmpty) {
      albums.retainWhere(
        (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final songCount = _allTracks.where((t) => t.album == album).length;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedAlbumDetail = album;
            });
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.album, color: Colors.white38),
          ),
          title: Text(
            album,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '$songCount songs',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
            size: 14,
          ),
        );
      },
    );
  }

  Widget _buildSongList(List<Track> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No matching songs found',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final track = list[index];
        final isSelected =
            _playingTrack != null && track.id == _playingTrack!.id;
        final isFavorited = _favoriteTrackIds.contains(track.id);

        return Container(
          key: ValueKey("list_item_${track.id}"),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.03)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            onTap: () => _playTrack(index, sourceList: list),
            leading: ClipRRect(
              key: ValueKey("artwork_clip_${track.id}"),
              borderRadius: BorderRadius.circular(6),
              child: QueryArtworkWidget(
                key: ValueKey("artwork_${track.id}"),
                id: int.tryParse(track.id) ?? 0,
                type: ArtworkType.AUDIO,
                keepOldArtwork: true,
                artworkWidth: 44,
                artworkHeight: 44,
                artworkBorder: BorderRadius.circular(0),
                artworkFit: BoxFit.cover,
                nullArtworkWidget: Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFF161616),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white24,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? const Color(0xFF1DB954) : Colors.white,
              ),
            ),
            subtitle: Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  MiniMusicVisualizer(
                    color: const Color(0xFF1DB954),
                    width: 4,
                    height: 14,
                    radius: 2,
                    animate: _isPlaying,
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited
                        ? const Color(0xFF1DB954)
                        : Colors.white24,
                    size: 18,
                  ),
                  onPressed: () => _toggleFavorite(track.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer(Track currentTrack) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => setState(() => _isPlayerOpen = true),
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: QueryArtworkWidget(
                  key: ValueKey("mini_art_${currentTrack.id}"),
                  id: int.tryParse(currentTrack.id) ?? 0,
                  type: ArtworkType.AUDIO,
                  keepOldArtwork: true,
                  artworkWidth: 44,
                  artworkHeight: 44,
                  artworkBorder: BorderRadius.circular(0),
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    width: 44,
                    height: 44,
                    color: const Color(0xFF222222),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTrack.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _processingState == ProcessingState.loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (_isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                      },
                    ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _playNext(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueueBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<int> effectiveIndices;
        if (_isShuffle && _shuffledIndices.length == _playbackQueue.length) {
          int pos = _shuffledIndices.indexOf(_currentIndex);
          if (pos != -1) {
            effectiveIndices = _shuffledIndices.sublist(pos);
          } else {
            effectiveIndices = _shuffledIndices;
          }
        } else {
          effectiveIndices = List.generate(
            _playbackQueue.length - _currentIndex,
            (i) => _currentIndex + i,
          );
        }

        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Up Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (_isShuffle)
                    const Icon(
                      Icons.shuffle,
                      color: Color(0xFF1DB954),
                      size: 18,
                    ),
                  if (_isShuffle) const SizedBox(width: 8),
                  if (_repeatMode != 0)
                    Icon(
                      _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                      color: const Color(0xFF1DB954),
                      size: 18,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: effectiveIndices.length,
                itemBuilder: (context, idx) {
                  final realIndex = effectiveIndices[idx];
                  final track = _playbackQueue[realIndex];
                  final isCurrent = realIndex == _currentIndex;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: QueryArtworkWidget(
                        id: int.tryParse(track.id) ?? 0,
                        type: ArtworkType.AUDIO,
                        keepOldArtwork: true,
                        artworkWidth: 40,
                        artworkHeight: 40,
                        artworkBorder: BorderRadius.circular(0),
                        nullArtworkWidget: Container(
                          width: 40,
                          height: 40,
                          color: const Color(0xFF161616),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    trailing: isCurrent
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: MiniMusicVisualizer(
                                color: const Color(0xFF1DB954),
                                width: 4,
                                height: 14,
                                radius: 2,
                                animate: _isPlaying,
                              ),
                            ),
                          )
                        : null,
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFF1DB954)
                            : Colors.white,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _playTrack(realIndex);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFullScreenPlayer(Track currentTrack) {
    final isFavorited = _favoriteTrackIds.contains(currentTrack.id);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            setState(() {
              _isPlayerOpen = false;
              _showLyrics = false;
            });
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E1E1E), Color(0xFF0A0A0A)],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                            size: 28,
                          ),
                          onPressed: () =>
                              setState(() => _isPlayerOpen = false),
                        ),
                        const Text(
                          'Now Playing',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white38,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),

                    Center(
                      child: AnimatedScale(
                        scale: _isPlaying ? 1.0 : 0.92,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: QueryArtworkWidget(
                                key: ValueKey("full_art_${currentTrack.id}"),
                                id: int.tryParse(currentTrack.id) ?? 0,
                                type: ArtworkType.AUDIO,
                                keepOldArtwork: true,
                                artworkWidth: 400,
                                artworkHeight: 400,
                                artworkBorder: BorderRadius.circular(0),
                                size: 1000,
                                artworkFit: BoxFit.cover,
                                nullArtworkWidget: Container(
                                  color: const Color(0xFF161616),
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white10,
                                    size: 64,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTrack.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 22,
                          ),
                          onPressed: () => _toggleFavorite(currentTrack.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final duration = _audioPlayer.duration ?? Duration.zero;
                        final currentPosition = snapshot.data ?? Duration.zero;

                        return StatefulBuilder(
                          builder: (context, setLocalState) {
                            final displayValue =
                                _dragValue ??
                                (duration.inMilliseconds > 0
                                    ? (currentPosition.inMilliseconds /
                                              duration.inMilliseconds)
                                          .clamp(0.0, 1.0)
                                    : 0.0);

                            final displayPosition = Duration(
                              milliseconds:
                                  (displayValue * duration.inMilliseconds)
                                      .toInt(),
                            );

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.5,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 3,
                                    ),
                                    activeTrackColor: Colors.white70,
                                    inactiveTrackColor: Colors.white
                                        .withOpacity(0.1),
                                    overlayColor: Colors.transparent,
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: displayValue,
                                    onChangeStart: (val) {
                                      setLocalState(() {
                                        _dragValue = val;
                                      });
                                    },
                                    onChanged: (val) {
                                      setLocalState(() {
                                        _dragValue = val;
                                      });
                                    },
                                    onChangeEnd: (val) {
                                      final newPosition = Duration(
                                        milliseconds:
                                            (val * duration.inMilliseconds)
                                                .toInt(),
                                      );
                                      _audioPlayer.seek(newPosition);
                                      _dragValue = null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(displayPosition),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '-${_formatDuration(duration - displayPosition)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.fast_rewind,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _playPrevious();
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_processingState == ProcessingState.loading)
                              return;
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _processingState == ProcessingState.loading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _playNext();
                          },
                        ),
                      ],
                    ),
                    const Spacer(),

                    Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          color: Colors.white.withOpacity(0.3),
                          size: 16,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              activeTrackColor: Colors.white60,
                              inactiveTrackColor: Colors.white.withOpacity(
                                0.08,
                              ),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _volume,
                              onChanged: (val) {
                                setState(() {
                                  _volume = val;
                                });
                                _audioPlayer.setVolume(val);
                              },
                            ),
                          ),
                        ),
                        Icon(
                          Icons.volume_up,
                          color: Colors.white.withOpacity(0.3),
                          size: 16,
                        ),
                      ],
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.lyrics_outlined,
                            color: _showLyrics
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showLyrics = !_showLyrics;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffle
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isShuffle = !_isShuffle;
                              if (_isShuffle) {
                                _shuffledIndices = List.generate(
                                  _playbackQueue.length,
                                  (i) => i,
                                );
                                _shuffledIndices.shuffle();
                                _shuffledIndices.remove(_currentIndex);
                                _shuffledIndices.insert(0, _currentIndex);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                            color: _repeatMode != 0
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _repeatMode = (_repeatMode + 1) % 3;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.playlist_play,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onPressed: () => _showQueueBottomSheet(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            if (_showLyrics) _buildLyricsOverlay(currentTrack),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsOverlay(Track currentTrack) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      bottom: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lyrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showLyrics = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _audioPlayer.duration ?? Duration.zero;
                      final ratio = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;
                      final highlightedIndex =
                          (ratio * currentTrack.lyrics.length).floor();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_lyricsScrollController.hasClients) {
                          final targetOffset = highlightedIndex * 42.0;
                          _lyricsScrollController.animateTo(
                            targetOffset.clamp(
                              0.0,
                              _lyricsScrollController.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: _lyricsScrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentTrack.lyrics.length,
                        itemBuilder: (context, index) {
                          final lyric = currentTrack.lyrics[index];
                          final isHighlighted = index == highlightedIndex;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              lyric,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isHighlighted
                                    ? const Color(0xFF1DB954)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
