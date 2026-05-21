import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:io';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';

bool isBackgroundInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.tunza.music.channel.audio.v3',
      androidNotificationChannelName: 'Tunza Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'drawable/ic_notification',
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
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
  final String path;
  final List<String> lyrics;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.path,
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
  Map<String, List<String>> _userPlaylists = {};
  Map<String, String> _playlistCovers = {};
  Map<String, Map<String, String>> _metadataOverrides = {};
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isPlaying = false;
  bool _isShuffle = false;
  int _repeatMode = 1;
  double _volume = 0.8;
  ProcessingState _processingState = ProcessingState.idle;
  double? _dragValue;
  Color? _dominantColor;
  int _fadeSessionId = 0;
  double _playerDragOffset = 0.0;
  bool _isDraggingPlayer = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _requestPermissionAndScan();
    _setupAudioStreams();
  }

  void _setupAudioStreams() {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastTrackId = prefs.getString('last_playing_track_id');
      List<String>? favs = prefs.getStringList('favorite_track_ids');
      List<String>? lastPlayed = prefs.getStringList('last_played_track_ids');
      String? playCountsStr = prefs.getString('play_counts');
      String? userPlaylistsStr = prefs.getString('user_playlists');
      String? playlistCoversStr = prefs.getString('playlist_covers');
      String? metadataStr = prefs.getString('metadata_overrides');

      if (favs != null) {
        _favoriteTrackIds.clear();
        _favoriteTrackIds.addAll(favs);
      }
      if (lastPlayed != null) _lastPlayedTrackIds = lastPlayed;
      if (playCountsStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(playCountsStr);
          _playCounts = decoded.map((k, v) => MapEntry(k, v as int));
        } catch (_) {}
      }
      if (userPlaylistsStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(userPlaylistsStr);
          _userPlaylists = decoded.map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          );
        } catch (_) {}
      }
      if (playlistCoversStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(playlistCoversStr);
          _playlistCovers = decoded.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {}
      }
      if (metadataStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(metadataStr);
          _metadataOverrides = decoded.map(
            (k, v) => MapEntry(k, Map<String, String>.from(v)),
          );
        } catch (_) {}
      }

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

            String title = song.title;
            String artist = song.artist ?? 'Unknown Artist';
            String album = song.album ?? 'Unknown Album';

            if (_metadataOverrides.containsKey(song.id.toString())) {
              final overrides = _metadataOverrides[song.id.toString()]!;
              title = overrides['title'] ?? title;
              artist = overrides['artist'] ?? artist;
              album = overrides['album'] ?? album;
            }

            return Track(
              id: song.id.toString(),
              title: title,
              artist: artist,
              album: album,
              url: safeUri,
              path: song.data,
              lyrics: [
                "Playing '$title'...",
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

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (_allTracks.isNotEmpty) {
          _playbackQueue = List.from(_allTracks);

          int startIndex = 0;
          if (lastTrackId != null) {
            final index = _allTracks.indexWhere((t) => t.id == lastTrackId);
            if (index != -1) startIndex = index;
          }

          _playingTrack = _allTracks[startIndex];
          _playTrack(startIndex, playImmediately: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _allTracks = [];
    }
  }

  void _filterSongs() {
    setState(() {});
  }

  Future<void> _updateDominantColor(Track track) async {
    try {
      final customPath = _metadataOverrides[track.id]?['coverPath'];
      ImageProvider? imageProvider;

      if (customPath != null) {
        imageProvider = FileImage(File(customPath));
      } else {
        final artwork = await _audioQuery.queryArtwork(
          int.parse(track.id),
          ArtworkType.AUDIO,
          size: 200,
        );
        if (artwork != null) {
          imageProvider = MemoryImage(artwork);
        }
      }

      if (imageProvider != null) {
        final palette = await PaletteGenerator.fromImageProvider(imageProvider);
        if (mounted) {
          setState(() {
            _dominantColor =
                palette.dominantColor?.color ??
                palette.vibrantColor?.color ??
                palette.mutedColor?.color;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dominantColor = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = null;
        });
      }
    }
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

    _updateDominantColor(track);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_playing_track_id', track.id);
      prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      prefs.setString('play_counts', jsonEncode(_playCounts));
    });

    try {
      final parsedUri = track.url.startsWith('/')
          ? Uri.file(track.url)
          : (Uri.tryParse(track.url) ?? Uri.parse(''));

      Uri? coverUri;
      if (_metadataOverrides.containsKey(track.id) &&
          _metadataOverrides[track.id]!['coverPath'] != null) {
        coverUri = Uri.file(_metadataOverrides[track.id]!['coverPath']!);
      } else {
        coverUri = Uri.parse(
          'content://media/external/audio/media/${track.id}/albumart',
        );
      }

      final source = ConcatenatingAudioSource(
        children: [
          AudioSource.uri(
            parsedUri,
            tag: MediaItem(
              id: track.id,
              album: track.album,
              title: track.title,
              artist: track.artist,
              artUri: coverUri,
            ),
          ),
        ],
      );

      final int sessionId = ++_fadeSessionId;

      if (_audioPlayer.playing) {
        // Smooth fade out
        for (int i = 10; i >= 0; i--) {
          if (_fadeSessionId != sessionId) return;
          await _audioPlayer.setVolume(_volume * (i / 10));
          await Future.delayed(const Duration(milliseconds: 15));
        }
      }

      if (_fadeSessionId != sessionId) return;
      await _audioPlayer.setAudioSource(source);

      if (_fadeSessionId != sessionId) return;

      if (playImmediately) {
        await _audioPlayer.setVolume(0.0);
        _audioPlayer.play();
        // Smooth fade in
        for (int i = 1; i <= 10; i++) {
          if (_fadeSessionId != sessionId) return;
          await _audioPlayer.setVolume(_volume * (i / 10));
          await Future.delayed(const Duration(milliseconds: 15));
        }
        if (_fadeSessionId == sessionId) {
          await _audioPlayer.setVolume(_volume);
        }
      } else {
        await _audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('abort')) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing song: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Resync UI if a real error occurred
      final currentTag =
          _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      setState(() {
        _processingState = ProcessingState.idle;
        if (currentTag != null) {
          final index = _playbackQueue.indexWhere((t) => t.id == currentTag.id);
          if (index != -1) {
            _currentIndex = index;
            _playingTrack = _playbackQueue[index];
            _updateDominantColor(_playingTrack!);
          }
        }
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

  bool _isFading = false;

  Future<void> _pauseWithFade() async {
    if (_isFading || !_isPlaying) return;
    _isFading = true;
    final currentVol = _volume;
    for (int i = 10; i >= 0; i--) {
      if (!mounted) break;
      await _audioPlayer.setVolume(currentVol * (i / 10.0));
      await Future.delayed(const Duration(milliseconds: 15));
    }
    await _audioPlayer.pause();
    await _audioPlayer.setVolume(currentVol);
    _isFading = false;
  }

  Future<void> _playWithFade() async {
    if (_isFading || _isPlaying) return;
    _isFading = true;
    final currentVol = _volume;
    await _audioPlayer.setVolume(0.0);
    _audioPlayer.play();
    for (int i = 0; i <= 10; i++) {
      if (!mounted) break;
      await _audioPlayer.setVolume(currentVol * (i / 10.0));
      await Future.delayed(const Duration(milliseconds: 15));
    }
    await _audioPlayer.setVolume(currentVol);
    _isFading = false;
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

  void _showTrackOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isFavorited = _favoriteTrackIds.contains(track.id);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildTrackArtwork(track, size: 48, radius: 8),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${track.artist} • ${track.album}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildOptionItem(Icons.playlist_play, 'Play next', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _playbackQueue.insert(_currentIndex + 1, track);
                      Fluttertoast.showToast(msg: "Added to play next");
                    }
                  }),
                  _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                    Navigator.pop(context);
                    _playbackQueue.add(track);
                    Fluttertoast.showToast(msg: "Added to queue");
                  }),
                  _buildOptionItem(Icons.playlist_add, 'Add to playlist', () {
                    Navigator.pop(context);
                    _showAddToPlaylistModal(context, track);
                  }),
                  _buildOptionItem(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    'Favourite',
                    () {
                      _toggleFavorite(track.id);
                      setModalState(() {});
                    },
                    iconColor: isFavorited
                        ? const Color(0xFF1DB954)
                        : Colors.white,
                  ),
                  _buildOptionItem(Icons.album_outlined, 'Go to album', () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedFilter = 'Albums';
                      _selectedAlbumDetail = track.album;
                      _currentPageIndex = 3;
                      _pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  }),
                  _buildOptionItem(Icons.person_outline, 'Go to artist', () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedFilter = 'Artists';
                      _selectedArtistDetail = track.artist;
                      _currentPageIndex = 2;
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  }),
                  _buildOptionItem(Icons.edit_outlined, 'Edit metadata', () {
                    Navigator.pop(context);
                    _showEditMetadataModal(context, track);
                  }),
                  _buildOptionItem(
                    Icons.delete_outline,
                    'Delete from device',
                    () async {
                      Navigator.pop(context);
                      try {
                        final file = File(track.path);
                        if (await file.exists()) {
                          await file.delete();
                          setState(() {
                            _allTracks.removeWhere((t) => t.id == track.id);
                            _playbackQueue.removeWhere((t) => t.id == track.id);
                          });
                          Fluttertoast.showToast(msg: "Track deleted");
                        } else {
                          Fluttertoast.showToast(msg: "File not found");
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Cannot delete: Permission denied",
                        );
                      }
                    },
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddToPlaylistModal(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Add to Playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.add, color: Color(0xFF1DB954)),
                    title: const Text(
                      'Create New Playlist',
                      style: TextStyle(color: Color(0xFF1DB954)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreatePlaylistModal(context, trackToAdd: track);
                    },
                  ),
                  if (_userPlaylists.isNotEmpty)
                    const Divider(color: Colors.white10, height: 1),
                  ..._userPlaylists.keys.map((playlistName) {
                    return ListTile(
                      leading: const Icon(
                        Icons.queue_music,
                        color: Colors.white,
                      ),
                      title: Text(
                        playlistName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          if (!_userPlaylists[playlistName]!.contains(
                            track.id,
                          )) {
                            _userPlaylists[playlistName]!.add(track.id);
                            _saveUserPlaylists();
                          }
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Added to \$playlistName");
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistModal(BuildContext context, {Track? trackToAdd}) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'New Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty && !_userPlaylists.containsKey(name)) {
                  setState(() {
                    _userPlaylists[name] = trackToAdd != null
                        ? [trackToAdd.id]
                        : [];
                    _saveUserPlaylists();
                  });
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Playlist '\$name' created");
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveUserPlaylists() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_playlists', jsonEncode(_userPlaylists));
    });
  }

  void _savePlaylistCovers() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('playlist_covers', jsonEncode(_playlistCovers));
    });
  }

  void _showEditMetadataModal(BuildContext context, Track track) {
    final TextEditingController titleController = TextEditingController(
      text: track.title,
    );
    final TextEditingController artistController = TextEditingController(
      text: track.artist,
    );
    final TextEditingController albumController = TextEditingController(
      text: track.album,
    );

    String? currentCoverPath = _metadataOverrides[track.id]?['coverPath'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Metadata',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? image = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setModalState(() {
                                currentCoverPath = image.path;
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                              image: currentCoverPath != null
                                  ? DecorationImage(
                                      image: FileImage(File(currentCoverPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: currentCoverPath == null
                                ? const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white54,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: artistController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Artist',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: albumController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Album',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                            ),
                            onPressed: () {
                              setState(() {
                                _metadataOverrides[track.id] = {
                                  'title': titleController.text.trim(),
                                  'artist': artistController.text.trim(),
                                  'album': albumController.text.trim(),
                                };
                                if (currentCoverPath != null) {
                                  _metadataOverrides[track.id]!['coverPath'] =
                                      currentCoverPath!;
                                }

                                final index = _allTracks.indexWhere(
                                  (t) => t.id == track.id,
                                );
                                if (index != -1) {
                                  final t = _allTracks[index];
                                  _allTracks[index] = Track(
                                    id: t.id,
                                    title: titleController.text.trim(),
                                    artist: artistController.text.trim(),
                                    album: albumController.text.trim(),
                                    url: t.url,
                                    path: t.path,
                                    lyrics: t.lyrics,
                                  );
                                }

                                if (_playingTrack?.id == track.id &&
                                    index != -1) {
                                  _playingTrack = _allTracks[index];
                                  if (currentCoverPath != null) {
                                    _updateDominantColor(_playingTrack!);
                                  }
                                }
                              });
                              _saveMetadataOverrides();
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Metadata updated locally",
                              );
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveMetadataOverrides() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('metadata_overrides', jsonEncode(_metadataOverrides));
    });
  }

  Widget _buildOptionItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color iconColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DB954),
                      ),
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

            Positioned.fill(
              child: AnimatedSlide(
                duration: _isDraggingPlayer ? Duration.zero : const Duration(milliseconds: 400),
                curve: Curves.easeOutQuint,
                offset: _isPlayerOpen ? Offset(0, _playerDragOffset) : const Offset(0, 1),
                child: _playingTrack != null
                    ? _buildFullScreenPlayer(_playingTrack!)
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: SizedBox(
        height: 32,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = _currentPageIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == filters.length - 1 ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
              ),
            );
          }).toList(),
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
      } else if (_userPlaylists.containsKey(_selectedPlaylistDetail)) {
        final trackIds = _userPlaylists[_selectedPlaylistDetail]!;
        playlistSongs = _allTracks
            .where((t) => trackIds.contains(t.id))
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
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Color(0xFF1DB954)),
          ),
          title: const Text(
            'Create New Playlist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1DB954),
            ),
          ),
          onTap: () => _showCreatePlaylistModal(context),
        ),
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
        if (_userPlaylists.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8, left: 8),
            child: Text(
              'My Playlists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ..._userPlaylists.entries.map((entry) {
          final songs = _allTracks
              .where((t) => entry.value.contains(t.id))
              .toList();
          return _buildPlaylistCard(
            entry.key,
            songs,
            const Color(0xFF9C27B0),
            Icons.queue_music,
          );
        }),
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
      leading: _playlistCovers.containsKey(title)
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(_playlistCovers[title]!)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : _buildStackedArtwork(songs, color, icon, title == 'Favourites'),
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
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white24, size: 20),
        onPressed: () => _showPlaylistOptions(context, title, songs),
      ),
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    String title,
    List<Track> songs,
  ) {
    final isCustomPlaylist = _userPlaylists.containsKey(title);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildOptionItem(Icons.play_arrow, 'Play all', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playTrack(0, sourceList: songs);
                } else {
                  Fluttertoast.showToast(msg: "Playlist is empty");
                }
              }),
              _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playbackQueue.addAll(songs);
                  Fluttertoast.showToast(
                    msg: "Added ${songs.length} songs to queue",
                  );
                }
              }),
              if (isCustomPlaylist) ...[
                const Divider(color: Colors.white10, height: 1),
                _buildOptionItem(Icons.edit, 'Rename playlist', () {
                  Navigator.pop(context);
                  _showRenamePlaylistModal(context, title);
                }),
                _buildOptionItem(Icons.image, 'Edit cover', () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _playlistCovers[title] = image.path;
                    });
                    _savePlaylistCovers();
                    Fluttertoast.showToast(msg: "Playlist cover updated");
                  }
                }),
                _buildOptionItem(
                  Icons.delete_outline,
                  'Delete playlist',
                  () {
                    Navigator.pop(context);
                    setState(() {
                      _userPlaylists.remove(title);
                      _playlistCovers.remove(title);
                      _savePlaylistCovers();
                      if (_selectedPlaylistDetail == title) {
                        _selectedPlaylistDetail = null;
                      }
                    });
                    _saveUserPlaylists();
                    Fluttertoast.showToast(msg: "Playlist deleted");
                  },
                  iconColor: Colors.redAccent,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRenamePlaylistModal(BuildContext context, String oldName) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Rename Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'New playlist name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty &&
                    newName != oldName &&
                    !_userPlaylists.containsKey(newName)) {
                  setState(() {
                    final tracks = _userPlaylists.remove(oldName);
                    _userPlaylists[newName] = tracks!;
                    if (_playlistCovers.containsKey(oldName)) {
                      _playlistCovers[newName] = _playlistCovers.remove(
                        oldName,
                      )!;
                      _savePlaylistCovers();
                    }
                    if (_selectedPlaylistDetail == oldName) {
                      _selectedPlaylistDetail = newName;
                    }
                    _saveUserPlaylists();
                  });
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Playlist renamed");
                } else if (_userPlaylists.containsKey(newName)) {
                  Fluttertoast.showToast(msg: "Playlist name already exists");
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrackArtwork(
    Track track, {
    double size = 48,
    double radius = 8,
  }) {
    final customPath = _metadataOverrides[track.id]?['coverPath'];
    if (customPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
            image: FileImage(File(customPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: int.parse(track.id),
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkBorder: BorderRadius.zero,
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        size: size > 100 ? 1000 : 200,
        quality: size > 100 ? 100 : 50,
        artworkQuality: size > 100 ? FilterQuality.high : FilterQuality.low,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Icon(Icons.music_note, color: Colors.white54),
        ),
      ),
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
        child: _buildTrackArtwork(displayTracks.first, size: 56, radius: 28),
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
              child: _buildTrackArtwork(track, size: 56, radius: 28),
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
        final firstTrack = _allTracks.firstWhere((t) => t.artist == artist);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedArtistDetail = artist;
            });
          },
          leading: _buildTrackArtwork(firstTrack, size: 44, radius: 22),
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
        final firstTrack = _allTracks.firstWhere((t) => t.album == album);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedAlbumDetail = album;
            });
          },
          leading: _buildTrackArtwork(firstTrack, size: 44, radius: 6),
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
            leading: _buildTrackArtwork(track, size: 44, radius: 6),
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
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () => _showTrackOptions(context, track),
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
        onVerticalDragStart: (details) {
          setState(() {
            _isDraggingPlayer = true;
            _isPlayerOpen = true;
            _playerDragOffset = 1.0;
          });
        },
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta != null) {
            setState(() {
              _playerDragOffset += details.primaryDelta! / MediaQuery.of(context).size.height;
              if (_playerDragOffset < 0) _playerDragOffset = 0;
              if (_playerDragOffset > 1) _playerDragOffset = 1;
            });
          }
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDraggingPlayer = false;
            if (_playerDragOffset < 0.85 || (details.primaryVelocity ?? 0) < -300) {
              _isPlayerOpen = true;
              _playerDragOffset = 0.0;
            } else {
              _isPlayerOpen = false;
              _playerDragOffset = 0.0;
            }
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _isDraggingPlayer = false;
            _isPlayerOpen = false;
            _playerDragOffset = 0.0;
          });
        },
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: const Color(0xFF161616),
            end: _dominantColor != null
                ? Color.lerp(const Color(0xFF161616), _dominantColor, 0.4)
                : const Color(0xFF161616),
          ),
          duration: const Duration(milliseconds: 500),
          builder: (context, Color? color, child) {
            return Container(
              height: 60,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              _buildTrackArtwork(currentTrack, size: 44, radius: 6),
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
              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _playPrevious(),
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
                          _pauseWithFade();
                        } else {
                          _playWithFade();
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
                    leading: _buildTrackArtwork(track, size: 40, radius: 6),
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
        onVerticalDragStart: (details) {
          setState(() {
            _isDraggingPlayer = true;
          });
        },
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta != null) {
            setState(() {
              _playerDragOffset += details.primaryDelta! / MediaQuery.of(context).size.height;
              if (_playerDragOffset < 0) _playerDragOffset = 0;
            });
          }
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDraggingPlayer = false;
            if (_playerDragOffset > 0.15 || (details.primaryVelocity ?? 0) > 300) {
              _isPlayerOpen = false;
              _showLyrics = false;
            }
            _playerDragOffset = 0.0;
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _isDraggingPlayer = false;
            _playerDragOffset = 0.0;
          });
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFF0A0A0A))),
            Positioned.fill(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: const Color(0xFF1E1E1E),
                  end: _dominantColor ?? const Color(0xFF1E1E1E),
                ),
                duration: const Duration(milliseconds: 800),
                builder: (context, Color? color, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color ?? const Color(0xFF1E1E1E),
                          color != null ? Color.lerp(color, Colors.black, 0.85)! : const Color(0xFF0A0A0A),
                        ],
                      ),
                    ),
                  );
                },
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
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          onPressed: () =>
                              _showTrackOptions(context, currentTrack),
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
                            child: _buildTrackArtwork(
                              currentTrack,
                              size: MediaQuery.of(context).size.width * 0.85,
                              radius: 16,
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
                                    trackShape: const CustomTrackShape(),
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
                              _pauseWithFade();
                            } else {
                              _playWithFade();
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
                            Fluttertoast.showToast(
                              msg: "Lyrics coming soon",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
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

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
