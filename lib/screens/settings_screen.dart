// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../utils/globals.dart';

part 'settings_ui_components.dart';
part 'settings_modals.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onRescanLibrary;
  final Function(int) onSetSleepTimer;
  final VoidCallback onResetData;
  final ValueNotifier<int> sleepTimerNotifier;
  final VoidCallback onManageFolders;
  final int playCountThreshold;
  final Function(int) onSetPlayCountThreshold;
  final String activeFont;
  final Function(String) onSetFont;
  final double fontScale;
  final Function(double) onSetFontScale;
  final String themeAccentPreset;
  final Function(String) onSetThemeAccent;
  final Color activeAccentColor;
  final ValueNotifier<Color?> dominantColorNotifier;
  final String playerBackgroundStyle;
  final ValueNotifier<String> playerBackgroundStyleNotifier;
  final Function(String) onSetPlayerBackgroundStyle;
  final String? playerCustomBgPath;
  final ValueNotifier<String?> playerCustomBgPathNotifier;
  final Function(String?) onSetPlayerCustomBgPath;
  final double playerCustomBgBlur;
  final ValueNotifier<double> playerCustomBgBlurNotifier;
  final Function(double) onSetPlayerCustomBgBlur;
  final double playerCustomBgDim;
  final ValueNotifier<double> playerCustomBgDimNotifier;
  final Function(double) onSetPlayerCustomBgDim;
  final double playerCustomBgScale;
  final ValueNotifier<double> playerCustomBgScaleNotifier;
  final Function(double) onSetPlayerCustomBgScale;
  final String themeMode;
  final Function(String) onSetThemeMode;
  final String customThemeBg;
  final ValueNotifier<String> customThemeBgNotifier;
  final Function(String) onSetCustomThemeBg;
  final String? customThemeBgPath;
  final ValueNotifier<String?> customThemeBgPathNotifier;
  final Function(String?) onSetCustomThemeBgPath;
  final double customThemeBgBlur;
  final ValueNotifier<double> customThemeBgBlurNotifier;
  final Function(double) onSetCustomThemeBgBlur;
  final double customThemeBgDim;
  final ValueNotifier<double> customThemeBgDimNotifier;
  final Function(double) onSetCustomThemeBgDim;
  final double customThemeBgScale;
  final ValueNotifier<double> customThemeBgScaleNotifier;
  final Function(double) onSetCustomThemeBgScale;
  final String customThemeStyle;
  final ValueNotifier<String> customThemeStyleNotifier;
  final Function(String) onSetCustomThemeStyle;

  const SettingsScreen({
    super.key,
    required this.onRescanLibrary,
    required this.onSetSleepTimer,
    required this.onResetData,
    required this.sleepTimerNotifier,
    required this.onManageFolders,
    required this.playCountThreshold,
    required this.onSetPlayCountThreshold,
    required this.activeFont,
    required this.onSetFont,
    required this.fontScale,
    required this.onSetFontScale,
    required this.themeAccentPreset,
    required this.onSetThemeAccent,
    required this.activeAccentColor,
    required this.dominantColorNotifier,
    required this.playerBackgroundStyle,
    required this.playerBackgroundStyleNotifier,
    required this.onSetPlayerBackgroundStyle,
    required this.playerCustomBgPath,
    required this.playerCustomBgPathNotifier,
    required this.onSetPlayerCustomBgPath,
    required this.playerCustomBgBlur,
    required this.playerCustomBgBlurNotifier,
    required this.onSetPlayerCustomBgBlur,
    required this.playerCustomBgDim,
    required this.playerCustomBgDimNotifier,
    required this.onSetPlayerCustomBgDim,
    required this.playerCustomBgScale,
    required this.playerCustomBgScaleNotifier,
    required this.onSetPlayerCustomBgScale,
    required this.themeMode,
    required this.onSetThemeMode,
    required this.customThemeBg,
    required this.customThemeBgNotifier,
    required this.onSetCustomThemeBg,
    required this.customThemeBgPath,
    required this.customThemeBgPathNotifier,
    required this.onSetCustomThemeBgPath,
    required this.customThemeBgBlur,
    required this.customThemeBgBlurNotifier,
    required this.onSetCustomThemeBgBlur,
    required this.customThemeBgDim,
    required this.customThemeBgDimNotifier,
    required this.onSetCustomThemeBgDim,
    required this.customThemeBgScale,
    required this.customThemeBgScaleNotifier,
    required this.onSetCustomThemeBgScale,
    required this.customThemeStyle,
    required this.customThemeStyleNotifier,
    required this.onSetCustomThemeStyle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _filterShortAudio = false;
  bool _autoRegexClean = false;
  int _crossfadeDuration = 200;
  bool _pauseOnDisconnect = true;
  bool _autoPlayAfterCall = true;
  bool _playTogether = false;
  int _playCountThreshold = 10;
  String _activeFont = 'Plus Jakarta Sans';
  double _fontScale = 1.0;
  bool _skipSilence = false;
  bool _stopOnLowBattery = false;
  bool _monoAudio = false;
  List<String> _hiddenTrackIds = [];
  String _selectedThemeAccent = 'spotify';
  String _selectedThemeMode = 'dark';
  String _customThemeBg = 'dynamic';
  String? _customThemeBgPath;
  double _customThemeBgBlur = 25.0;
  double _customThemeBgDim = 0.65;
  double _customThemeBgScale = 1.0;
  double _customThemeBgOffsetX = 0.0;
  double _customThemeBgOffsetY = 0.0;
  String _customThemeStyle = 'dark';
  String _playerBackgroundStyle = 'gradient';
  String? _playerCustomBgPath;
  double _playerCustomBgBlur = 0.0;
  double _playerCustomBgDim = 0.4;
  double _playerCustomBgScale = 1.0;
  double _playerCustomBgOffsetX = 0.0;
  double _playerCustomBgOffsetY = 0.0;
  Future<List<SongModel>>? _songsFuture;

  Color get _activeAccentColor {
    if (_selectedThemeAccent == 'dynamic') {
      return widget.dominantColorNotifier.value ?? const Color(0xFF8E8E93);
    }
    switch (_selectedThemeAccent) {
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
    widget.dominantColorNotifier.addListener(_onDominantColorChanged);
  }

  @override
  void dispose() {
    widget.dominantColorNotifier.removeListener(_onDominantColorChanged);
    super.dispose();
  }

  void _onDominantColorChanged() {
    if (mounted && _selectedThemeAccent == 'dynamic') {
      setState(() {});
    }
  }

  Future<void> _checkForUpdates() async {
    showFlowToast("Checking for updates...");
    try {
      final client = HttpClient();
      client.userAgent = 'Flow-App';
      final request = await client.getUrl(
        Uri.parse('https://api.github.com/repos/coflyn/Flow/releases/latest'),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final String latestVersionTag = json['tag_name'] ?? 'v1.0.0';
        final String htmlUrl =
            json['html_url'] ?? 'https://github.com/coflyn/Flow/releases';

        final latestVersion = latestVersionTag.replaceAll('v', '').trim();
        const currentVersion = '1.0.0';

        if (latestVersion != currentVersion) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.system_update_rounded,
                      color: _activeAccentColor,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Update Available!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A new version of Flow is available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current Version: v$currentVersion\nLatest Version: $latestVersionTag',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Later',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(htmlUrl);
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {
                        showFlowToast("Could not open update page");
                      }
                    },
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: _activeAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          showFlowToast("Flow is up to date! (v$currentVersion)");
        }
      } else {
        showFlowToast("Unable to check for updates");
      }
    } catch (_) {
      showFlowToast("Network error checking for updates");
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool monoAudio = prefs.getBool('monoAudio') ?? false;
    if (monoAudio) {
      try {
        const channel = MethodChannel('com.flow.audio/equalizer');
        final hasPermission =
            await channel.invokeMethod<bool>('checkWriteSettingsPermission') ??
            false;
        if (!hasPermission) {
          monoAudio = false;
          await prefs.setBool('monoAudio', false);
        } else {
          final systemMono =
              await channel.invokeMethod<bool>('getMonoAudioStatus') ?? false;
          if (!systemMono) {
            await channel.invokeMethod('toggleMonoAudio', {'enable': true});
          }
        }
      } catch (_) {
        monoAudio = false;
        await prefs.setBool('monoAudio', false);
      }
    }

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
      _skipSilence = prefs.getBool('skipSilence') ?? false;
      _stopOnLowBattery = prefs.getBool('stopOnLowBattery') ?? false;
      _monoAudio = monoAudio;
      _hiddenTrackIds = prefs.getStringList('hidden_track_ids') ?? [];
      _selectedThemeAccent = prefs.getString('themeAccentPreset') ?? 'spotify';
      _selectedThemeMode = prefs.getString('themeMode') ?? 'dark';
      _customThemeBg = prefs.getString('customThemeBg') ?? 'dynamic';
      _customThemeBgPath = prefs.getString('customThemeBgPath');
      _customThemeBgBlur = prefs.getDouble('customThemeBgBlur') ?? 25.0;
      _customThemeBgDim = prefs.getDouble('customThemeBgDim') ?? 0.65;
      _customThemeBgScale = prefs.getDouble('customThemeBgScale') ?? 1.0;
      _customThemeBgOffsetX = prefs.getDouble('customThemeBgOffsetX') ?? 0.0;
      _customThemeBgOffsetY = prefs.getDouble('customThemeBgOffsetY') ?? 0.0;
      _customThemeStyle = prefs.getString('customThemeStyle') ?? 'dark';
      _playerBackgroundStyle =
          prefs.getString('playerBackgroundStyle') ?? 'gradient';
      _playerCustomBgPath = prefs.getString('playerCustomBgPath');
      _playerCustomBgBlur = prefs.getDouble('playerCustomBgBlur') ?? 0.0;
      _playerCustomBgDim = prefs.getDouble('playerCustomBgDim') ?? 0.4;
      _playerCustomBgScale = prefs.getDouble('playerCustomBgScale') ?? 1.0;
      _playerCustomBgOffsetX = prefs.getDouble('playerCustomBgOffsetX') ?? 0.0;
      _playerCustomBgOffsetY = prefs.getDouble('playerCustomBgOffsetY') ?? 0.0;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    widget.onRescanLibrary(); // Trigger reload
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    widget.onRescanLibrary(); // Trigger reload
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = _selectedThemeMode == 'light';
    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF6F8FA)
          : const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: isLight
            ? const Color(0xFFF6F8FA)
            : const Color(0xFF0A0A0A),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader('App Customization'),
          _buildPremiumCard(
            children: [
              _buildPremiumListTile(
                icon: Icons.font_download_outlined,
                title: 'Typography & Font Size',
                subtitle:
                    '${_activeFont == 'Spotify Style'
                        ? 'Figtree'
                        : _activeFont == 'Apple Music Style'
                        ? 'Inter'
                        : 'Plus Jakarta Sans'} • ${_getFontSizeLabel(_fontScale)}',
                onTap: () => _showTypographyPreviewDialog(),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildPremiumListTile(
                icon: Icons.palette_outlined,
                title: 'Theme Accent Color',
                subtitle: _getThemeAccentLabel(_selectedThemeAccent),
                onTap: () => _showThemeAccentSelectionDialog(),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildPremiumListTile(
                icon: _selectedThemeMode == 'light'
                    ? Icons.light_mode_outlined
                    : _selectedThemeMode == 'custom'
                    ? Icons.color_lens_outlined
                    : Icons.dark_mode_outlined,
                title: 'Theme Mode',
                subtitle: _getThemeModeLabel(_selectedThemeMode),
                onTap: () => _showThemeModeSelectionDialog(),
              ),
              if (_selectedThemeMode == 'custom') ...[
                const Divider(color: Colors.white10, height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: isLight
                      ? Colors.black.withOpacity(0.01)
                      : Colors.white.withValues(alpha: 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOM THEME BACKGROUND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isLight ? Colors.black54 : Colors.white54,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildCustomBgOption(
                              id: 'dynamic',
                              name: 'Dynamic (Artwork)',
                              color:
                                  widget.dominantColorNotifier.value ??
                                  const Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'custom_image',
                              name: 'Custom Image',
                              color: const Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'navy',
                              name: 'Deep Navy',
                              color: const Color(0xFF0B132B),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'forest',
                              name: 'Forest Green',
                              color: const Color(0xFF0D1F1D),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'wine',
                              name: 'Midnight Wine',
                              color: const Color(0xFF1A0F1A),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'terracotta',
                              name: 'Sunset Terracotta',
                              color: const Color(0xFF211510),
                            ),
                            const SizedBox(width: 10),
                            _buildCustomBgOption(
                              id: 'slate',
                              name: 'Slate Gray-Blue',
                              color: const Color(0xFF1C2541),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedThemeMode == 'custom' &&
                  _customThemeBg == 'custom_image') ...[
                const Divider(color: Colors.white10, height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: isLight
                      ? Colors.black.withOpacity(0.01)
                      : Colors.white.withValues(alpha: 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Theme Wallpaper Settings',
                            style: TextStyle(
                              color: _activeAccentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: _activeFont,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: isLight
                                  ? Colors.black54
                                  : Colors.white70,
                            ),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 14,
                            ),
                            label: Text(
                              'Change Photo',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: _activeFont,
                              ),
                            ),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'customThemeBgPath',
                                  image.path,
                                );
                                setState(() {
                                  _customThemeBgPath = image.path;
                                });
                                widget.onSetCustomThemeBgPath(image.path);
                                showFlowToast(
                                  'Custom theme wallpaper updated!',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (_customThemeBgPath != null &&
                          File(_customThemeBgPath!).existsSync()) ...[
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            bool isMockLight = false;
                            if (_customThemeStyle == 'light') {
                              isMockLight = true;
                            } else if (_customThemeStyle == 'dynamic') {
                              final activeCol =
                                  widget.dominantColorNotifier.value ??
                                  const Color(0xFF8E8E93);
                              isMockLight = activeCol.computeLuminance() > 0.45;
                            }
                            return Center(
                              child: Container(
                                width: 140,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: isMockLight
                                      ? Colors.white
                                      : const Color(0xFF0A0A0A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isMockLight
                                        ? Colors.black12
                                        : Colors.white10,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      // Live blurred custom background image preview
                                      Positioned.fill(
                                        child: ClipRect(
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: _customThemeBgBlur / 2.0,
                                              sigmaY: _customThemeBgBlur / 2.0,
                                            ),
                                            child: Transform.scale(
                                              scale: _customThemeBgScale,
                                              alignment: Alignment(
                                                _customThemeBgOffsetX,
                                                _customThemeBgOffsetY,
                                              ),
                                              child: Image.file(
                                                File(_customThemeBgPath!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Theme dimming overlay
                                      Positioned.fill(
                                        child: Container(
                                          color: isMockLight
                                              ? Colors.white.withOpacity(0.15)
                                              : Colors.black.withOpacity(
                                                  _customThemeBgDim,
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Container(
                                              width: 45,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isMockLight
                                                    ? const Color(0xFF1A1A1A)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: isMockLight
                                                    ? Colors.black.withOpacity(
                                                        0.06,
                                                      )
                                                    : Colors.white10,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.search,
                                                    size: 8,
                                                    color: isMockLight
                                                        ? Colors.black38
                                                        : Colors.white38,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    width: 50,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: isMockLight
                                                          ? Colors.black26
                                                          : Colors.white24,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            for (int i = 0; i < 3; i++) ...[
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: _activeAccentColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.music_note,
                                                      size: 9,
                                                      color: _activeAccentColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 38,
                                                        height: 4,
                                                        decoration: BoxDecoration(
                                                          color: isMockLight
                                                              ? const Color(
                                                                  0xFF1A1A1A,
                                                                )
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                1,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Container(
                                                        width: 25,
                                                        height: 3,
                                                        decoration: BoxDecoration(
                                                          color: isMockLight
                                                              ? Colors.black45
                                                              : Colors.white38,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                1,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Overlay Theme Style Selector
                        Text(
                          'Overlay Theme Style',
                          style: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: _activeFont,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildStylePill('dark', 'Dark')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStylePill('light', 'Light')),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStylePill('dynamic', 'Dynamic'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Blur Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Blur Level',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                            Text(
                              '${_customThemeBgBlur.round()}',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _customThemeBgBlur,
                          min: 0.0,
                          max: 60.0,
                          activeColor: _activeAccentColor,
                          inactiveColor: isLight
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white10,
                          onChanged: (val) {
                            setState(() {
                              _customThemeBgBlur = val;
                            });
                            widget.onSetCustomThemeBgBlur(val);
                          },
                        ),
                        // Dim Level (Opacity)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dim Level',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                            Text(
                              '${(_customThemeBgDim * 100).round()}%',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _customThemeBgDim,
                          min: 0.0,
                          max: 0.90,
                          activeColor: _activeAccentColor,
                          inactiveColor: isLight
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white10,
                          onChanged: (val) {
                            setState(() {
                              _customThemeBgDim = val;
                            });
                            widget.onSetCustomThemeBgDim(val);
                          },
                        ),
                        // Zoom Scale
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Zoom Scale',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                            Text(
                              '${_customThemeBgScale.toStringAsFixed(1)}x',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _customThemeBgScale,
                          min: 1.0,
                          max: 3.0,
                          activeColor: _activeAccentColor,
                          inactiveColor: isLight
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white10,
                          onChanged: (val) {
                            setState(() {
                              _customThemeBgScale = val;
                            });
                            widget.onSetCustomThemeBgScale(val);
                          },
                        ),
                        // Pan X
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pan Horizontal (X)',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                            Text(
                              '${(_customThemeBgOffsetX * 100).toInt()}%',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _customThemeBgOffsetX,
                          min: -1.0,
                          max: 1.0,
                          activeColor: _activeAccentColor,
                          inactiveColor: isLight
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white10,
                          onChanged: (val) {
                            setState(() {
                              _customThemeBgOffsetX = val;
                            });
                            _saveDouble('customThemeBgOffsetX', val);
                            customThemeBgOffsetXNotifier.value = val;
                          },
                        ),
                        // Pan Y
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pan Vertical (Y)',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                            Text(
                              '${(_customThemeBgOffsetY * 100).toInt()}%',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _customThemeBgOffsetY,
                          min: -1.0,
                          max: 1.0,
                          activeColor: _activeAccentColor,
                          inactiveColor: isLight
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white10,
                          onChanged: (val) {
                            setState(() {
                              _customThemeBgOffsetY = val;
                            });
                            _saveDouble('customThemeBgOffsetY', val);
                            customThemeBgOffsetYNotifier.value = val;
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No custom wallpaper selected.\nTap "Change Photo" to pick one from gallery!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isLight ? Colors.black54 : Colors.white54,
                              fontSize: 12,
                              fontFamily: _activeFont,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const Divider(color: Colors.white10, height: 1),
              _buildPremiumListTile(
                icon: Icons.wallpaper_outlined,
                title: 'Player Background Style',
                subtitle: _getPlayerBackgroundStyleLabel(
                  _playerBackgroundStyle,
                ),
                onTap: () => _showPlayerBackgroundStyleDialog(),
              ),
              if (_playerBackgroundStyle == 'custom') ...[
                const Divider(color: Colors.white10, height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: Colors.white.withValues(alpha: 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wallpaper Settings',
                            style: TextStyle(
                              color: _activeAccentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: _activeFont,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.white70,
                            ),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 14,
                            ),
                            label: Text(
                              'Change Photo',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: _activeFont,
                              ),
                            ),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'playerCustomBgPath',
                                  image.path,
                                );
                                setState(() {
                                  _playerCustomBgPath = image.path;
                                });
                                widget.onSetPlayerCustomBgPath(image.path);
                                showFlowToast(
                                  'Custom wallpaper background updated!',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (_playerCustomBgPath != null &&
                          File(_playerCustomBgPath!).existsSync()) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 140,
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white10,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                children: [
                                  // Live blurred, scaled custom background image preview
                                  Positioned.fill(
                                    child: ClipRect(
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: _playerCustomBgBlur,
                                          sigmaY: _playerCustomBgBlur,
                                        ),
                                        child: Transform.scale(
                                          scale: _playerCustomBgScale,
                                          alignment: Alignment(
                                            _playerCustomBgOffsetX,
                                            _playerCustomBgOffsetY,
                                          ),
                                          child: Image.file(
                                            File(_playerCustomBgPath!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Real-time custom dimming overlay
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withValues(
                                        alpha: _playerCustomBgDim,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white24,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.music_note,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: 65,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 45,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white54,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.skip_previous,
                                              color: Colors.white70,
                                              size: 10,
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.skip_next,
                                              color: Colors.white70,
                                              size: 10,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Blur Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Blur Level',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${_playerCustomBgBlur.round()}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCustomBgBlur,
                        min: 0.0,
                        max: 60.0,
                        activeColor: _activeAccentColor,
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _playerCustomBgBlur = val;
                          });
                          widget.onSetPlayerCustomBgBlur(val);
                        },
                      ),
                      // Dim Level (Opacity)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dim Level',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${(_playerCustomBgDim * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCustomBgDim,
                        min: 0.0,
                        max: 0.90,
                        activeColor: _activeAccentColor,
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _playerCustomBgDim = val;
                          });
                          widget.onSetPlayerCustomBgDim(val);
                        },
                      ),
                      // Zoom Scale
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Zoom Scale',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${_playerCustomBgScale.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCustomBgScale,
                        min: 1.0,
                        max: 3.0,
                        activeColor: _activeAccentColor,
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _playerCustomBgScale = val;
                          });
                          widget.onSetPlayerCustomBgScale(val);
                        },
                      ),
                      // Pan X
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pan Horizontal (X)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${(_playerCustomBgOffsetX * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCustomBgOffsetX,
                        min: -1.0,
                        max: 1.0,
                        activeColor: _activeAccentColor,
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _playerCustomBgOffsetX = val;
                          });
                          _saveDouble('playerCustomBgOffsetX', val);
                          playerCustomBgOffsetXNotifier.value = val;
                        },
                      ),
                      // Pan Y
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pan Vertical (Y)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${(_playerCustomBgOffsetY * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playerCustomBgOffsetY,
                        min: -1.0,
                        max: 1.0,
                        activeColor: _activeAccentColor,
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _playerCustomBgOffsetY = val;
                          });
                          _saveDouble('playerCustomBgOffsetY', val);
                          playerCustomBgOffsetYNotifier.value = val;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          _buildSectionHeader('Audio & Playback'),
          _buildPremiumCard(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: widget.sleepTimerNotifier,
                builder: (context, remaining, child) {
                  final isActive = remaining > 0;
                  final mins = (remaining / 60).floor().toString().padLeft(
                    2,
                    '0',
                  );
                  final secs = (remaining % 60).toString().padLeft(2, '0');
                  return _buildPremiumListTile(
                    icon: Icons.timer_outlined,
                    title: 'Sleep Timer',
                    subtitle: isActive
                        ? 'Stops in $mins:$secs'
                        : 'Stop audio after a set time',
                    isActive: isActive,
                    trailing: isActive
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                            onPressed: () => widget.onSetSleepTimer(0),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white24,
                          ),
                    onTap: () => _showSleepTimerDialog(),
                  );
                },
              ),
              _buildPremiumListTile(
                icon: Icons.compare_arrows_rounded,
                title: 'Audio Crossfade',
                subtitle: '${_crossfadeDuration}ms',
                trailing: SizedBox(
                  width: 140,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: _crossfadeDuration.toDouble().clamp(200.0, 3000.0),
                      min: 200,
                      max: 3000,
                      divisions: 28,
                      activeColor: _activeAccentColor,
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setState(() {
                          _crossfadeDuration = val.toInt();
                        });
                      },
                      onChangeEnd: (val) {
                        _saveInt('crossfadeDuration', val.toInt());
                      },
                    ),
                  ),
                ),
              ),
              _buildPremiumSwitchTile(
                icon: Icons.headset_off_outlined,
                title: 'Pause on Disconnect',
                subtitle: 'Pause music when headphones are removed',
                value: _pauseOnDisconnect,
                onChanged: (val) {
                  setState(() => _pauseOnDisconnect = val);
                  _saveBool('pauseOnDisconnect', val);
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.call_missed_outgoing_rounded,
                title: 'Resume after Call',
                subtitle: 'Auto play music when a call ends',
                value: _autoPlayAfterCall,
                onChanged: (val) {
                  setState(() => _autoPlayAfterCall = val);
                  _saveBool('autoPlayAfterCall', val);
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.layers_rounded,
                title: 'Play Together with other Apps',
                subtitle: 'Allow Flow to play audio alongside other apps',
                value: _playTogether,
                onChanged: (val) {
                  setState(() => _playTogether = val);
                  _saveBool('playTogether', val);
                  configureAudioSession(val); // Reconfigure dynamically
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.content_cut_rounded,
                title: 'Silence Trimmer',
                subtitle: 'Skip silent periods in audio tracks',
                value: _skipSilence,
                onChanged: (val) {
                  setState(() => _skipSilence = val);
                  _saveBool('skipSilence', val);
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.battery_saver_rounded,
                title: 'Stop Playback on Low Battery',
                subtitle: 'Pause music when battery falls below 15%',
                value: _stopOnLowBattery,
                onChanged: (val) {
                  setState(() => _stopOnLowBattery = val);
                  _saveBool('stopOnLowBattery', val);
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.hearing_rounded,
                title: 'Mono Audio Toggle',
                subtitle: 'Combine left and right audio channels',
                value: _monoAudio,
                onChanged: (val) async {
                  try {
                    const channel = MethodChannel('com.flow.audio/equalizer');
                    await channel.invokeMethod('toggleMonoAudio', {
                      'enable': val,
                    });
                    setState(() => _monoAudio = val);
                    await _saveBool('monoAudio', val);
                  } catch (e) {
                    if (e is PlatformException &&
                        e.code == 'SECURE_SETTINGS_RESTRICTED') {
                      setState(() => _monoAudio = val);
                      await _saveBool('monoAudio', val);
                      showFlowToast(
                        "Info: Flow doesn't need to be in 'Downloaded Apps'. Simply toggle the global 'Mono Audio' switch on this screen!",
                        isLong: true,
                      );
                    } else {
                      setState(() => _monoAudio = false);
                      await _saveBool('monoAudio', false);
                      if (e is PlatformException &&
                          e.code == 'PERMISSION_DENIED') {
                        showFlowToast(
                          "Please grant Flow permission to modify system settings to toggle Mono Audio",
                          isLong: true,
                        );
                      } else {
                        showFlowToast(
                          "Mono Audio is not supported on this device",
                          isLong: true,
                        );
                      }
                    }
                  }
                },
              ),
              _buildPremiumListTile(
                icon: Icons.equalizer_rounded,
                title: 'Equalizer',
                subtitle: 'Adjust sound effects and audio frequency',
                onTap: () {
                  MainScreen.showEqualizer(context);
                },
              ),
              _buildPremiumListTile(
                icon: Icons.bar_chart_rounded,
                title: 'Most Played Threshold',
                subtitle: _getThresholdLabel(_playCountThreshold),
                onTap: () => _showThresholdDialog(),
              ),
            ],
          ),
          _buildSectionHeader('Library & Storage'),
          _buildPremiumCard(
            children: [
              _buildPremiumSwitchTile(
                icon: Icons.auto_fix_high,
                title: 'Auto Regex Cleaner',
                subtitle: 'Automatically clean messy song titles',
                value: _autoRegexClean,
                onChanged: (val) {
                  setState(() => _autoRegexClean = val);
                  _saveBool('autoRegexClean', val);
                  if (val) {
                    showFlowToast(
                      "Rescan library to apply title cleaning to existing songs",
                      isLong: true,
                    );
                  }
                },
              ),
              _buildPremiumSwitchTile(
                icon: Icons.filter_alt_outlined,
                title: 'Filter Short Audio',
                subtitle: 'Hide tracks shorter than 30 seconds',
                value: _filterShortAudio,
                onChanged: (val) {
                  setState(() => _filterShortAudio = val);
                  _saveBool('filterShortAudio', val);
                },
              ),
              _buildPremiumListTile(
                icon: Icons.folder_outlined,
                title: 'Specific Folder Scan',
                subtitle: 'Only scan specific directories',
                onTap: () {
                  widget.onManageFolders();
                },
              ),
              _buildPremiumListTile(
                icon: Icons.visibility_off_outlined,
                title: 'Hidden Tracks',
                subtitle: 'Manage hidden and filtered tracks',
                onTap: () async {
                  _songsFuture = OnAudioQuery().querySongs(
                    sortType: SongSortType.TITLE,
                    orderType: OrderType.ASC_OR_SMALLER,
                    uriType: UriType.EXTERNAL,
                    ignoreCase: true,
                  );
                  await _showHiddenTracksSheet(context);
                  _songsFuture = null;
                },
              ),
              _buildPremiumListTile(
                icon: Icons.sync_rounded,
                title: 'Rescan Library',
                subtitle: 'Search for new audio files on your device',
                onTap: () {
                  Navigator.pop(context);
                  widget.onRescanLibrary();
                },
              ),
              _buildPremiumListTile(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear Image Cache',
                subtitle: 'Free up memory used by album covers',
                onTap: () {
                  PaintingBinding.instance.imageCache.clear();
                  PaintingBinding.instance.imageCache.clearLiveImages();
                  showFlowToast("Image cache cleared");
                },
              ),
              _buildPremiumListTile(
                icon: Icons.delete_forever_outlined,
                title: 'Reset App Data',
                subtitle: 'Clear all playlists, favorites, and history',
                titleColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                onTap: () => _showResetConfirmation(),
              ),
            ],
          ),
          _buildSectionHeader('About Flow'),
          _buildPremiumCard(
            children: [
              _buildPremiumListTile(
                icon: Icons.update_rounded,
                title: 'Check for Updates',
                subtitle: 'Version 1.0.0',
                onTap: () => _checkForUpdates(),
              ),
              _buildPremiumListTile(
                icon: Icons.code_rounded,
                title: 'Source Code',
                subtitle: 'GitHub Repository',
                trailing: const Icon(
                  Icons.open_in_new,
                  color: Colors.white24,
                  size: 18,
                ),
                onTap: () async {
                  final url = Uri.parse('https://github.com/coflyn/Flow');
                  try {
                    final launched = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      showFlowToast("Could not open link");
                    }
                  } catch (e) {
                    showFlowToast("Could not open link");
                  }
                },
              ),
              _buildPremiumListTile(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFE91E63),
                title: 'Support Developer',
                subtitle: 'Donate via Sociabuzz',
                trailing: const Icon(
                  Icons.open_in_new,
                  color: Colors.white24,
                  size: 18,
                ),
                onTap: () async {
                  final url = Uri.parse('https://sociabuzz.com/coflyn');
                  try {
                    final launched = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      showFlowToast("Could not open link");
                    }
                  } catch (e) {
                    showFlowToast("Could not open link");
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
