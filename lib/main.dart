// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, unused_field
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';

import 'models/track.dart';

import 'screens/settings_screen.dart';
part 'ui/player_ui.dart';
part 'ui/detail_views_ui.dart';
part 'ui/tabs_ui.dart';
part 'ui/modals_ui.dart';

bool isBackgroundInitialized = false;
String? backgroundInitError;
late AudioHandler audioHandler;

class MyAudioHandler extends BaseAudioHandler {
  final player = AudioPlayer();

  MyAudioHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    player.sequenceStateStream.listen((sequenceState) {
      final queueItems = sequenceState.sequence
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(queueItems);

      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        final item = currentSource.tag as MediaItem?;
        if (item != null) {
          mediaItem.add(item);
        }
      }
    });
  }

  @override
  Future<void> play() async {
    if (_MainScreenState.mainScreenState != null) {
      await _MainScreenState.mainScreenState!._playWithFade();
    } else {
      await player.play();
    }
  }

  @override
  Future<void> pause() async {
    if (_MainScreenState.mainScreenState != null) {
      await _MainScreenState.mainScreenState!._pauseWithFade();
    } else {
      await player.pause();
    }
  }

  @override
  Future<void> stop() async {
    await player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
        controls: [],
      ),
    );
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_MainScreenState.mainScreenState != null) {
      _MainScreenState.mainScreenState!._playNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_MainScreenState.mainScreenState != null) {
      _MainScreenState.mainScreenState!._playPrevious();
    }
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'close') {
      await stop();
    } else if (name == 'favorite') {
      final currentId = mediaItem.value?.id;
      if (currentId != null && _MainScreenState.mainScreenState != null) {
        _MainScreenState.mainScreenState!._toggleFavorite(currentId);
        refreshPlaybackState();
      }
    }
  }

  void refreshPlaybackState() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
      ),
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState:
          const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[player.processingState] ??
          AudioProcessingState.idle,
      playing: player.playing,
      updatePosition: event.updatePosition,
      updateTime: event.updateTime,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.tunza.music.channel.audio.v6',
        androidNotificationChannelName: 'Tunza Audio Player',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'drawable/ic_notification',
      ),
    );
    isBackgroundInitialized = true;
  } catch (e, stackTrace) {
    debugPrint('AudioService init error: $e');
    debugPrint('StackTrace: $stackTrace');
    backgroundInitError = '$e\n$stackTrace';
    isBackgroundInitialized = false;
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static _MainScreenState? mainScreenState;
  final AudioPlayer _audioPlayer = (audioHandler as MyAudioHandler).player;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _lyricsScrollController = ScrollController();
  final ScrollController _detailScrollController = ScrollController();
  final ValueNotifier<int> _sleepTimerNotifier = ValueNotifier<int>(0);
  Timer? _sleepTimer;
  bool _sleepAtEndOfTrack = false;
  bool _filterShortAudio = false;
  bool _autoRegexClean = false;
  int _crossfadeDuration = 150;
  bool _pauseOnDisconnect = true;
  String _specificFolderScan = '';

  List<Track> _allTracks = [];
  bool _isLoading = true;
  bool _isPlayerOpen = false;
  bool _showLyrics = false;
  String _playingFromType = 'LIBRARY';
  String _playingFromName = 'All Songs';
  String? _lastIncrementedTrackId;

  List<Track> _playbackQueue = [];
  List<int> _shuffledIndices = [];
  Track? _playingTrack;
  int _currentIndex = 0;
  bool _isProgrammaticLoading = false;

  final Set<String> _favoriteTrackIds = {};
  final Set<String> _hiddenTrackIds = {};
  String _searchQuery = '';
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
  Future<Color?>? _detailColorFuture;
  int _fadeSessionId = 0;
  double _playerDragOffset = 0.0;
  bool _isDraggingPlayer = false;
  double _detailDragOffset = 0.0;
  bool _isDraggingDetail = false;

  Widget? _lastDetailView;
  String? _cachedDetailKey;
  List<Track>? _cachedDetailSongs;
  Widget? _cachedDetailImage;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filterShortAudio = prefs.getBool('filterShortAudio') ?? false;
      _autoRegexClean = prefs.getBool('autoRegexClean') ?? false;
      _crossfadeDuration = prefs.getInt('crossfadeDuration') ?? 150;
      _pauseOnDisconnect = prefs.getBool('pauseOnDisconnect') ?? true;
      _specificFolderScan = prefs.getString('specificFolderScan') ?? '';

      final cachedSongsStr = prefs.getString('cached_tracks_list');
      if (cachedSongsStr != null) {
        try {
          final List<dynamic> decodedList = jsonDecode(cachedSongsStr);
          final loadedTracks = decodedList
              .map((item) => Track.fromMap(Map<String, dynamic>.from(item)))
              .toList();
          if (loadedTracks.isNotEmpty) {
            _allTracks = loadedTracks;
            _playbackQueue = List.from(loadedTracks);
            _isLoading = false;
          }
        } catch (_) {}
      }
    });
  }

  void _startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes == -1) {
      setState(() {
        _sleepAtEndOfTrack = true;
        _sleepTimerNotifier.value = -1;
      });
      return;
    }
    setState(() {
      _sleepAtEndOfTrack = false;
    });
    if (minutes <= 0) {
      _sleepTimerNotifier.value = 0;
      return;
    }
    _sleepTimerNotifier.value = minutes * 60;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimerNotifier.value > 0) {
        _sleepTimerNotifier.value--;
      } else {
        _sleepTimer?.cancel();
        _pauseWithFade();
      }
    });
  }

  void _updatePlayingFrom() {
    setState(() {
      if (_selectedPlaylistDetail != null) {
        _playingFromType = 'PLAYLIST';
        _playingFromName = _selectedPlaylistDetail!;
      } else if (_selectedArtistDetail != null) {
        _playingFromType = 'ARTIST';
        _playingFromName = _selectedArtistDetail!;
      } else if (_selectedAlbumDetail != null) {
        _playingFromType = 'ALBUM';
        _playingFromName = _selectedAlbumDetail!;
      } else {
        _playingFromType = 'LIBRARY';
        _playingFromName = 'All Songs';
      }
    });
  }

  Future<void> _resetAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _favoriteTrackIds.clear();
      _playCounts.clear();
      _lastPlayedTrackIds.clear();
      _userPlaylists.clear();
      _metadataOverrides.clear();
      _playlistCovers.clear();
    });
    Fluttertoast.showToast(msg: "App data has been reset.");
    _loadSettings();
  }

  @override
  void initState() {
    super.initState();
    mainScreenState = this;
    _pageController = PageController();
    _loadSettings();
    _requestPermissionAndScan();
    _setupAudioStreams();

    if (backgroundInitError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text("Background Audio Error"),
              ],
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                "If you see this, background audio initialization has failed with the following native stack trace:\n\n$backgroundInitError",
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<Color?> _getDetailColor(Track? track, {String? playlistName}) async {
    ImageProvider? provider;
    if (playlistName != null && _playlistCovers.containsKey(playlistName)) {
      provider = ResizeImage(
        FileImage(File(_playlistCovers[playlistName]!)),
        width: 600,
      );
    } else if (track != null) {
      final customPath = _metadataOverrides[track.id]?['coverPath'];
      if (customPath != null) {
        provider = ResizeImage(FileImage(File(customPath)), width: 600);
      } else {
        final artwork = await _audioQuery.queryArtwork(
          int.parse(track.id),
          ArtworkType.AUDIO,
          size: 200,
        );
        if (artwork != null) provider = MemoryImage(artwork);
      }
    }

    if (provider != null) {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(100, 100),
      );
      return palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          palette.mutedColor?.color;
    }
    return null;
  }

  void _setupAudioStreams() {
    _audioPlayer.setLoopMode(_repeatMode == 2 ? LoopMode.one : LoopMode.off);
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (mounted) setState(() => _processingState = state);
    });

    _audioPlayer.currentIndexStream.listen((nativeIndex) {
      if (_isProgrammaticLoading) return;
      if (nativeIndex == null) return;
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        if (nativeIndex < concatenating.sequence.length) {
          final mediaItem =
              concatenating.sequence[nativeIndex].tag as MediaItem;
          final trackId = mediaItem.id;
          if (_playingTrack != null && _playingTrack!.id != trackId) {
            final newQueueIndex = _playbackQueue.indexWhere(
              (t) => t.id == trackId,
            );
            if (newQueueIndex != -1) {
              _playTrack(newQueueIndex, playImmediately: true);
            }
          }
        }
      }
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

    _audioPlayer.positionStream.listen((pos) {
      if (_playingTrack != null &&
          _lastIncrementedTrackId != _playingTrack!.id) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        final trackDuration = Duration(milliseconds: _playingTrack!.duration);
        final effectiveDuration = duration > Duration.zero
            ? duration
            : trackDuration;

        bool shouldIncrement = pos.inSeconds >= 10;
        if (!shouldIncrement && effectiveDuration > Duration.zero) {
          if (effectiveDuration.inSeconds < 10 &&
              pos >= effectiveDuration - const Duration(milliseconds: 500)) {
            shouldIncrement = true;
          }
        }

        if (shouldIncrement) {
          _lastIncrementedTrackId = _playingTrack!.id;
          setState(() {
            _playCounts[_playingTrack!.id] =
                (_playCounts[_playingTrack!.id] ?? 0) + 1;
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('play_counts', jsonEncode(_playCounts));
          });
        }
      }

      if (_sleepAtEndOfTrack) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        if (duration > Duration.zero &&
            pos >= duration - const Duration(milliseconds: 350)) {
          setState(() {
            _sleepAtEndOfTrack = false;
            _sleepTimerNotifier.value = 0;
          });
          _pauseWithFade();
        }
      }
    });
  }

  Future<void> _requestPermissionAndScan({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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
      List<String>? hidden = prefs.getStringList('hidden_track_ids');
      if (hidden != null) {
        _hiddenTrackIds.clear();
        _hiddenTrackIds.addAll(hidden);
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

      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Notification Required"),
                ],
              ),
              content: const Text(
                "Tunza needs the Notification permission to show music playback controls on your lock screen and background.\n\nPlease enable Notifications for Tunza in your phone's App Settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: const Text("OPEN SETTINGS"),
                ),
              ],
            ),
          );
        }
      }

      if (permissionGranted) {
        final List<SongModel> songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        if (songs.isNotEmpty) {
          var filteredSongs = songs;
          if (_filterShortAudio) {
            filteredSongs = filteredSongs
                .where((s) => (s.duration ?? 0) >= 30000)
                .toList();
          }
          if (_specificFolderScan.isNotEmpty) {
            try {
              final allowedDirs = List<String>.from(
                jsonDecode(_specificFolderScan),
              );
              if (allowedDirs.isNotEmpty) {
                filteredSongs = filteredSongs.where((song) {
                  final parentDir = _getParentDirectory(song.data);
                  return allowedDirs.contains(parentDir);
                }).toList();
              }
            } catch (_) {}
          }
          _allTracks = filteredSongs
              .map((song) {
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

                if (_autoRegexClean &&
                    !_metadataOverrides.containsKey(song.id.toString())) {
                  final artistPrefix = RegExp(
                    '^${RegExp.escape(artist)}\\s*[-|:]\\s*',
                    caseSensitive: false,
                  );
                  if (artistPrefix.hasMatch(title)) {
                    title = title.replaceAll(artistPrefix, '');
                  }
                  final tagsToRemove = RegExp(
                    r'[\[\(](official|audio|video|lyric|lyrics|music video|official video|official audio|official lyric video|official music video)[\]\)]',
                    caseSensitive: false,
                  );
                  title = title.replaceAll(tagsToRemove, '').trim();

                  final artistSuffix = RegExp(
                    r'\s*[-|:]\s*' + RegExp.escape(artist) + r'$',
                    caseSensitive: false,
                  );
                  if (artistSuffix.hasMatch(title)) {
                    title = title.replaceAll(artistSuffix, '').trim();
                  }
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
                  duration: song.duration ?? 0,
                );
              })
              .where((t) => !_hiddenTrackIds.contains(t.id))
              .toList();
          if (_allTracks.isNotEmpty) {
            final serialized = _allTracks.map((t) => t.toMap()).toList();
            prefs.setString('cached_tracks_list', jsonEncode(serialized));
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _cachedDetailKey = null;
        });

        if (_allTracks.isNotEmpty) {
          _playbackQueue = List.from(_allTracks);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        imageProvider = ResizeImage(FileImage(File(customPath)), width: 600);
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

  Future<Uri?> _getCoverUriForTrack(Track track) async {
    if (_metadataOverrides.containsKey(track.id) &&
        _metadataOverrides[track.id]!['coverPath'] != null) {
      return Uri.file(_metadataOverrides[track.id]!['coverPath']!);
    }
    try {
      final cacheDir = Directory.systemTemp;
      final cacheFile = File('${cacheDir.path}/album_art_${track.id}.png');
      if (await cacheFile.exists()) {
        return Uri.file(cacheFile.path);
      }
      final bytes = await _audioQuery.queryArtwork(
        int.parse(track.id),
        ArtworkType.AUDIO,
        size: 300,
      );
      if (bytes != null) {
        await cacheFile.writeAsBytes(bytes);
        return Uri.file(cacheFile.path);
      }
    } catch (_) {}
    return null;
  }

  void _updateCurrentSourceSilently() async {
    try {
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        int nextSourceIndexInConcatenating = _currentIndex > 0 ? 2 : 1;

        if (_currentIndex + 1 < _playbackQueue.length) {
          final nextTrack = _playbackQueue[_currentIndex + 1];
          final nextUri = nextTrack.url.startsWith('/')
              ? Uri.file(nextTrack.url)
              : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
          final nextCover = await _getCoverUriForTrack(nextTrack);
          final newNextSource = AudioSource.uri(
            nextUri,
            tag: MediaItem(
              id: nextTrack.id,
              album: nextTrack.album.trim().isEmpty
                  ? 'Unknown Album'
                  : nextTrack.album,
              title: nextTrack.title.trim().isEmpty
                  ? 'Unknown Title'
                  : nextTrack.title,
              artist: nextTrack.artist.trim().isEmpty
                  ? 'Unknown Artist'
                  : nextTrack.artist,
              artUri: nextCover,
              duration: Duration(milliseconds: nextTrack.duration),
            ),
          );

          if (nextSourceIndexInConcatenating < concatenating.length) {
            await concatenating.removeAt(nextSourceIndexInConcatenating);
            await concatenating.insert(
              nextSourceIndexInConcatenating,
              newNextSource,
            );
          } else {
            await concatenating.add(newNextSource);
          }
        } else {
          if (nextSourceIndexInConcatenating < concatenating.length) {
            await concatenating.removeAt(nextSourceIndexInConcatenating);
          }
        }
      }
    } catch (_) {}
  }

  void _moveTrackInQueue(Track track, int targetIndex) {
    setState(() {
      final existingIndex = _playbackQueue.indexWhere((t) => t.id == track.id);
      int adjustedTargetIndex = targetIndex;

      if (existingIndex != -1) {
        if (existingIndex == _currentIndex) {
          return;
        }

        _playbackQueue.removeAt(existingIndex);

        _shuffledIndices.remove(existingIndex);
        for (int i = 0; i < _shuffledIndices.length; i++) {
          if (_shuffledIndices[i] > existingIndex) {
            _shuffledIndices[i]--;
          }
        }

        if (existingIndex < _currentIndex) {
          _currentIndex--;
        }

        if (adjustedTargetIndex > existingIndex) {
          adjustedTargetIndex--;
        }
      }

      if (adjustedTargetIndex > _playbackQueue.length) {
        adjustedTargetIndex = _playbackQueue.length;
      }
      if (adjustedTargetIndex < 0) {
        adjustedTargetIndex = 0;
      }

      _playbackQueue.insert(adjustedTargetIndex, track);

      for (int i = 0; i < _shuffledIndices.length; i++) {
        if (_shuffledIndices[i] >= adjustedTargetIndex) {
          _shuffledIndices[i]++;
        }
      }

      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        final currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
        if (currentShuffledPos != -1) {
          _shuffledIndices.insert(currentShuffledPos + 1, adjustedTargetIndex);
        } else {
          _shuffledIndices.add(adjustedTargetIndex);
        }
      } else {
        _shuffledIndices = List.generate(_playbackQueue.length, (i) => i);
      }
    });

    _updateCurrentSourceSilently();
  }

  void _toggleRepeatMode() {
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3;
      _audioPlayer.setLoopMode(_repeatMode == 2 ? LoopMode.one : LoopMode.off);
    });
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
      _lastIncrementedTrackId = null;
      if (_isShuffle && !queueMatches && sourceList != null) {
        _shuffledIndices.remove(_currentIndex);
        _shuffledIndices.insert(0, _currentIndex);
      }

      if (playImmediately) {
        _lastPlayedTrackIds.remove(track.id);
        _lastPlayedTrackIds.insert(0, track.id);
        if (_lastPlayedTrackIds.length > 100) _lastPlayedTrackIds.removeLast();
      }
    });

    _updateDominantColor(track);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_playing_track_id', track.id);
      if (playImmediately) {
        prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      }
    });

    _isProgrammaticLoading = true;
    try {
      final currentUri = track.url.startsWith('/')
          ? Uri.file(track.url)
          : (Uri.tryParse(track.url) ?? Uri.parse(''));
      final currentCover = await _getCoverUriForTrack(track);

      final currentSource = AudioSource.uri(
        currentUri,
        tag: MediaItem(
          id: track.id,
          album: track.album.trim().isEmpty ? 'Unknown Album' : track.album,
          title: track.title.trim().isEmpty ? 'Unknown Title' : track.title,
          artist: track.artist.trim().isEmpty ? 'Unknown Artist' : track.artist,
          artUri: currentCover,
          duration: Duration(milliseconds: track.duration),
        ),
      );

      AudioSource source;
      int initialIndex = 0;

      if (_playbackQueue.length <= 1) {
        source = currentSource;
      } else {
        final List<AudioSource> children = [];

        // Previous track
        if (index > 0) {
          final prevTrack = _playbackQueue[index - 1];
          final prevUri = prevTrack.url.startsWith('/')
              ? Uri.file(prevTrack.url)
              : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
          final prevCover = await _getCoverUriForTrack(prevTrack);
          children.add(
            AudioSource.uri(
              prevUri,
              tag: MediaItem(
                id: prevTrack.id,
                album: prevTrack.album.trim().isEmpty
                    ? 'Unknown Album'
                    : prevTrack.album,
                title: prevTrack.title.trim().isEmpty
                    ? 'Unknown Title'
                    : prevTrack.title,
                artist: prevTrack.artist.trim().isEmpty
                    ? 'Unknown Artist'
                    : prevTrack.artist,
                artUri: prevCover,
                duration: Duration(milliseconds: prevTrack.duration),
              ),
            ),
          );
          initialIndex = 1;
        }

        // Current track
        children.add(currentSource);

        // Next track
        if (index < _playbackQueue.length - 1) {
          final nextTrack = _playbackQueue[index + 1];
          final nextUri = nextTrack.url.startsWith('/')
              ? Uri.file(nextTrack.url)
              : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
          final nextCover = await _getCoverUriForTrack(nextTrack);
          children.add(
            AudioSource.uri(
              nextUri,
              tag: MediaItem(
                id: nextTrack.id,
                album: nextTrack.album.trim().isEmpty
                    ? 'Unknown Album'
                    : nextTrack.album,
                title: nextTrack.title.trim().isEmpty
                    ? 'Unknown Title'
                    : nextTrack.title,
                artist: nextTrack.artist.trim().isEmpty
                    ? 'Unknown Artist'
                    : nextTrack.artist,
                artUri: nextCover,
                duration: Duration(milliseconds: nextTrack.duration),
              ),
            ),
          );
        }

        source = ConcatenatingAudioSource(
          children: children,
          useLazyPreparation: true,
        );
      }

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
      await _audioPlayer.setAudioSource(source, initialIndex: initialIndex);

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
          _audioPlayer.sequenceState.currentSource?.tag as MediaItem?;
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
    } finally {
      _isProgrammaticLoading = false;
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
    _detailScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDetailView =
        (_currentPageIndex == 1 && _selectedPlaylistDetail != null) ||
        (_currentPageIndex == 2 && _selectedArtistDetail != null) ||
        (_currentPageIndex == 3 && _selectedAlbumDetail != null);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: !_isPlayerOpen && !isDetailView && !_showLyrics,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_showLyrics) {
            setState(() => _showLyrics = false);
          } else if (_isPlayerOpen) {
            setState(() => _isPlayerOpen = false);
          } else if (isDetailView) {
            setState(() {
              _selectedPlaylistDetail = null;
              _selectedArtistDetail = null;
              _selectedAlbumDetail = null;
            });
          }
        },
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
                        ],
                      ),
              ),

              Positioned.fill(
                child: AnimatedSlide(
                  duration: _isDraggingDetail
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  offset: isDetailView
                      ? Offset(0, _detailDragOffset)
                      : const Offset(0, 1),
                  child: _getActiveDetailView(),
                ),
              ),

              if (_playingTrack != null) _buildMiniPlayer(_playingTrack!),

              Positioned.fill(
                child: AnimatedSlide(
                  duration: _isDraggingPlayer
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuint,
                  offset: _isPlayerOpen
                      ? Offset(0, _playerDragOffset)
                      : const Offset(0, 1),
                  child: _playingTrack != null
                      ? _buildFullScreenPlayer(_playingTrack!)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  ? 'Playlists'
                  : _currentPageIndex == 2
                  ? 'Artists'
                  : 'Albums',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onRescanLibrary: () {
                        _loadSettings();
                        _loadSettings();
                        _requestPermissionAndScan();
                      },
                      onSetSleepTimer: _startSleepTimer,
                      onResetData: _resetAppData,
                      sleepTimerNotifier: _sleepTimerNotifier,
                      onManageFolders: () => _showFolderScanDialog(context),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
                color: Colors.white.withValues(alpha: 0.03),
              ),
              child: Icon(
                Icons.music_note_outlined,
                size: 40,
                color: Colors.white.withValues(alpha: 0.4),
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
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
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
          _searchQuery = '';
          _searchController.clear();

          List<Track> pSongs = [];
          if (title == 'Favourites') {
            pSongs = _allTracks
                .where((t) => _favoriteTrackIds.contains(t.id))
                .toList();
          } else if (title == 'Recently Added') {
            pSongs = List.from(_allTracks);
          } else if (title == 'Last Played') {
            pSongs = _lastPlayedTrackIds
                .map(
                  (id) => _allTracks.firstWhere(
                    (t) => t.id == id,
                    orElse: () => _allTracks[0],
                  ),
                )
                .where((t) => _lastPlayedTrackIds.contains(t.id))
                .toList();
          } else if (title == 'Most Played') {
            pSongs = List.from(_allTracks);
            pSongs.sort(
              (a, b) =>
                  (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
            );
            pSongs = pSongs.where((t) => (_playCounts[t.id] ?? 0) > 0).toList();
          } else if (_userPlaylists.containsKey(title)) {
            pSongs = _allTracks
                .where((t) => _userPlaylists[title]!.contains(t.id))
                .toList();
          }
          _detailColorFuture = _getDetailColor(
            pSongs.isNotEmpty ? pSongs.first : null,
            playlistName: title,
          );
        });
      },
      leading: _playlistCovers.containsKey(title)
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: ResizeImage(
                    FileImage(File(_playlistCovers[title]!)),
                    width: 600,
                  ),
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
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white24, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _showPlaylistOptions(context, title, songs),
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
          color: color.withValues(alpha: 0.1),
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
          color: color.withValues(alpha: 0.1),
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

  void _showQueueBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<int> effectiveIndices;
        if (_repeatMode == 2) {
          effectiveIndices = [_currentIndex];
        } else if (_repeatMode == 1) {
          if (_isShuffle && _shuffledIndices.length == _playbackQueue.length) {
            int pos = _shuffledIndices.indexOf(_currentIndex);
            if (pos != -1) {
              effectiveIndices = [
                ..._shuffledIndices.sublist(pos),
                ..._shuffledIndices.sublist(0, pos),
              ];
            } else {
              effectiveIndices = _shuffledIndices;
            }
          } else {
            effectiveIndices = [
              ...List.generate(
                _playbackQueue.length - _currentIndex,
                (i) => _currentIndex + i,
              ),
              ...List.generate(_currentIndex, (i) => i),
            ];
          }
        } else {
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

  String _getParentDirectory(String filePath) {
    final lastSeparator = filePath.lastIndexOf('/');
    if (lastSeparator == -1) return '';
    return filePath.substring(0, lastSeparator);
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
