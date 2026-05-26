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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/track.dart';
import 'models/lyrics_line.dart';
import 'widgets/custom_track_shape.dart';

import 'screens/settings_screen.dart';
import 'utils/globals.dart';
part 'ui/player_ui.dart';
part 'ui/detail_views_ui.dart';
part 'ui/tabs_ui.dart';
part 'ui/modals_track_ui.dart';
part 'ui/modals_playlist_ui.dart';
part 'ui/modals_utility_ui.dart';
part 'services/audio_handler.dart';
part 'ui/main_ui_components.dart';
part 'logic/main_audio_logic.dart';

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
        androidNotificationChannelId: 'com.flow.music.channel.audio.v6',
        androidNotificationChannelName: 'Flow Audio Player',
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

  runApp(const FlowApp());
}

class FlowApp extends StatelessWidget {
  const FlowApp({super.key});

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
                              title: 'Flow',
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
        showFlowToast("Please play a song first to use the Equalizer!");
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
  bool _isFading = false;
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
          showFlowToast("Headphones unplugged. Paused.");
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
}
