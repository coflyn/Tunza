// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member
part of 'settings_screen.dart';

extension SettingsModals on _SettingsScreenState {
  void _showSleepTimerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  FlowStrings.get('sleep_timer_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              _buildTimerOption('5 ${FlowStrings.get('minutes_format')}', 5),
              _buildTimerOption('10 ${FlowStrings.get('minutes_format')}', 10),
              _buildTimerOption('15 ${FlowStrings.get('minutes_format')}', 15),
              _buildTimerOption('30 ${FlowStrings.get('minutes_format')}', 30),
              _buildTimerOption('45 ${FlowStrings.get('minutes_format')}', 45),
              _buildTimerOption(FlowStrings.get('hour_1'), 60),
              _buildTimerOption(FlowStrings.get('end_of_track_short'), -1),
              _buildTimerOption(FlowStrings.get('turn_off'), 0),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerOption(String title, int minutes) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        widget.onSetSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _handleBackup() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: FlowStrings.get('confirm_backup'),
      content: FlowStrings.get('confirm_backup_body'),
      confirmText: FlowStrings.get('backup'),
      confirmColor: widget.activeAccentColor,
    );
    if (confirm != true) return;

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    try {
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        final Map<String, dynamic> prefsMap = {};
        for (String key in keys) {
          prefsMap[key] = prefs.get(key);
        }
        final String jsonString = jsonEncode(prefsMap);

        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final file = File('${directory.path}/Flow_Backup.json');
        await file.writeAsString(jsonString);

        if (!context.mounted) return;
        showFlowToast(FlowStrings.get('backup_success'));
      } else {
        if (!context.mounted) return;
        showFlowToast(FlowStrings.get('permission_denied'));
      }
    } catch (e) {
      if (!context.mounted) return;
      showFlowToast('${FlowStrings.get('backup_failed')}: $e');
    }
  }

  Future<void> _handleRestore() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: FlowStrings.get('confirm_restore'),
      content: FlowStrings.get('confirm_restore_body'),
      confirmText: FlowStrings.get('restore'),
      confirmColor: widget.activeAccentColor,
    );
    if (confirm != true) return;

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    try {
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        final directory = Directory('/storage/emulated/0/Download');
        final file = File('${directory.path}/Flow_Backup.json');

        if (await file.exists()) {
          final String jsonString = await file.readAsString();
          final Map<String, dynamic> prefsMap = jsonDecode(jsonString);

          final prefs = await SharedPreferences.getInstance();
          for (String key in prefsMap.keys) {
            final value = prefsMap[key];
            if (value is String) {
              await prefs.setString(key, value);
            } else if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            } else if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is List<dynamic>) {
              await prefs.setStringList(key, List<String>.from(value));
            }
          }

          if (!context.mounted) return;
          showFlowToast(FlowStrings.get('restore_success'));
          widget.onRescanLibrary();
        } else {
          if (!context.mounted) return;
          showFlowToast(FlowStrings.get('no_backup_found'));
        }
      } else {
        if (!context.mounted) return;
        showFlowToast(FlowStrings.get('permission_denied'));
      }
    } catch (e) {
      if (!context.mounted) return;
      showFlowToast('${FlowStrings.get('restore_failed')}: $e');
    }
  }

  Future<void> _showResetConfirmation() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: FlowStrings.get('reset_confirm_title'),
      content: FlowStrings.get('reset_confirm_body'),
      confirmText: FlowStrings.get('reset'),
    );
    if (confirm == true) {
      if (mounted) {
        Navigator.pop(context); // close settings
      }
      widget.onResetData();
    }
  }

  Future<void> _showHiddenTracksSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<SongModel>>(
              future: _songsFuture,
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
                          Text(
                            FlowStrings.get('hidden_filtered_tracks_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${displaySongs.length}${FlowStrings.get('tracks_count_suffix')}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        FlowStrings.get('hidden_tracks_desc'),
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
                                  FlowStrings.get('no_hidden_tracks'),
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
                                                      (song.artist == null ||
                                                              song.artist ==
                                                                  '<unknown>')
                                                          ? FlowStrings.get(
                                                              'unknown_artist',
                                                            )
                                                          : song.artist!,
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
                                                      child: Text(
                                                        FlowStrings.get(
                                                          'badge_hidden',
                                                        ),
                                                        style: const TextStyle(
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
                                                      child: Text(
                                                        FlowStrings.get(
                                                          'badge_short_audio',
                                                        ),
                                                        style: const TextStyle(
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
                                            icon: Icon(
                                              Icons.visibility_outlined,
                                              color: _activeAccentColor,
                                              size: 20,
                                            ),
                                            tooltip: FlowStrings.get(
                                              'unhide_track',
                                            ),
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
                                              showFlowToast(
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
                                            tooltip: FlowStrings.get(
                                              'auto_hidden_tooltip',
                                            ),
                                            onPressed: () {
                                              showFlowToast(
                                                FlowStrings.get(
                                                  'auto_hidden_toast',
                                                ),
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

  String _getThresholdLabel(int seconds) {
    if (seconds == -1) return FlowStrings.get('end_of_track_short');
    if (seconds == 60) return FlowStrings.get('minute_1');
    return '$seconds ${FlowStrings.get('seconds_format')}';
  }

  void _showThresholdDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  FlowStrings.get('most_played_threshold_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              _buildThresholdOption(
                '5 ${FlowStrings.get('seconds_format')}',
                5,
              ),
              _buildThresholdOption(
                '10 ${FlowStrings.get('seconds_default_format')}',
                10,
              ),
              _buildThresholdOption(
                '30 ${FlowStrings.get('seconds_format')}',
                30,
              ),
              _buildThresholdOption(FlowStrings.get('minute_1'), 60),
              _buildThresholdOption(FlowStrings.get('end_of_track_short'), -1),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThresholdOption(String label, int seconds) {
    final isSelected = _playCountThreshold == seconds;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? _activeAccentColor : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: _activeAccentColor)
          : null,
      onTap: () {
        widget.onSetPlayCountThreshold(seconds);
        setState(() {
          _playCountThreshold = seconds;
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFontSizeLabel(double scale) {
    if (scale == 0.85) return FlowStrings.get('size_small');
    if (scale == 1.15) return FlowStrings.get('size_large');
    if (scale == 1.3) return FlowStrings.get('size_extra_large');
    return FlowStrings.get('size_default');
  }

  void _showTypographyPreviewDialog() {
    String tempFont = _activeFont;
    double tempFontScale = _fontScale;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            TextStyle previewTextStyle({
              double size = 14,
              FontWeight weight = FontWeight.normal,
              Color? color,
            }) {
              final baseStyle = TextStyle(
                fontSize: size * tempFontScale,
                fontWeight: weight,
                color: color ?? Colors.white,
              );
              if (tempFont == 'Spotify Style') {
                return GoogleFonts.figtree(textStyle: baseStyle);
              } else if (tempFont == 'Apple Music Style') {
                return GoogleFonts.inter(textStyle: baseStyle);
              } else {
                return GoogleFonts.plusJakartaSans(textStyle: baseStyle);
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          FlowStrings.get('typography_font_size'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Live Preview Section Header
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: _activeAccentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            FlowStrings.get('live_preview'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Live Simulated Library Window
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF0A0A0A), Color(0xFF0A0A0A)],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Simulated Header App Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        FlowStrings.get('library'),
                                        style: previewTextStyle(
                                          size: 32,
                                          weight: FontWeight.w800,
                                        ).copyWith(letterSpacing: -1.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24 * tempFontScale,
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Search Bar & Sort Button Row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161616),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.search,
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            size: 20 * tempFontScale,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              FlowStrings.get('search_songs'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: previewTextStyle(
                                                size: 13,
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161616),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.sort_rounded,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 20 * tempFontScale,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Filter Capsules
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 16,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      FlowStrings.get('songs_title'),
                                      true,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      FlowStrings.get('playlists'),
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      FlowStrings.get('artists'),
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      FlowStrings.get('albums'),
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Simulated Song List (Padding left/right 16)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  _buildSimulatedSongRow(
                                    title: 'Alexandra',
                                    artist: 'Reality Club',
                                    duration: '4:08',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildSimulatedSongRow(
                                    title: 'About You',
                                    artist: 'The 1975',
                                    duration: '5:26',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildSimulatedSongRow(
                                    title: 'Apocalypse',
                                    artist: 'Cigarettes After Sex',
                                    duration: '4:50',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Typography Selection Row
                      Text(
                        FlowStrings.get('font_family'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Plus Jakarta',
                              value: 'Plus Jakarta Sans',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Spotify Style',
                              value: 'Spotify Style',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Spotify Style',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Apple Style',
                              value: 'Apple Music Style',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Apple Music Style',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Font Size Selection List
                      Text(
                        FlowStrings.get('font_size'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFontSizeSelectorRow(
                        '${FlowStrings.get('size_small')} (85%)',
                        0.85,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${FlowStrings.get('size_default')} (100%)',
                        1.0,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${FlowStrings.get('size_large')} (115%)',
                        1.15,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${FlowStrings.get('size_extra_large')} (130%)',
                        1.3,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Bottom actions Close & Save
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    FlowStrings.get('close'),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('activeFont', tempFont);
                                await prefs.setDouble(
                                  'fontScale',
                                  tempFontScale,
                                );
                                widget.onSetFont(tempFont);
                                widget.onSetFontScale(tempFontScale);
                                setState(() {
                                  _activeFont = tempFont;
                                  _fontScale = tempFontScale;
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                showFlowToast(
                                  "Typography & size updated successfully!",
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _activeAccentColor,
                                      _activeAccentColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _activeAccentColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    FlowStrings.get('save'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

  String _getThemeAccentLabel(String preset) {
    switch (preset) {
      case 'dynamic':
        return FlowStrings.get('dynamic_artwork');
      case 'spotify':
        return FlowStrings.get('accent_spotify');
      case 'apple':
        return FlowStrings.get('accent_apple');
      case 'purple':
        return FlowStrings.get('accent_purple');
      case 'tidal':
        return FlowStrings.get('accent_tidal');
      case 'orange':
        return FlowStrings.get('accent_orange');
      case 'sakura':
        return FlowStrings.get('accent_sakura');
      case 'gold':
        return FlowStrings.get('accent_gold');
      case 'blue':
        return FlowStrings.get('accent_blue');
      case 'lime':
        return FlowStrings.get('accent_lime');
      default:
        return FlowStrings.get('accent_spotify');
    }
  }

  void _showThemeAccentSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                final presets = [
                  {
                    'id': 'dynamic',
                    'label': FlowStrings.get('dynamic_artwork'),
                    'desc': FlowStrings.get('accent_desc_dynamic'),
                    'color': widget.activeAccentColor,
                  },
                  {
                    'id': 'spotify',
                    'label': FlowStrings.get('accent_spotify'),
                    'desc': FlowStrings.get('accent_desc_spotify'),
                    'color': const Color(0xFF1DB954),
                  },
                  {
                    'id': 'apple',
                    'label': FlowStrings.get('accent_apple'),
                    'desc': FlowStrings.get('accent_desc_apple'),
                    'color': const Color(0xFFFC3C44),
                  },
                  {
                    'id': 'purple',
                    'label': FlowStrings.get('accent_purple'),
                    'desc': FlowStrings.get('accent_desc_purple'),
                    'color': const Color(0xFF8E2DE2),
                  },
                  {
                    'id': 'tidal',
                    'label': FlowStrings.get('accent_tidal'),
                    'desc': FlowStrings.get('accent_desc_tidal'),
                    'color': const Color(0xFF00F2FE),
                  },
                  {
                    'id': 'orange',
                    'label': FlowStrings.get('accent_orange'),
                    'desc': FlowStrings.get('accent_desc_orange'),
                    'color': const Color(0xFFFF9233),
                  },
                  {
                    'id': 'sakura',
                    'label': FlowStrings.get('accent_sakura'),
                    'desc': FlowStrings.get('accent_desc_sakura'),
                    'color': const Color(0xFFFF2A6D),
                  },
                  {
                    'id': 'gold',
                    'label': FlowStrings.get('accent_gold'),
                    'desc': FlowStrings.get('accent_desc_gold'),
                    'color': const Color(0xFFDFBA59),
                  },
                  {
                    'id': 'blue',
                    'label': FlowStrings.get('accent_blue'),
                    'desc': FlowStrings.get('accent_desc_blue'),
                    'color': const Color(0xFF007AFF),
                  },
                  {
                    'id': 'lime',
                    'label': FlowStrings.get('accent_lime'),
                    'desc': FlowStrings.get('accent_desc_lime'),
                    'color': const Color(0xFFCCFF00),
                  },
                ];

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
                    Text(
                      FlowStrings.get('theme_accent_color'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FlowStrings.get('accent_dialog_subtitle'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: presets.length,
                        itemBuilder: (context, index) {
                          final p = presets[index];
                          final id = p['id'] as String;
                          final isSelected = _selectedThemeAccent == id;
                          final color = p['color'] as Color;

                          return ListTile(
                            onTap: () {
                              setModalState(() {
                                _selectedThemeAccent = id;
                              });
                              setState(() {
                                _selectedThemeAccent = id;
                              });
                              widget.onSetThemeAccent(id);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(0.15),
                                border: Border.all(
                                  color: isSelected ? color : Colors.white10,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: id == 'dynamic'
                                        ? const SweepGradient(
                                            colors: [
                                              Colors.red,
                                              Colors.yellow,
                                              Colors.green,
                                              Colors.blue,
                                              Colors.red,
                                            ],
                                          )
                                        : null,
                                    color: id == 'dynamic' ? null : color,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              p['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              p['desc'] as String,
                              style: const TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: color,
                                    size: 22,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSimulatedFilterCapsule(
    String label,
    bool isSelected,
    TextStyle Function({double size, FontWeight weight, Color? color})
    styleHelper,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: styleHelper(
              size: 12,
              weight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedSongRow({
    required String title,
    required String artist,
    required String duration,
    required TextStyle Function({double size, FontWeight weight, Color? color})
    textStyleHelper,
    required double tempFontScale,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Center(
              child: Icon(
                Icons.music_note,
                color: _activeAccentColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleHelper(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleHelper(size: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                duration,
                style: textStyleHelper(size: 12, color: Colors.white38),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_vert,
                color: Colors.white54,
                size: 18 * tempFontScale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelectorChip({
    required String label,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: isSelected
                ? _activeAccentColor
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? _activeAccentColor : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSelectorRow(
    String label,
    double scale,
    double currentValue,
    Function(double) onChanged,
  ) {
    final isSelected = currentValue == scale;
    return ListTile(
      onTap: () => onChanged(scale),
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? _activeAccentColor
              : Colors.white.withOpacity(0.9),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? _activeAccentColor : Colors.white30,
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: _activeAccentColor,
                ),
              )
            : null,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _activeAccentColor, size: 18)
          : null,
    );
  }

  String _getPlayerBackgroundStyleLabel(String style) {
    switch (style) {
      case 'gradient':
        return FlowStrings.get('gradient_dynamic');
      case 'blur':
        return FlowStrings.get('blurred_cover');
      case 'amoled':
        return FlowStrings.get('amoled_black');
      case 'custom':
        return FlowStrings.get('custom_image');
      default:
        return FlowStrings.get('gradient_dynamic');
    }
  }

  void _showPlayerBackgroundStyleDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.75,
              expand: false,
              builder: (context, scrollController) {
                final options = [
                  {
                    'id': 'gradient',
                    'label': FlowStrings.get('gradient_dynamic'),
                    'desc': FlowStrings.get('player_bg_desc_gradient'),
                  },
                  {
                    'id': 'blur',
                    'label': FlowStrings.get('blurred_cover'),
                    'desc': FlowStrings.get('player_bg_desc_blur'),
                  },
                  {
                    'id': 'amoled',
                    'label': FlowStrings.get('amoled_black'),
                    'desc': FlowStrings.get('player_bg_desc_amoled'),
                  },
                  {
                    'id': 'custom',
                    'label': FlowStrings.get('custom_image'),
                    'desc': FlowStrings.get('player_bg_desc_custom'),
                  },
                ];

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      FlowStrings.get('player_background'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final id = opt['id'] as String;
                          final label = opt['label'] as String;
                          final desc = opt['desc'] as String;
                          final isSelected = _playerBackgroundStyle == id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            onTap: () async {
                              if (id == 'custom') {
                                if (_playerCustomBgPath != null &&
                                    File(_playerCustomBgPath!).existsSync()) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'playerBackgroundStyle',
                                    'custom',
                                  );
                                  if (!context.mounted) return;
                                  setState(() {
                                    _playerBackgroundStyle = 'custom';
                                  });
                                  setModalState(() {
                                    _playerBackgroundStyle = 'custom';
                                  });
                                  widget.onSetPlayerBackgroundStyle('custom');
                                  showFlowToast(
                                    'Custom wallpaper background set!',
                                  );
                                  Navigator.pop(context);
                                } else {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'playerBackgroundStyle',
                                      'custom',
                                    );
                                    await prefs.setString(
                                      'playerCustomBgPath',
                                      image.path,
                                    );
                                    if (!context.mounted) return;
                                    setState(() {
                                      _playerBackgroundStyle = 'custom';
                                      _playerCustomBgPath = image.path;
                                    });
                                    setModalState(() {
                                      _playerBackgroundStyle = 'custom';
                                      _playerCustomBgPath = image.path;
                                    });
                                    widget.onSetPlayerBackgroundStyle('custom');
                                    widget.onSetPlayerCustomBgPath(image.path);
                                    showFlowToast(
                                      'Custom wallpaper background set!',
                                    );
                                    Navigator.pop(context);
                                  }
                                }
                              } else {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'playerBackgroundStyle',
                                  id,
                                );
                                if (!context.mounted) return;
                                setState(() {
                                  _playerBackgroundStyle = id;
                                });
                                setModalState(() {
                                  _playerBackgroundStyle = id;
                                });
                                widget.onSetPlayerBackgroundStyle(id);
                                showFlowToast(
                                  '${FlowStrings.get('toast_bg_style_set')} $label',
                                );
                                Navigator.pop(context);
                              }
                            },
                            title: Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: _activeFont,
                              ),
                            ),
                            subtitle: Text(
                              desc,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (id == 'custom' &&
                                    _playerCustomBgPath != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(_playerCustomBgPath!),
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: _activeAccentColor,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return FlowStrings.get('light_mode');
      case 'custom':
        return FlowStrings.get('custom_theme');
      case 'dark':
      default:
        return FlowStrings.get('dark_mode');
    }
  }

  void _showThemeModeSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLight = _selectedThemeMode == 'light';
        final cardColor = isLight ? Colors.white : const Color(0xFF161616);
        final titleColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isLight
                      ? Colors.black.withOpacity(0.08)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                FlowStrings.get('theme_mode'),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeModeItem(
                id: 'dark',
                title: FlowStrings.get('dark_mode'),
                subtitle: FlowStrings.get('theme_mode_desc_dark'),
                icon: Icons.dark_mode_outlined,
              ),
              _buildThemeModeItem(
                id: 'light',
                title: FlowStrings.get('light_mode'),
                subtitle: FlowStrings.get('theme_mode_desc_light'),
                icon: Icons.light_mode_outlined,
              ),
              _buildThemeModeItem(
                id: 'custom',
                title: FlowStrings.get('custom_theme'),
                subtitle: FlowStrings.get('theme_mode_desc_custom'),
                icon: Icons.color_lens_outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeItem({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedThemeMode == id;
    final isLight = _selectedThemeMode == 'light';
    final primaryTextColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final secondaryTextColor = isLight ? Colors.black45 : Colors.white38;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.1)
              : (isLight
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? _activeAccentColor
              : (isLight ? Colors.black54 : Colors.white70),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: primaryTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: secondaryTextColor, fontSize: 12),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _activeAccentColor)
          : null,
      onTap: () async {
        Navigator.pop(context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('themeMode', id);
        setState(() {
          _selectedThemeMode = id;
        });
        widget.onSetThemeMode(id);
      },
    );
  }

  Widget _buildStylePill(String id, String label) {
    final isSelected = _customThemeStyle == id;
    final isLight = _selectedThemeMode == 'light';

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customThemeStyle', id);
        setState(() {
          _customThemeStyle = id;
        });
        widget.onSetCustomThemeStyle(id);
        showFlowToast('${FlowStrings.get('toast_theme_style_set')} $label');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor
              : (isLight
                    ? Colors.black.withOpacity(0.05)
                    : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _activeAccentColor
                : (isLight ? Colors.black12 : Colors.white10),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isLight ? Colors.black87 : Colors.white70),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: _activeFont,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBgOption({
    required String id,
    required String name,
    required Color color,
  }) {
    final isSelected = _customThemeBg == id;
    final isLight = _selectedThemeMode == 'light';

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customThemeBg', id);
        setState(() {
          _customThemeBg = id;
        });
        widget.onSetCustomThemeBg(id);

        if (id == 'custom_image' && _customThemeBgPath == null) {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            await prefs.setString('customThemeBgPath', image.path);
            setState(() {
              _customThemeBgPath = image.path;
            });
            widget.onSetCustomThemeBgPath(image.path);
            showFlowToast(FlowStrings.get('custom_theme_wallpaper_updated'));
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.15)
              : (isLight
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _activeAccentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: id == 'custom_image' && _customThemeBgPath != null
                    ? null
                    : color,
                image:
                    id == 'custom_image' &&
                        _customThemeBgPath != null &&
                        File(_customThemeBgPath!).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(_customThemeBgPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? Colors.black26 : Colors.white30,
                  width: 1,
                ),
              ),
              child: isSelected && id == 'dynamic'
                  ? const Icon(Icons.star, size: 8, color: Colors.white)
                  : (id == 'custom_image' && _customThemeBgPath == null
                        ? const Icon(Icons.add, size: 8, color: Colors.white)
                        : null),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? _activeAccentColor
                    : (isLight ? const Color(0xFF1A1A1A) : Colors.white70),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  FlowStrings.get('language'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              _buildLanguageOption('English', 'en', '🇺🇸'),
              _buildLanguageOption('Indonesia', 'id', '🇮🇩'),
              _buildLanguageOption('日本語', 'ja', '🇯🇵'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String label, String langCode, String flag) {
    final isSelected = _language == langCode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? _activeAccentColor : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: _activeAccentColor)
          : null,
      onTap: () async {
        final nav = Navigator.of(context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', langCode);
        languageNotifier.value = langCode;
        setState(() {
          _language = langCode;
        });
        nav.pop();
        // Force rebuild settings screen to apply new language
        setState(() {});
      },
    );
  }
}
