// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onRescanLibrary;
  final Function(int) onSetSleepTimer;
  final VoidCallback onResetData;
  final ValueNotifier<int> sleepTimerNotifier;
  final VoidCallback onManageFolders;

  const SettingsScreen({
    super.key,
    required this.onRescanLibrary,
    required this.onSetSleepTimer,
    required this.onResetData,
    required this.sleepTimerNotifier,
    required this.onManageFolders,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _filterShortAudio = false;
  bool _autoRegexClean = false;
  int _crossfadeDuration = 150;
  bool _pauseOnDisconnect = true;
  List<String> _hiddenTrackIds = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filterShortAudio = prefs.getBool('filterShortAudio') ?? false;
      _autoRegexClean = prefs.getBool('autoRegexClean') ?? false;
      _crossfadeDuration = prefs.getInt('crossfadeDuration') ?? 150;
      _pauseOnDisconnect = prefs.getBool('pauseOnDisconnect') ?? true;
      _hiddenTrackIds = prefs.getStringList('hidden_track_ids') ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
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
                      value: _crossfadeDuration.toDouble(),
                      min: 0,
                      max: 3000,
                      divisions: 30,
                      activeColor: const Color(0xFF1DB954),
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
                onTap: () {
                  _showHiddenTracksSheet(context);
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
                  Fluttertoast.showToast(msg: "Image cache cleared");
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
          _buildSectionHeader('About Tunza'),
          _buildPremiumCard(
            children: [
              _buildPremiumListTile(
                icon: Icons.update_rounded,
                title: 'Check for Updates',
                subtitle: 'Version 1.0.0 is up to date',
                onTap: () {
                  Fluttertoast.showToast(msg: "Tunza is up to date");
                },
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
                  final url = Uri.parse('https://github.com/coflyn/Tunza');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Fluttertoast.showToast(msg: "Could not open link");
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
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Fluttertoast.showToast(msg: "Could not open link");
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1DB954),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Widget child = entry.value;
          if (idx == children.length - 1) return child;
          return Column(
            children: [
              child,
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withOpacity(0.04),
                indent: 56,
                endIndent: 16,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
    bool isActive = false,
  }) {
    final effectiveIconColor =
        iconColor ?? (isActive ? const Color(0xFF1DB954) : Colors.white70);
    final effectiveTitleColor = titleColor ?? Colors.white;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: effectiveTitleColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isActive
                    ? effectiveIconColor.withOpacity(0.8)
                    : Colors.white38,
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _buildPremiumSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildPremiumListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isActive: value,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF1DB954),
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.white10,
      ),
    );
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sleep Timer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimerOption('Off', 0),
              _buildTimerOption('15 Minutes', 15),
              _buildTimerOption('30 Minutes', 30),
              _buildTimerOption('60 Minutes', 60),
              ListTile(
                title: const Text(
                  'Custom...',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.edit,
                  color: Colors.white54,
                  size: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomTimerDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomTimerDialog() {
    int customMinutes = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Custom Timer',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Minutes (e.g. 120)',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
          onChanged: (val) {
            customMinutes = int.tryParse(val) ?? 0;
          },
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
              widget.onSetSleepTimer(customMinutes);
              Navigator.pop(context);
            },
            child: const Text(
              'Start',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerOption(String title, int minutes) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        widget.onSetSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Reset App Data?', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'This will permanently delete your custom playlists, favorites, and play statistics.\n\nAudio files on your device will NOT be deleted.',
            style: TextStyle(color: Colors.white70, height: 1.5),
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
                Navigator.pop(context);
                Navigator.pop(context); // close settings
                widget.onResetData();
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHiddenTracksSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final OnAudioQuery audioQuery = OnAudioQuery();
            return FutureBuilder<List<SongModel>>(
              future: audioQuery.querySongs(
                sortType: SongSortType.TITLE,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1DB954),
                        ),
                      ),
                    ),
                  );
                }

                final allSongs = snapshot.data ?? [];
                final List<SongModel> displaySongs =
                    allSongs.where((song) {
                      final bool isManuallyHidden = _hiddenTrackIds.contains(
                        song.id.toString(),
                      );
                      final bool isShortAudio =
                          _filterShortAudio && (song.duration ?? 0) < 30000;
                      return isManuallyHidden || isShortAudio;
                    }).toList()..sort(
                      (a, b) => a.title.toLowerCase().compareTo(
                        b.title.toLowerCase(),
                      ),
                    );

                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hidden & Filtered Tracks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${displaySongs.length} tracks',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage tracks that are manually hidden or automatically filtered out by your settings.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: displaySongs.isEmpty
                            ? Center(
                                child: Text(
                                  'No hidden tracks found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: displaySongs.length,
                                itemBuilder: (context, index) {
                                  final song = displaySongs[index];
                                  final bool isManuallyHidden = _hiddenTrackIds
                                      .contains(song.id.toString());
                                  final bool isShortAudio =
                                      _filterShortAudio &&
                                      (song.duration ?? 0) < 30000;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161616),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      song.artist ??
                                                          'Unknown Artist',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (isManuallyHidden)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.orange
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'HIDDEN',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  if (isShortAudio)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.cyan
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.cyan
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'SHORT AUDIO',
                                                        style: TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (isManuallyHidden)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              color: Color(0xFF1DB954),
                                              size: 20,
                                            ),
                                            tooltip: 'Unhide track',
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              setState(() {
                                                _hiddenTrackIds.remove(
                                                  song.id.toString(),
                                                );
                                              });
                                              await prefs.setStringList(
                                                'hidden_track_ids',
                                                _hiddenTrackIds,
                                              );
                                              widget.onRescanLibrary();
                                              setModalState(() {});
                                              Fluttertoast.showToast(
                                                msg:
                                                    "${song.title} restored to library",
                                              );
                                            },
                                          )
                                        else
                                          IconButton(
                                            icon: const Icon(
                                              Icons.info_outline_rounded,
                                              color: Colors.white30,
                                              size: 20,
                                            ),
                                            tooltip:
                                                'Auto-hidden by Short Audio filter',
                                            onPressed: () {
                                              Fluttertoast.showToast(
                                                msg:
                                                    "This track is automatically hidden because it is shorter than 30s.",
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  );
                                },
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
}
