// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _MainUIComponents on _MainScreenState {
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
              'Flow',
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
                      onSettingsChanged: _loadSettings,
                      onRescanLibrary: () {
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
                      onSetSkipSilence: (val) {
                        setState(() {
                          _skipSilence = val;
                        });
                        _audioPlayer.setSkipSilenceEnabled(val);
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
            Text(
              FlowStrings.get('no_songs_found'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              FlowStrings.get('no_songs_subtitle'),
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
              label: Text(
                FlowStrings.get('refresh_library'),
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
          if (title == FlowStrings.get('favourites')) {
            pSongs = _allTracks
                .where((t) => _favoriteTrackIds.contains(t.id))
                .toList();
          } else if (title == FlowStrings.get('recently_added')) {
            pSongs = List.from(_allTracks);
          } else if (title == FlowStrings.get('last_played')) {
            pSongs = _lastPlayedTrackIds
                .map(
                  (id) => _allTracks.firstWhere(
                    (t) => t.id == id,
                    orElse: () => _allTracks[0],
                  ),
                )
                .where((t) => _lastPlayedTrackIds.contains(t.id))
                .toList();
          } else if (title == FlowStrings.get('most_played')) {
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
                    width: 150,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : _buildStackedArtwork(
              songs,
              color,
              icon,
              title == FlowStrings.get('favourites'),
            ),
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<int> effectiveIndices = [];
            if (_repeatMode == 2) {
              effectiveIndices = [_currentIndex];
            } else if (_repeatMode == 1) {
              if (_isShuffle &&
                  _shuffledIndices.length == _playbackQueue.length) {
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
              if (_isShuffle &&
                  _shuffledIndices.length == _playbackQueue.length) {
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
                      Text(
                        FlowStrings.get('up_next'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_isShuffle)
                        Icon(
                          Icons.shuffle,
                          color: _activeAccentColor,
                          size: 18,
                        ),
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
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: effectiveIndices.length,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex == 0) {
                        return; // Cannot move currently playing track
                      }
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      if (newIndex == 0) {
                        newIndex =
                            1; // Cannot move above currently playing track
                      }

                      setModalState(() {
                        final item = effectiveIndices.removeAt(oldIndex);
                        effectiveIndices.insert(newIndex, item);
                      });
                      reorderUpNext(effectiveIndices);
                    },
                    itemBuilder: (context, idx) {
                      final realIndex = effectiveIndices[idx];
                      final track = _playbackQueue[realIndex];
                      final isCurrent = realIndex == _currentIndex;
                      return ListTile(
                        key: ValueKey('up_next_${track.id}_$realIndex'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
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
                            : const Icon(
                                Icons.drag_handle,
                                color: Colors.white30,
                              ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent
                                ? _activeAccentColor
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
      },
    );
  }

  String _getParentDirectory(String filePath) {
    final lastSeparator = filePath.lastIndexOf('/');
    if (lastSeparator == -1) return '';
    return filePath.substring(0, lastSeparator);
  }
}
