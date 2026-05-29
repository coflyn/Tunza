// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsUtilityUI on _MainScreenState {
  void _showFullSleepTimerDialog(BuildContext context) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black12 : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Sleep timer',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: _activeFont,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.08)
                    : Colors.white10,
                height: 1,
              ),
              _buildTimerSheetOpt(context, '5 minutes', 5),
              _buildTimerSheetOpt(context, '10 minutes', 10),
              _buildTimerSheetOpt(context, '15 minutes', 15),
              _buildTimerSheetOpt(context, '30 minutes', 30),
              _buildTimerSheetOpt(context, '45 minutes', 45),
              _buildTimerSheetOpt(context, '1 hour', 60),
              _buildTimerSheetOpt(context, 'End of track', -1),
              _buildTimerSheetOpt(context, 'Turn off', 0),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerSheetOpt(BuildContext context, String label, int minutes) {
    final isLight = isAppLight;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        label,
        style: TextStyle(
          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: _activeFont,
        ),
      ),
      onTap: () {
        _startSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }

  void _showFolderScanDialog(BuildContext context) {
    final Future<List<SongModel>> queryFuture = _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final isLight = isAppLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<SongModel>>(
              future: queryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _activeAccentColor,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        FlowStrings.get('no_music_folders'),
                        style: TextStyle(
                          color: isLight ? Colors.black45 : Colors.white30,
                          fontSize: 14,
                          fontFamily: _activeFont,
                        ),
                      ),
                    ),
                  );
                }

                // Group songs by parent directory path
                final Map<String, List<SongModel>> folderGroups = {};
                for (final song in snapshot.data!) {
                  if (song.data.isEmpty) continue;
                  final parentDir = _getParentDirectory(song.data);
                  if (parentDir.isEmpty) continue;
                  folderGroups.putIfAbsent(parentDir, () => []).add(song);
                }

                final List<String> allFolders = folderGroups.keys.toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                // Parse current allowed folders
                List<String> currentAllowed = [];
                if (_specificFolderScan.isNotEmpty) {
                  try {
                    currentAllowed = List<String>.from(
                      jsonDecode(_specificFolderScan),
                    );
                  } catch (_) {}
                }

                // If allowed folders is empty, visually treat all folders as enabled
                final bool isFilteringActive = currentAllowed.isNotEmpty;

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
                            color: isLight ? Colors.black12 : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FlowStrings.get('specific_folder_scan'),
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: _activeFont,
                            ),
                          ),
                          if (isFilteringActive)
                            TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('specificFolderScan', '');
                                setState(() {
                                  _specificFolderScan = '';
                                });
                                _requestPermissionAndScan(showLoading: false);
                                setModalState(() {});
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                FlowStrings.get('reset_filter'),
                                style: TextStyle(
                                  color: _activeAccentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  fontFamily: _activeFont,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        FlowStrings.get('folder_scan_desc'),
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white54,
                          fontSize: 12,
                          fontFamily: _activeFont,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: allFolders.length,
                          itemBuilder: (context, index) {
                            final folderPath = allFolders[index];
                            final songsInFolder =
                                folderGroups[folderPath] ?? [];
                            final folderName = folderPath.split('/').last;
                            final bool isEnabled =
                                !isFilteringActive ||
                                currentAllowed.contains(folderPath);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? Colors.black.withValues(alpha: 0.04)
                                    : const Color(0xFF22222B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                activeThumbColor: _activeAccentColor,
                                activeTrackColor: _activeAccentColor.withValues(
                                  alpha: 0.2,
                                ),
                                inactiveThumbColor: isLight
                                    ? Colors.black26
                                    : Colors.white24,
                                inactiveTrackColor: isLight
                                    ? Colors.black12
                                    : Colors.white12,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: _activeAccentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        folderName.isEmpty
                                            ? FlowStrings.get('folder_root')
                                            : folderName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: _activeFont,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLight
                                            ? Colors.black.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${songsInFolder.length}',
                                        style: TextStyle(
                                          color: isLight
                                              ? Colors.black54
                                              : Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: _activeFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 30,
                                  ),
                                  child: Text(
                                    folderPath,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.black38
                                          : Colors.white30,
                                      fontSize: 11,
                                      fontFamily: _activeFont,
                                    ),
                                  ),
                                ),
                                value: isEnabled,
                                onChanged: (value) async {
                                  List<String> newAllowed = List.from(
                                    currentAllowed,
                                  );
                                  if (!isFilteringActive) {
                                    newAllowed = List.from(allFolders);
                                  }

                                  if (value) {
                                    if (!newAllowed.contains(folderPath)) {
                                      newAllowed.add(folderPath);
                                    }
                                  } else {
                                    newAllowed.remove(folderPath);
                                  }

                                  if (newAllowed.length == allFolders.length) {
                                    newAllowed.clear();
                                  }

                                  final String jsonStr = newAllowed.isNotEmpty
                                      ? jsonEncode(newAllowed)
                                      : '';
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'specificFolderScan',
                                    jsonStr,
                                  );

                                  setState(() {
                                    _specificFolderScan = jsonStr;
                                  });
                                  _requestPermissionAndScan(showLoading: false);
                                  setModalState(() {});
                                },
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

  void _showEqualizerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _EqualizerSheetContent(
          player: _audioPlayer,
          activeFont: _activeFont,
          accentColor: _activeAccentColor,
        );
      },
    );
  }
}

class _EqualizerSheetContent extends StatefulWidget {
  final AudioPlayer player;
  final String activeFont;
  final Color accentColor;

  const _EqualizerSheetContent({
    required this.player,
    required this.activeFont,
    required this.accentColor,
  });

  @override
  State<_EqualizerSheetContent> createState() => _EqualizerSheetContentState();
}

class _EqualizerSheetContentState extends State<_EqualizerSheetContent> {
  static const _channel = MethodChannel('com.flow.audio/equalizer');
  bool _initialized = false;
  bool _enabled = false;
  int _bands = 0;
  int _minLevel = -1500;
  int _maxLevel = 1500;
  List<int> _frequencies = [];
  List<int> _levels = [];
  String? _error;
  String _activePreset = FlowStrings.get('custom_time');

  final Map<String, List<int>> _presets = {
    'Flat': [0, 0, 0, 0, 0],
    'Classical': [500, 300, -200, 400, 400],
    'Dance': [600, 0, 200, 400, 100],
    'Folk': [300, 0, 0, 200, -100],
    'Heavy Metal': [400, 100, 900, 300, 0],
    'Hip Hop': [500, 300, 0, 100, 500],
    'Jazz': [400, 200, -200, 200, 500],
    'Pop': [-200, -100, 500, 100, -200],
    'Rock': [500, 300, -100, 300, 500],
    'Bass Booster': [900, 600, 0, 0, 0],
    'Vocal Booster': [-200, 0, 600, 400, 0],
  };

  @override
  void initState() {
    super.initState();
    _initEQ();
  }

  Future<void> _initEQ() async {
    final sessionId = widget.player.androidAudioSessionId ?? 0;
    if (sessionId == 0) {
      setState(() {
        _error = FlowStrings.get('eq_error_play_first');
        _initialized = true;
      });
      return;
    }

    try {
      final res = await _channel.invokeMapMethod<String, dynamic>(
        'initEqualizer',
        {'audioSessionId': sessionId},
      );
      if (res != null) {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _bands = res['bands'] as int;
          _minLevel = res['minLevel'] as int;
          _maxLevel = res['maxLevel'] as int;
          _frequencies = List<int>.from(res['frequencies']);

          final savedLevelsStr = prefs.getString('saved_eq_levels');
          if (savedLevelsStr != null) {
            _levels = List<int>.from(jsonDecode(savedLevelsStr));
            for (int i = 0; i < _levels.length; i++) {
              if (i < _bands) {
                _channel.invokeMethod('setBandLevel', {
                  'band': i,
                  'level': _levels[i],
                });
              }
            }
          } else {
            _levels = List<int>.from(res['levels']);
          }

          _enabled =
              prefs.getBool('saved_eq_enabled') ?? res['enabled'] as bool;
          _channel.invokeMethod('setEqualizerEnabled', {'enable': _enabled});
          _activePreset =
              prefs.getString('saved_eq_preset') ??
              FlowStrings.get('custom_time');
          _initialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = FlowStrings.get('eq_error_unsupported');
        _initialized = true;
      });
    }
  }

  Future<void> _updateBandLevel(int band, int value) async {
    if (!_enabled) return;
    setState(() {
      _levels[band] = value;
      _activePreset = FlowStrings.get('custom_time');
    });
    try {
      await _channel.invokeMethod('setBandLevel', {
        'band': band,
        'level': value,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_eq_levels', jsonEncode(_levels));
      await prefs.setString('saved_eq_preset', FlowStrings.get('custom_time'));
    } catch (_) {}
  }

  Future<void> _toggleEnabled(bool val) async {
    setState(() {
      _enabled = val;
    });
    try {
      await _channel.invokeMethod('setEqualizerEnabled', {'enable': val});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('saved_eq_enabled', val);
    } catch (_) {}
  }

  Future<void> _selectPreset(String name) async {
    if (!_enabled) return;
    final presetVals = _presets[name];
    if (presetVals != null) {
      setState(() {
        _activePreset = name;
        for (int i = 0; i < _levels.length; i++) {
          if (i < presetVals.length) {
            _levels[i] = presetVals[i];
          }
        }
      });

      try {
        for (int i = 0; i < _levels.length; i++) {
          await _channel.invokeMethod('setBandLevel', {
            'band': i,
            'level': _levels[i],
          });
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_eq_levels', jsonEncode(_levels));
        await prefs.setString('saved_eq_preset', name);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.getFont(
      widget.activeFont,
      color: Colors.white,
    );

    if (!_initialized) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        color: const Color(0xFF121212),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        color: const Color(0xFF121212),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.equalizer_rounded,
                size: 64,
                color: widget.accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                FlowStrings.get('system_equalizer'),
                style: textStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: textStyle.copyWith(fontSize: 14, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FlowStrings.get('system_equalizer'),
                      style: textStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FlowStrings.get('equalizer_subtitle'),
                      style: textStyle.copyWith(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _enabled,
                  activeThumbColor: widget.accentColor,
                  activeTrackColor: widget.accentColor.withValues(alpha: 0.3),
                  onChanged: (val) => _toggleEnabled(val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Opacity(
              opacity: _enabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _presets.keys.map((presetName) {
                      final isActive = _activePreset == presetName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(presetName),
                          selected: isActive,
                          selectedColor: widget.accentColor,
                          backgroundColor: const Color(0xFF1E1E1E),
                          labelStyle: textStyle.copyWith(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isActive ? Colors.white : Colors.white70,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              _selectPreset(presetName);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Opacity(
              opacity: _enabled ? 1.0 : 0.3,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_bands, (index) {
                      final freq = _frequencies[index];
                      final freqLabel = freq >= 1000
                          ? '${(freq / 1000).toStringAsFixed(0)}k'
                          : '$freq';
                      final level = _levels[index];
                      final dbVal = (level / 100).toStringAsFixed(0);

                      return Column(
                        children: [
                          Text(
                            '${dbVal}dB',
                            style: textStyle.copyWith(
                              fontSize: 10,
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3.5,
                                  activeTrackColor: widget.accentColor,
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: Colors.white,
                                  overlayColor: widget.accentColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6.5,
                                    elevation: 2,
                                  ),
                                ),
                                child: Slider(
                                  value: level.toDouble(),
                                  min: _minLevel.toDouble(),
                                  max: _maxLevel.toDouble(),
                                  onChanged: (val) {
                                    _updateBandLevel(index, val.toInt());
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            '${freqLabel}Hz',
                            style: textStyle.copyWith(
                              fontSize: 11,
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
