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
import 'package:url_launcher/url_launcher.dart';

import 'models/track.dart';

import 'screens/settings_screen.dart';
part 'ui/player_ui.dart';
part 'ui/detail_views_ui.dart';
part 'ui/tabs_ui.dart';
part 'ui/modals_ui.dart';

bool isBackgroundInitialized = false;
String? backgroundInitError;
late AudioHandler audioHandler;
final ValueNotifier<String> activeFontNotifier = ValueNotifier<String>(
  'Plus Jakarta Sans',
);
final ValueNotifier<double> fontScaleNotifier = ValueNotifier<double>(1.0);
final ValueNotifier<String> themeModeNotifier = ValueNotifier<String>('dark');
final ValueNotifier<String> customThemeBgNotifier = ValueNotifier<String>(
  'dynamic',
);
final ValueNotifier<Color?> dominantColorNotifier = ValueNotifier<Color?>(null);
final ValueNotifier<String?> customThemeBgPathNotifier = ValueNotifier<String?>(
  null,
);
final ValueNotifier<double> customThemeBgBlurNotifier = ValueNotifier<double>(
  25.0,
);
final ValueNotifier<double> customThemeBgDimNotifier = ValueNotifier<double>(
  0.65,
);
final ValueNotifier<double> customThemeBgScaleNotifier = ValueNotifier<double>(
  1.0,
);
final ValueNotifier<String> customThemeStyleNotifier = ValueNotifier<String>(
  'dark',
);
final ValueNotifier<double> customThemeBgOffsetXNotifier =
    ValueNotifier<double>(0.0);
final ValueNotifier<double> customThemeBgOffsetYNotifier =
    ValueNotifier<double>(0.0);
final ValueNotifier<double> playerCustomBgOffsetXNotifier =
    ValueNotifier<double>(0.0);
final ValueNotifier<double> playerCustomBgOffsetYNotifier =
    ValueNotifier<double>(0.0);
void showTunzaToast(String msg, {bool isLong = false}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color(0xFF1E1E1E),
    textColor: Colors.white,
    fontSize: 14.0,
  );
}

bool get isAppLight {
  final mode = themeModeNotifier.value;
  if (mode == 'light') return true;
  if (mode == 'custom') {
    final style = customThemeStyleNotifier.value;
    if (style == 'light') return true;
    if (style == 'dynamic') {
      final activeCol = dominantColorNotifier.value ?? const Color(0xFF8E8E93);
      return activeCol.computeLuminance() > 0.45;
    }
  }
  return false;
}

Color getAppBackgroundColor({
  required String themeMode,
  required String customBg,
  required Color? artworkColor,
}) {
  if (themeMode == 'light') return const Color(0xFFF6F8FA);
  if (themeMode == 'dark') return const Color(0xFF0A0A0A);
  switch (customBg) {
    case 'custom_image':
      return Colors.transparent;
    case 'navy':
      return const Color(0xFF0B132B);
    case 'forest':
      return const Color(0xFF0D1F1D);
    case 'wine':
      return const Color(0xFF1A0F1A);
    case 'terracotta':
      return const Color(0xFF211510);
    case 'slate':
      return const Color(0xFF1C2541);
    case 'dynamic':
    default:
      if (artworkColor == null) return const Color(0xFF0F0F15);
      final hsl = HSLColor.fromColor(artworkColor);
      return hsl
          .withSaturation(clampDouble(hsl.saturation * 0.35, 0.1, 0.25))
          .withLightness(clampDouble(hsl.lightness * 0.12, 0.04, 0.08))
          .toColor();
  }
}

Color getAppCardColor({required String themeMode, required Color appBgColor}) {
  if (themeMode == 'light') return Colors.white;
  if (themeMode == 'dark') return const Color(0xFF161616);
  final hsl = HSLColor.fromColor(appBgColor);
  return hsl
      .withLightness(clampDouble(hsl.lightness + 0.04, 0.06, 0.16))
      .toColor();
}

class MyAudioHandler extends BaseAudioHandler {
  final player = AudioPlayer(handleInterruptions: false);

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

Future<void> configureAudioSession(bool playTogether) async {
  final session = await AudioSession.instance;
  if (playTogether) {
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: false,
      ),
    );
  } else {
    await session.configure(const AudioSessionConfiguration.music());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();
  final playTogether = prefs.getBool('playTogether') ?? false;
  await configureAudioSession(playTogether);

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
    return ValueListenableBuilder<String>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: customThemeBgNotifier,
          builder: (context, customThemeBg, child) {
            return ValueListenableBuilder<Color?>(
              valueListenable: dominantColorNotifier,
              builder: (context, dominantColor, child) {
                return ValueListenableBuilder<String>(
                  valueListenable: customThemeStyleNotifier,
                  builder: (context, customThemeStyle, child) {
                    final appBgColor = getAppBackgroundColor(
                      themeMode: themeMode,
                      customBg: customThemeBg,
                      artworkColor: dominantColor,
                    );
                    final appCardColor = getAppCardColor(
                      themeMode: themeMode,
                      appBgColor: appBgColor,
                    );

                    bool isLight = themeMode == 'light';
                    if (themeMode == 'custom') {
                      if (customThemeStyle == 'light') {
                        isLight = true;
                      } else if (customThemeStyle == 'dynamic') {
                        final activeCol =
                            dominantColor ?? const Color(0xFF8E8E93);
                        isLight = activeCol.computeLuminance() > 0.45;
                      }
                    }

                    return ValueListenableBuilder<String>(
                      valueListenable: activeFontNotifier,
                      builder: (context, fontName, child) {
                        final baseTheme = isLight
                            ? ThemeData.light()
                            : ThemeData.dark();
                        TextTheme textTheme;
                        if (fontName == 'Spotify Style') {
                          textTheme = GoogleFonts.figtreeTextTheme(
                            baseTheme.textTheme,
                          );
                        } else if (fontName == 'Apple Music Style') {
                          textTheme = GoogleFonts.interTextTheme(
                            baseTheme.textTheme,
                          );
                        } else {
                          textTheme = GoogleFonts.plusJakartaSansTextTheme(
                            baseTheme.textTheme,
                          );
                        }

                        return ValueListenableBuilder<double>(
                          valueListenable: fontScaleNotifier,
                          builder: (context, scale, child) {
                            return MaterialApp(
                              title: 'Tunza',
                              debugShowCheckedModeBanner: false,
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(textScaleFactor: scale),
                                  child: child!,
                                );
                              },
                              theme: ThemeData(
                                useMaterial3: true,
                                brightness: isLight
                                    ? Brightness.light
                                    : Brightness.dark,
                                scaffoldBackgroundColor: appBgColor,
                                textTheme: textTheme.apply(
                                  bodyColor: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  displayColor: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                ),
                                colorScheme: ColorScheme(
                                  brightness: isLight
                                      ? Brightness.light
                                      : Brightness.dark,
                                  primary: const Color(0xFF1DB954),
                                  onPrimary: Colors.black,
                                  secondary: const Color(0xFF1DB954),
                                  onSecondary: Colors.black,
                                  error: Colors.red,
                                  onError: Colors.white,
                                  surface: appCardColor,
                                  onSurface: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  outline: isLight
                                      ? Colors.black12
                                      : Colors.white10,
                                ),
                                listTileTheme: ListTileThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              home: const MainScreen(),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // ignore: library_private_types_in_public_api
  static _MainScreenState? get mainScreenState =>
      _MainScreenState.mainScreenState;

  static void showEqualizer(BuildContext context) {
    if (mainScreenState != null) {
      final sessionId = mainScreenState!.player.androidAudioSessionId ?? 0;
      if (sessionId == 0) {
        showTunzaToast("Please play a song first to use the Equalizer!");
      } else {
        mainScreenState!._showEqualizerSheet(context);
      }
    }
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  static _MainScreenState? mainScreenState;
  AudioPlayer get player => _audioPlayer;
  final AudioPlayer _audioPlayer = (audioHandler as MyAudioHandler).player;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _lyricsScrollController = ScrollController();
  final ScrollController _detailScrollController = ScrollController();
  final ValueNotifier<int> _sleepTimerNotifier = ValueNotifier<int>(0);
  Timer? _sleepTimer;
  bool _sleepAtEndOfTrack = false;
  bool _isNaturalFadingOut = false;
  String? _lastCrossfadedTrackId;
  bool _filterShortAudio = false;
  bool _autoRegexClean = false;
  int _crossfadeDuration = 200;
  bool _pauseOnDisconnect = true;
  bool _autoPlayAfterCall = true;
  bool _playTogether = false;
  int _playCountThreshold = 10;
  String _activeFont = 'Plus Jakarta Sans';
  double _fontScale = 1.0;
  String _specificFolderScan = '';
  bool _skipSilence = false;
  bool _stopOnLowBattery = false;
  bool _monoAudio = false;
  Timer? _batteryCheckTimer;
  String _sortBy = 'date';
  String _detailSortBy = 'default';
  final Set<String> _animatedTrackIds = {};
  final Set<String> _animatedPlaylistIds = {};
  final Set<String> _animatedArtistIds = {};
  final Set<String> _animatedAlbumIds = {};
  final Set<String> _animatedDetailTrackIds = {};

  List<Track> _allTracks = [];
  bool _isLoading = true;
  bool _isPlayerOpen = false;
  bool _showLyrics = false;
  String? _currentLyricsPlain;
  List<LyricsLine> _currentLyricsSynced = [];
  bool _isLyricsLoading = false;
  bool _isLyricsSynced = false;
  int _lastActiveLyricsIndex = -1;
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
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebouncer;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isPlaying = false;
  bool _isShuffle = false;
  int _repeatMode = 1;
  final double _volume = 1.0;
  ProcessingState _processingState = ProcessingState.idle;
  double? _dragValue;
  Color? _dominantColor;
  ValueNotifier<Color?> get _dominantColorNotifier => dominantColorNotifier;
  String _playerBackgroundStyle = 'gradient';
  final ValueNotifier<String> _playerBackgroundStyleNotifier =
      ValueNotifier<String>('gradient');
  String? _playerCustomBgPath;
  final ValueNotifier<String?> _playerCustomBgPathNotifier =
      ValueNotifier<String?>(null);
  double _playerCustomBgBlur = 0.0;
  final ValueNotifier<double> _playerCustomBgBlurNotifier =
      ValueNotifier<double>(0.0);
  double _playerCustomBgDim = 0.4;
  final ValueNotifier<double> _playerCustomBgDimNotifier =
      ValueNotifier<double>(0.4);
  double _playerCustomBgScale = 1.0;
  final ValueNotifier<double> _playerCustomBgScaleNotifier =
      ValueNotifier<double>(1.0);
  String _themeAccentPreset = 'spotify';
  String _themeMode = 'dark';
  String _customThemeBg = 'dynamic';
  String? _customThemeBgPath;
  ValueNotifier<String?> get _customThemeBgPathNotifier =>
      customThemeBgPathNotifier;
  double _customThemeBgBlur = 25.0;
  final ValueNotifier<double> _customThemeBgBlurNotifier =
      customThemeBgBlurNotifier;
  double _customThemeBgDim = 0.65;
  final ValueNotifier<double> _customThemeBgDimNotifier =
      customThemeBgDimNotifier;
  double _customThemeBgScale = 1.0;
  final ValueNotifier<double> _customThemeBgScaleNotifier =
      customThemeBgScaleNotifier;
  String _customThemeStyle = 'dark';
  final ValueNotifier<String> _customThemeStyleNotifier =
      customThemeStyleNotifier;

  Color _ensureLuminance(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.55) {
      if (hsl.saturation < 0.12) {
        return const Color(0xFFB3B3B3);
      }
      return hsl.withLightness(0.6).toColor();
    }
    return color;
  }

  Color get _activeAccentColor {
    if (_themeAccentPreset == 'dynamic') {
      final baseColor = _dominantColor ?? const Color(0xFF8E8E93);
      return _ensureLuminance(baseColor);
    }
    switch (_themeAccentPreset) {
      case 'spotify':
        return const Color(0xFF1DB954);
      case 'apple':
        return const Color(0xFFFC3C44);
      case 'purple':
        return const Color(0xFF8E2DE2);
      case 'tidal':
        return const Color(0xFF00F2FE);
      case 'orange':
        return const Color(0xFFFF9233);
      case 'sakura':
        return const Color(0xFFFF2A6D);
      case 'gold':
        return const Color(0xFFDFBA59);
      case 'blue':
        return const Color(0xFF007AFF);
      case 'lime':
        return const Color(0xFFCCFF00);
      default:
        return const Color(0xFF1DB954);
    }
  }

  Future<Color?>? _detailColorFuture;
  int _fadeSessionId = 0;
  final ValueNotifier<double> _playerDragOffsetNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isDraggingPlayerNotifier = ValueNotifier(false);
  final ValueNotifier<double> _detailDragOffsetNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isDraggingDetailNotifier = ValueNotifier(false);

  Widget? _lastDetailView;
  String? _cachedDetailKey;
  List<Track>? _cachedDetailSongs;
  Widget? _cachedDetailImage;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filterShortAudio = prefs.getBool('filterShortAudio') ?? false;
      _autoRegexClean = prefs.getBool('autoRegexClean') ?? false;
      _crossfadeDuration = prefs.getInt('crossfadeDuration') ?? 200;
      _pauseOnDisconnect = prefs.getBool('pauseOnDisconnect') ?? true;
      _autoPlayAfterCall = prefs.getBool('autoPlayAfterCall') ?? true;
      _playTogether = prefs.getBool('playTogether') ?? false;
      _playCountThreshold = prefs.getInt('playCountThreshold') ?? 10;
      _activeFont = prefs.getString('activeFont') ?? 'Plus Jakarta Sans';
      _fontScale = prefs.getDouble('fontScale') ?? 1.0;
      activeFontNotifier.value = _activeFont;
      fontScaleNotifier.value = _fontScale;
      _specificFolderScan = prefs.getString('specificFolderScan') ?? '';
      _skipSilence = prefs.getBool('skipSilence') ?? false;
      _stopOnLowBattery = prefs.getBool('stopOnLowBattery') ?? false;
      _monoAudio = prefs.getBool('monoAudio') ?? false;
      _sortBy = prefs.getString('sortBy') ?? 'date';
      _detailSortBy = prefs.getString('detailSortBy') ?? 'default';
      _themeAccentPreset = prefs.getString('themeAccentPreset') ?? 'spotify';
      _themeMode = prefs.getString('themeMode') ?? 'dark';
      _customThemeBg = prefs.getString('customThemeBg') ?? 'dynamic';
      _customThemeBgPath = prefs.getString('customThemeBgPath');
      _customThemeBgBlur = prefs.getDouble('customThemeBgBlur') ?? 25.0;
      _customThemeBgDim = prefs.getDouble('customThemeBgDim') ?? 0.65;
      _customThemeBgScale = prefs.getDouble('customThemeBgScale') ?? 1.0;
      double customOffsetX = prefs.getDouble('customThemeBgOffsetX') ?? 0.0;
      double customOffsetY = prefs.getDouble('customThemeBgOffsetY') ?? 0.0;
      customThemeBgOffsetXNotifier.value = customOffsetX;
      customThemeBgOffsetYNotifier.value = customOffsetY;

      _customThemeStyle = prefs.getString('customThemeStyle') ?? 'dark';
      themeModeNotifier.value = _themeMode;
      customThemeBgNotifier.value = _customThemeBg;
      customThemeBgPathNotifier.value = _customThemeBgPath;
      customThemeBgBlurNotifier.value = _customThemeBgBlur;
      customThemeBgDimNotifier.value = _customThemeBgDim;
      customThemeBgScaleNotifier.value = _customThemeBgScale;
      customThemeStyleNotifier.value = _customThemeStyle;
      _playerBackgroundStyle =
          prefs.getString('playerBackgroundStyle') ?? 'gradient';
      _playerBackgroundStyleNotifier.value = _playerBackgroundStyle;
      _playerCustomBgPath = prefs.getString('playerCustomBgPath');
      _playerCustomBgPathNotifier.value = _playerCustomBgPath;
      _playerCustomBgBlur = prefs.getDouble('playerCustomBgBlur') ?? 0.0;
      _playerCustomBgBlurNotifier.value = _playerCustomBgBlur;
      _playerCustomBgDim = prefs.getDouble('playerCustomBgDim') ?? 0.4;
      _playerCustomBgDimNotifier.value = _playerCustomBgDim;
      _playerCustomBgScale = prefs.getDouble('playerCustomBgScale') ?? 1.0;
      _playerCustomBgScaleNotifier.value = _playerCustomBgScale;

      double playerOffsetX = prefs.getDouble('playerCustomBgOffsetX') ?? 0.0;
      double playerOffsetY = prefs.getDouble('playerCustomBgOffsetY') ?? 0.0;
      playerCustomBgOffsetXNotifier.value = playerOffsetX;
      playerCustomBgOffsetYNotifier.value = playerOffsetY;

      _audioPlayer.setSkipSilenceEnabled(_skipSilence);

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
    showTunzaToast("App data has been reset.");
    _loadSettings();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mainScreenState = this;
    _pageController = PageController();
    _loadSettings();
    _requestPermissionAndScan();
    _setupAudioStreams();
    _startBatteryMonitor();

    AudioSession.instance.then((session) {
      session.becomingNoisyEventStream.listen((_) {
        if (_pauseOnDisconnect && _audioPlayer.playing) {
          _pauseWithFade();
          showTunzaToast("Headphones unplugged. Paused.");
        }
      });

      bool playBeforeInterruption = false;
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              if (_audioPlayer.playing) {
                _audioPlayer.setVolume(_volume * 0.2);
              }
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (_audioPlayer.playing && !_playTogether) {
                playBeforeInterruption = true;
                _pauseWithFade();
              }
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _audioPlayer.setVolume(_volume);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (playBeforeInterruption && _autoPlayAfterCall) {
                _playWithFade();
              }
              playBeforeInterruption = false;
              break;
          }
        }
      });
    });

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

  void _startBatteryMonitor() {
    _batteryCheckTimer?.cancel();
    _batteryCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      if (_stopOnLowBattery && _audioPlayer.playing) {
        try {
          const channel = MethodChannel('com.tunza.audio/equalizer');
          final result = await channel.invokeMapMethod<String, dynamic>(
            'getBatteryStatus',
          );
          if (result != null) {
            final int level = result['level'] ?? -1;
            final bool isCharging = result['isCharging'] ?? false;
            if (level != -1 && level <= 15 && !isCharging) {
              _pauseWithFade();
              showTunzaToast(
                "Battery low ($level%). Playback paused.",
                isLong: true,
              );
            }
          }
        } catch (_) {}
      }
    });
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
              if (nativeIndex == 2) {
                _slideWindowInPlace(newQueueIndex, 1);
              } else if (nativeIndex == 0) {
                _slideWindowInPlace(newQueueIndex, -1);
              } else {
                _playTrack(newQueueIndex, playImmediately: true);
              }
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

        bool shouldIncrement = false;
        if (_playCountThreshold == -1) {
          if (effectiveDuration > Duration.zero) {
            shouldIncrement =
                pos >= effectiveDuration - const Duration(milliseconds: 500);
          }
        } else {
          shouldIncrement = pos.inSeconds >= _playCountThreshold;
          if (!shouldIncrement && effectiveDuration > Duration.zero) {
            if (effectiveDuration.inSeconds < _playCountThreshold &&
                pos >= effectiveDuration - const Duration(milliseconds: 500)) {
              shouldIncrement = true;
            }
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

      final currentSource = _audioPlayer.sequenceState.currentSource;
      final mediaItem = currentSource?.tag as MediaItem?;
      final activeTrackId = mediaItem?.id;

      if (activeTrackId != null && pos.inMilliseconds < 1000) {
        _lastCrossfadedTrackId = null;
      }

      bool hasNextTrack = false;
      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
        hasNextTrack =
            currentShuffledPos + 1 < _shuffledIndices.length ||
            _repeatMode == 1;
      } else {
        hasNextTrack =
            _currentIndex + 1 < _playbackQueue.length || _repeatMode == 1;
      }

      if (_crossfadeDuration > 0 &&
          _audioPlayer.playing &&
          !_isNaturalFadingOut &&
          _repeatMode != 2 &&
          activeTrackId != null &&
          hasNextTrack &&
          _lastCrossfadedTrackId != activeTrackId) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        if (duration > Duration.zero) {
          final remaining = duration - pos;
          if (remaining.inMilliseconds <= _crossfadeDuration &&
              remaining.inMilliseconds > 0) {
            _isNaturalFadingOut = true;
            _lastCrossfadedTrackId = activeTrackId;
            Future.delayed(Duration.zero, () async {
              final int sessionId = ++_fadeSessionId;
              final int steps = 10;
              final int stepDelay = (_crossfadeDuration / steps).round();
              for (int i = steps; i >= 0; i--) {
                if (_fadeSessionId != sessionId || !_audioPlayer.playing) break;
                await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
                if (stepDelay > 0) {
                  await Future.delayed(Duration(milliseconds: stepDelay));
                }
              }
            });
          }
        }
      }
    });

    _audioPlayer.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null && sessionId != 0) {
        _applySavedEqualizerSettings(sessionId);
      }
    });
  }

  Future<void> _applySavedEqualizerSettings(int sessionId) async {
    if (sessionId == 0) return;
    try {
      const channel = MethodChannel('com.tunza.audio/equalizer');
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('saved_eq_enabled') ?? false;
      if (enabled) {
        final res = await channel.invokeMapMethod<String, dynamic>(
          'initEqualizer',
          {'audioSessionId': sessionId},
        );
        if (res != null) {
          final savedLevelsStr = prefs.getString('saved_eq_levels');
          if (savedLevelsStr != null) {
            final levels = List<int>.from(jsonDecode(savedLevelsStr));
            for (int i = 0; i < levels.length; i++) {
              if (i < (res['bands'] as int)) {
                await channel.invokeMethod('setBandLevel', {
                  'band': i,
                  'level': levels[i],
                });
              }
            }
          }
          await channel.invokeMethod('setEqualizerEnabled', {'enable': true});
        }
      }
    } catch (_) {}
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
    setState(() {
      _animatedTrackIds.clear();
      _animatedPlaylistIds.clear();
      _animatedArtistIds.clear();
      _animatedAlbumIds.clear();
      _animatedDetailTrackIds.clear();
    });
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
            _dominantColorNotifier.value = _dominantColor != null
                ? _ensureLuminance(_dominantColor!)
                : null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dominantColor = null;
            _dominantColorNotifier.value = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = null;
          _dominantColorNotifier.value = null;
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
      _isNaturalFadingOut = false;
      _lastActiveLyricsIndex = -1;
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

    _loadLyricsForTrack(track);

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

        int prevIndex = -1;
        int nextIndex = -1;

        if (_isShuffle && _shuffledIndices.isNotEmpty) {
          int currentShuffledPos = _shuffledIndices.indexOf(index);
          if (currentShuffledPos > 0) {
            prevIndex = _shuffledIndices[currentShuffledPos - 1];
          } else if (_repeatMode == 1) {
            prevIndex = _shuffledIndices.last;
          }
          if (currentShuffledPos != -1 &&
              currentShuffledPos < _shuffledIndices.length - 1) {
            nextIndex = _shuffledIndices[currentShuffledPos + 1];
          } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
            nextIndex = _shuffledIndices.first;
          }
        } else {
          if (index > 0) {
            prevIndex = index - 1;
          } else if (_repeatMode == 1) {
            prevIndex = _playbackQueue.length - 1;
          }
          if (index < _playbackQueue.length - 1) {
            nextIndex = index + 1;
          } else if (_repeatMode == 1) {
            nextIndex = 0;
          }
        }

        // Previous track
        if (prevIndex != -1) {
          final prevTrack = _playbackQueue[prevIndex];
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
        if (nextIndex != -1) {
          final nextTrack = _playbackQueue[nextIndex];
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

      if (_audioPlayer.playing && _crossfadeDuration > 0) {
        // Smooth fade out
        final int steps = 10;
        final int stepDelay = (_crossfadeDuration / steps).round();
        for (int i = steps; i >= 0; i--) {
          if (_fadeSessionId != sessionId) return;
          await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
          if (stepDelay > 0) {
            await Future.delayed(Duration(milliseconds: stepDelay));
          }
        }
      }

      if (_fadeSessionId != sessionId) return;
      await _audioPlayer.setAudioSource(source, initialIndex: initialIndex);

      if (_fadeSessionId != sessionId) return;

      if (playImmediately) {
        await _audioPlayer.setVolume(0.0);
        _audioPlayer.play();
        if (_crossfadeDuration > 0) {
          // Smooth fade in
          final int steps = 10;
          final int stepDelay = (_crossfadeDuration / steps).round();
          for (int i = 1; i <= steps; i++) {
            if (_fadeSessionId != sessionId) return;
            await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
            if (stepDelay > 0) {
              await Future.delayed(Duration(milliseconds: stepDelay));
            }
          }
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

  Future<void> _refreshAudioSourceWindow() async {
    if (_playbackQueue.isEmpty || _playingTrack == null) return;
    if (_playbackQueue.length <= 1) return;
    if (_audioPlayer.audioSource is! ConcatenatingAudioSource) return;

    _isProgrammaticLoading = true;
    try {
      final concatenating =
          _audioPlayer.audioSource as ConcatenatingAudioSource;
      final index = _currentIndex;

      int prevIndex = -1;
      int nextIndex = -1;

      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        int currentShuffledPos = _shuffledIndices.indexOf(index);
        if (currentShuffledPos > 0) {
          prevIndex = _shuffledIndices[currentShuffledPos - 1];
        } else if (_repeatMode == 1) {
          prevIndex = _shuffledIndices.last;
        }
        if (currentShuffledPos != -1 &&
            currentShuffledPos < _shuffledIndices.length - 1) {
          nextIndex = _shuffledIndices[currentShuffledPos + 1];
        } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
          nextIndex = _shuffledIndices.first;
        }
      } else {
        if (index > 0) {
          prevIndex = index - 1;
        } else if (_repeatMode == 1) {
          prevIndex = _playbackQueue.length - 1;
        }
        if (index < _playbackQueue.length - 1) {
          nextIndex = index + 1;
        } else if (_repeatMode == 1) {
          nextIndex = 0;
        }
      }

      int playerCurrentIndex = _audioPlayer.currentIndex ?? 0;
      while (playerCurrentIndex > 0) {
        await concatenating.removeAt(0);
        playerCurrentIndex--;
      }
      while (concatenating.length > 1) {
        await concatenating.removeAt(1);
      }

      // Now insert the new adjacent tracks
      if (prevIndex != -1) {
        final prevTrack = _playbackQueue[prevIndex];
        final prevUri = prevTrack.url.startsWith('/')
            ? Uri.file(prevTrack.url)
            : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
        final prevCover = await _getCoverUriForTrack(prevTrack);
        await concatenating.insert(
          0,
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
      }

      if (nextIndex != -1) {
        final nextTrack = _playbackQueue[nextIndex];
        final nextUri = nextTrack.url.startsWith('/')
            ? Uri.file(nextTrack.url)
            : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
        final nextCover = await _getCoverUriForTrack(nextTrack);
        await concatenating.add(
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
    } finally {
      _isProgrammaticLoading = false;
    }
  }

  Future<void> _slideWindowInPlace(int newQueueIndex, int direction) async {
    _isProgrammaticLoading = true;
    try {
      final track = _playbackQueue[newQueueIndex];
      setState(() {
        _currentIndex = newQueueIndex;
        _playingTrack = track;
        _lastIncrementedTrackId = null;
        _isNaturalFadingOut = false; // Reset the natural fade variable
        _lastActiveLyricsIndex = -1;
      });
      _loadLyricsForTrack(track);
      _updateDominantColor(track);

      if (_crossfadeDuration > 0) {
        final int sessionId = ++_fadeSessionId;
        final int steps = 10;
        final int stepDelay = (_crossfadeDuration / steps).round();
        Future.delayed(Duration.zero, () async {
          await _audioPlayer.setVolume(0.0);
          for (int i = 1; i <= steps; i++) {
            if (_fadeSessionId != sessionId) return;
            await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
            if (stepDelay > 0) {
              await Future.delayed(Duration(milliseconds: stepDelay));
            }
          }
          if (_fadeSessionId == sessionId) {
            await _audioPlayer.setVolume(_volume);
          }
        });
      } else {
        await _audioPlayer.setVolume(_volume);
      }

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_playing_track_id', track.id);
        _lastPlayedTrackIds.remove(track.id);
        _lastPlayedTrackIds.insert(0, track.id);
        if (_lastPlayedTrackIds.length > 100) _lastPlayedTrackIds.removeLast();
        prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      });

      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        int prevIndex = -1;
        int nextIndex = -1;

        if (_isShuffle && _shuffledIndices.isNotEmpty) {
          int currentShuffledPos = _shuffledIndices.indexOf(newQueueIndex);
          if (currentShuffledPos > 0) {
            prevIndex = _shuffledIndices[currentShuffledPos - 1];
          } else if (_repeatMode == 1) {
            prevIndex = _shuffledIndices.last;
          }
          if (currentShuffledPos != -1 &&
              currentShuffledPos < _shuffledIndices.length - 1) {
            nextIndex = _shuffledIndices[currentShuffledPos + 1];
          } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
            nextIndex = _shuffledIndices.first;
          }
        } else {
          if (newQueueIndex > 0) {
            prevIndex = newQueueIndex - 1;
          } else if (_repeatMode == 1) {
            prevIndex = _playbackQueue.length - 1;
          }
          if (newQueueIndex < _playbackQueue.length - 1) {
            nextIndex = newQueueIndex + 1;
          } else if (_repeatMode == 1) {
            nextIndex = 0;
          }
        }

        if (direction > 0) {
          // Slide forward: remove index 0, add new next at end
          if (concatenating.sequence.isNotEmpty) {
            await concatenating.removeAt(0);
          }
          if (nextIndex != -1) {
            final nextTrack = _playbackQueue[nextIndex];
            final nextUri = nextTrack.url.startsWith('/')
                ? Uri.file(nextTrack.url)
                : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
            final nextCover = await _getCoverUriForTrack(nextTrack);
            await concatenating.add(
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
        } else if (direction < 0) {
          // Slide backward: remove last index, insert new prev at index 0
          if (concatenating.sequence.length > 1) {
            await concatenating.removeAt(concatenating.sequence.length - 1);
          }
          if (prevIndex != -1) {
            final prevTrack = _playbackQueue[prevIndex];
            final prevUri = prevTrack.url.startsWith('/')
                ? Uri.file(prevTrack.url)
                : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
            final prevCover = await _getCoverUriForTrack(prevTrack);
            await concatenating.insert(
              0,
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
          }
        }
      }
    } catch (_) {
      // Fallback if mutation fails
      _playTrack(newQueueIndex, playImmediately: true);
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

  List<LyricsLine> _parseLrc(String lrcContent) {
    final List<LyricsLine> lines = [];
    final RegExp regExp = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\](.*)');
    for (final line in lrcContent.split('\n')) {
      final match = regExp.firstMatch(line.trim());
      if (match != null) {
        final int minutes = int.parse(match.group(1)!);
        final int seconds = int.parse(match.group(2)!);
        final int milliseconds = match.group(3) != null
            ? int.parse(match.group(3)!.padRight(3, '0').substring(0, 3))
            : 0;
        final String text = match.group(4)?.trim() ?? '';
        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        lines.add(LyricsLine(time: duration, text: text));
      }
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return lines;
  }

  Future<void> _loadLyricsForTrack(Track track) async {
    if (_lyricsScrollController.hasClients) {
      _lyricsScrollController.jumpTo(0);
    }
    _lastActiveLyricsIndex = -1;
    setState(() {
      _isLyricsLoading = true;
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final manualKey = 'lyrics_manual_${track.id}';

    if (prefs.containsKey(manualKey)) {
      final manualText = prefs.getString(manualKey) ?? '';
      _parsePlainOrLrcLyrics(manualText);
      setState(() {
        _isLyricsLoading = false;
      });
      return;
    }

    final cacheKey = 'lyrics_cache_${track.id}';
    if (prefs.containsKey(cacheKey)) {
      final cachedJson = prefs.getString(cacheKey) ?? '';
      try {
        final data = jsonDecode(cachedJson);
        _applyFetchedLyrics(data);
        setState(() {
          _isLyricsLoading = false;
        });
        return;
      } catch (_) {}
    }

    try {
      final cleanTitle = track.title;
      final cleanArtist = track.artist.trim().isEmpty
          ? 'Unknown Artist'
          : track.artist;

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse('https://lrclib.net/api/get').replace(
        queryParameters: {'artist_name': cleanArtist, 'track_name': cleanTitle},
      );

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);

        await prefs.setString(cacheKey, body);
        _applyFetchedLyrics(data);
      } else {
        _currentLyricsPlain = null;
        _currentLyricsSynced = [];
        _isLyricsSynced = false;
      }
    } catch (_) {
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLyricsLoading = false;
        });
      }
    }
  }

  void _applyFetchedLyrics(dynamic data) {
    final synced = data['syncedLyrics'] as String?;
    final plain = data['plainLyrics'] as String?;

    if (synced != null && synced.trim().isNotEmpty) {
      _currentLyricsSynced = _parseLrc(synced);
      _currentLyricsPlain = plain ?? _stripLrcTimestamps(synced);
      _isLyricsSynced = _currentLyricsSynced.isNotEmpty;
    } else if (plain != null && plain.trim().isNotEmpty) {
      _currentLyricsPlain = plain;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    } else {
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    }
  }

  void _parsePlainOrLrcLyrics(String text) {
    if (text.contains(RegExp(r'\[\d+:\d+'))) {
      _currentLyricsSynced = _parseLrc(text);
      _currentLyricsPlain = _stripLrcTimestamps(text);
      _isLyricsSynced = _currentLyricsSynced.isNotEmpty;
    } else {
      _currentLyricsPlain = text;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    }
  }

  String _stripLrcTimestamps(String text) {
    return text.replaceAll(RegExp(r'\[\d+:\d+(?:\.\d+)?\]'), '').trim();
  }

  bool _isFading = false;

  Future<void> _pauseWithFade() async {
    if (_isFading || !_isPlaying) return;
    _isFading = true;
    final currentVol = _volume;
    if (_crossfadeDuration > 0) {
      final int steps = 10;
      final int stepDelay = (_crossfadeDuration / steps).round();
      for (int i = steps; i >= 0; i--) {
        if (!mounted) break;
        await _audioPlayer.setVolume(currentVol * (i / steps.toDouble()));
        if (stepDelay > 0) {
          await Future.delayed(Duration(milliseconds: stepDelay));
        }
      }
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
    if (_crossfadeDuration > 0) {
      final int steps = 10;
      final int stepDelay = (_crossfadeDuration / steps).round();
      for (int i = 0; i <= steps; i++) {
        if (!mounted) break;
        await _audioPlayer.setVolume(currentVol * (i / steps.toDouble()));
        if (stepDelay > 0) {
          await Future.delayed(Duration(milliseconds: stepDelay));
        }
      }
    }
    await _audioPlayer.setVolume(currentVol);
    _isFading = false;
  }

  Future<void> _smoothSeek(Duration position) async {
    final double originalVolume = _volume;
    final int steps = 5;
    final int stepDelay = 15; // Total fade out = 75ms

    try {
      for (int i = steps; i >= 0; i--) {
        if (!mounted) break;
        await _audioPlayer.setVolume(originalVolume * (i / steps.toDouble()));
        await Future.delayed(Duration(milliseconds: stepDelay));
      }

      await _audioPlayer.seek(position);

      for (int i = 0; i <= steps; i++) {
        if (!mounted) break;
        await _audioPlayer.setVolume(originalVolume * (i / steps.toDouble()));
        await Future.delayed(Duration(milliseconds: stepDelay));
      }
    } catch (_) {
      await _audioPlayer.seek(position);
      await _audioPlayer.setVolume(originalVolume);
    }
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
    Color? iconColor,
  }) {
    final isLight = isAppLight;
    final resolvedIconColor =
        iconColor ?? (isLight ? Colors.black54 : Colors.white70);
    return ListTile(
      leading: Icon(icon, color: resolvedIconColor),
      title: Text(
        title,
        style: TextStyle(
          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          fontSize: 16,
          fontFamily: _activeFont,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      if (!_audioPlayer.playing) {
        _audioPlayer.stop();
        audioHandler.stop();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _batteryCheckTimer?.cancel();
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
        canPop: !_isPlayerOpen && !isDetailView,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isPlayerOpen) {
            setState(() {
              _isPlayerOpen = false;
              _showLyrics = false;
            });
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
              ValueListenableBuilder<String>(
                valueListenable: themeModeNotifier,
                builder: (context, themeMode, child) {
                  return ValueListenableBuilder<String>(
                    valueListenable: customThemeBgNotifier,
                    builder: (context, customBg, child) {
                      if (themeMode == 'custom' && customBg == 'custom_image') {
                        return ValueListenableBuilder<String?>(
                          valueListenable: customThemeBgPathNotifier,
                          builder: (context, customPath, child) {
                            if (customPath != null &&
                                File(customPath).existsSync()) {
                              return ValueListenableBuilder<double>(
                                valueListenable: customThemeBgBlurNotifier,
                                builder: (context, blurVal, child) {
                                  return ValueListenableBuilder<double>(
                                    valueListenable: customThemeBgDimNotifier,
                                    builder: (context, dimVal, child) {
                                      return AnimatedBuilder(
                                        animation: Listenable.merge([
                                          customThemeBgScaleNotifier,
                                          customThemeBgOffsetXNotifier,
                                          customThemeBgOffsetYNotifier,
                                        ]),
                                        builder: (context, child) {
                                          return Positioned.fill(
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRect(
                                                    child: ImageFiltered(
                                                      imageFilter:
                                                          ImageFilter.blur(
                                                            sigmaX: blurVal,
                                                            sigmaY: blurVal,
                                                          ),
                                                      child: Transform.scale(
                                                        scale:
                                                            customThemeBgScaleNotifier
                                                                .value,
                                                        alignment: Alignment(
                                                          customThemeBgOffsetXNotifier
                                                              .value,
                                                          customThemeBgOffsetYNotifier
                                                              .value,
                                                        ),
                                                        child: Image.file(
                                                          File(customPath),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Container(
                                                    color: Colors.black
                                                        .withOpacity(dimVal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }
                            return Positioned.fill(
                              child: Container(color: const Color(0xFF0F0F15)),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
              SafeArea(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: _activeAccentColor,
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
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _detailDragOffsetNotifier,
                    _isDraggingDetailNotifier,
                  ]),
                  child: _getActiveDetailView(),
                  builder: (context, child) {
                    final isDragging = _isDraggingDetailNotifier.value;
                    final dragOffset = _detailDragOffsetNotifier.value;

                    if (!isDetailView && dragOffset != 0.0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _detailDragOffsetNotifier.value = 0.0;
                      });
                    }

                    return AnimatedSlide(
                      duration: isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 380),
                      curve: Curves.easeOutQuint,
                      offset: isDetailView
                          ? Offset(0, dragOffset)
                          : const Offset(0, 1),
                      child: child!,
                    );
                  },
                ),
              ),

              if (_playingTrack != null) _buildMiniPlayer(_playingTrack!),

              Positioned.fill(
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _playerDragOffsetNotifier,
                    _isDraggingPlayerNotifier,
                  ]),
                  child: _playingTrack != null
                      ? _buildFullScreenPlayer(_playingTrack!)
                      : const SizedBox.shrink(),
                  builder: (context, child) {
                    final isDragging = _isDraggingPlayerNotifier.value;
                    final dragOffset = _playerDragOffsetNotifier.value;

                    return AnimatedSlide(
                      duration: isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 380),
                      curve: Curves.easeOutQuint,
                      offset: _isPlayerOpen
                          ? Offset(0, dragOffset)
                          : const Offset(0, 1),
                      child: child!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isLight = isAppLight;
    final headerTextColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;

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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: headerTextColor,
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: headerTextColor),
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
                      playCountThreshold: _playCountThreshold,
                      onSetPlayCountThreshold: (seconds) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('playCountThreshold', seconds);
                        setState(() {
                          _playCountThreshold = seconds;
                        });
                      },
                      activeFont: _activeFont,
                      onSetFont: (fontName) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('activeFont', fontName);
                        setState(() {
                          _activeFont = fontName;
                        });
                        activeFontNotifier.value = fontName;
                      },
                      fontScale: _fontScale,
                      onSetFontScale: (scale) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('fontScale', scale);
                        setState(() {
                          _fontScale = scale;
                        });
                        fontScaleNotifier.value = scale;
                      },
                      themeAccentPreset: _themeAccentPreset,
                      activeAccentColor: _activeAccentColor,
                      dominantColorNotifier: _dominantColorNotifier,
                      onSetThemeAccent: (preset) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('themeAccentPreset', preset);
                        setState(() {
                          _themeAccentPreset = preset;
                        });
                      },
                      playerBackgroundStyle: _playerBackgroundStyle,
                      playerBackgroundStyleNotifier:
                          _playerBackgroundStyleNotifier,
                      onSetPlayerBackgroundStyle: (style) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('playerBackgroundStyle', style);
                        setState(() {
                          _playerBackgroundStyle = style;
                        });
                        _playerBackgroundStyleNotifier.value = style;
                      },
                      playerCustomBgPath: _playerCustomBgPath,
                      playerCustomBgPathNotifier: _playerCustomBgPathNotifier,
                      onSetPlayerCustomBgPath: (path) async {
                        final prefs = await SharedPreferences.getInstance();
                        if (path != null) {
                          await prefs.setString('playerCustomBgPath', path);
                        } else {
                          await prefs.remove('playerCustomBgPath');
                        }
                        setState(() {
                          _playerCustomBgPath = path;
                        });
                        _playerCustomBgPathNotifier.value = path;
                      },
                      playerCustomBgBlur: _playerCustomBgBlur,
                      playerCustomBgBlurNotifier: _playerCustomBgBlurNotifier,
                      onSetPlayerCustomBgBlur: (blur) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('playerCustomBgBlur', blur);
                        setState(() {
                          _playerCustomBgBlur = blur;
                        });
                        _playerCustomBgBlurNotifier.value = blur;
                      },
                      playerCustomBgDim: _playerCustomBgDim,
                      playerCustomBgDimNotifier: _playerCustomBgDimNotifier,
                      onSetPlayerCustomBgDim: (dim) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('playerCustomBgDim', dim);
                        setState(() {
                          _playerCustomBgDim = dim;
                        });
                        _playerCustomBgDimNotifier.value = dim;
                      },
                      playerCustomBgScale: _playerCustomBgScale,
                      playerCustomBgScaleNotifier: _playerCustomBgScaleNotifier,
                      onSetPlayerCustomBgScale: (scale) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('playerCustomBgScale', scale);
                        setState(() {
                          _playerCustomBgScale = scale;
                        });
                        _playerCustomBgScaleNotifier.value = scale;
                      },
                      themeMode: _themeMode,
                      onSetThemeMode: (mode) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('themeMode', mode);
                        setState(() {
                          _themeMode = mode;
                        });
                        themeModeNotifier.value = mode;
                      },
                      customThemeBg: _customThemeBg,
                      customThemeBgNotifier: customThemeBgNotifier,
                      onSetCustomThemeBg: (customBg) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('customThemeBg', customBg);
                        setState(() {
                          _customThemeBg = customBg;
                        });
                        customThemeBgNotifier.value = customBg;
                      },
                      customThemeBgPath: _customThemeBgPath,
                      customThemeBgPathNotifier: _customThemeBgPathNotifier,
                      onSetCustomThemeBgPath: (path) async {
                        final prefs = await SharedPreferences.getInstance();
                        if (path != null) {
                          await prefs.setString('customThemeBgPath', path);
                        } else {
                          await prefs.remove('customThemeBgPath');
                        }
                        setState(() {
                          _customThemeBgPath = path;
                        });
                        _customThemeBgPathNotifier.value = path;
                      },
                      customThemeBgBlur: _customThemeBgBlur,
                      customThemeBgBlurNotifier: _customThemeBgBlurNotifier,
                      onSetCustomThemeBgBlur: (blur) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('customThemeBgBlur', blur);
                        setState(() {
                          _customThemeBgBlur = blur;
                        });
                        _customThemeBgBlurNotifier.value = blur;
                      },
                      customThemeBgDim: _customThemeBgDim,
                      customThemeBgDimNotifier: _customThemeBgDimNotifier,
                      onSetCustomThemeBgDim: (dim) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('customThemeBgDim', dim);
                        setState(() {
                          _customThemeBgDim = dim;
                        });
                        _customThemeBgDimNotifier.value = dim;
                      },
                      customThemeBgScale: _customThemeBgScale,
                      customThemeBgScaleNotifier: _customThemeBgScaleNotifier,
                      onSetCustomThemeBgScale: (scale) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('customThemeBgScale', scale);
                        setState(() {
                          _customThemeBgScale = scale;
                        });
                        _customThemeBgScaleNotifier.value = scale;
                      },
                      customThemeStyle: _customThemeStyle,
                      customThemeStyleNotifier: _customThemeStyleNotifier,
                      onSetCustomThemeStyle: (style) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('customThemeStyle', style);
                        setState(() {
                          _customThemeStyle = style;
                        });
                        _customThemeStyleNotifier.value = style;
                      },
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
      contentPadding: const EdgeInsets.only(
        left: 8,
        right: 0,
        top: 8,
        bottom: 8,
      ),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isAppLight ? const Color(0xFF1A1A1A) : Colors.white,
        ),
      ),
      subtitle: Text(
        '${songs.length} songs',
        style: TextStyle(
          fontSize: 13,
          color: isAppLight ? Colors.black54 : Colors.white54,
        ),
      ),
      trailing: Transform.translate(
        offset: const Offset(12, 0),
        child: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: isAppLight ? Colors.black26 : Colors.white24,
            size: 20,
          ),
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
                    Icon(Icons.shuffle, color: _activeAccentColor, size: 18),
                  if (_isShuffle) const SizedBox(width: 8),
                  if (_repeatMode != 0)
                    Icon(
                      _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                      color: _activeAccentColor,
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
                                color: _activeAccentColor,
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
                        color: isCurrent ? _activeAccentColor : Colors.white,
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

class LyricsLine {
  final Duration time;
  final String text;

  LyricsLine({required this.time, required this.text});
}
