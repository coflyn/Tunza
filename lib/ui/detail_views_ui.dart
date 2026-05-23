// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _DetailViewsUI on _MainScreenState {
  Widget _getActiveDetailView() {
    String? baseName =
        _selectedPlaylistDetail ??
        _selectedArtistDetail ??
        _selectedAlbumDetail;
    String? type = _selectedPlaylistDetail != null
        ? 'Playlist'
        : _selectedArtistDetail != null
        ? 'Artist'
        : _selectedAlbumDetail != null
        ? 'Album'
        : null;

    if (baseName == null || type == null) {
      return _lastDetailView ?? const SizedBox.shrink();
    }

    String currentKey = "${baseName}_${_searchQuery}_$type";

    if (_cachedDetailKey != currentKey ||
        _cachedDetailSongs == null ||
        _cachedDetailImage == null) {
      _cachedDetailKey = currentKey;
      if (_detailScrollController.hasClients) {
        _detailScrollController.jumpTo(0);
      }
      List<Track> pSongs = [];
      Widget? imageWidget;

      if (type == 'Playlist') {
        if (baseName == 'Favourites') {
          pSongs = _allTracks
              .where((t) => _favoriteTrackIds.contains(t.id))
              .toList();
        } else if (baseName == 'Recently Added') {
          pSongs = List.from(_allTracks);
        } else if (baseName == 'Last Played') {
          pSongs = _lastPlayedTrackIds
              .map(
                (id) => _allTracks.firstWhere(
                  (t) => t.id == id,
                  orElse: () => _allTracks[0],
                ),
              )
              .where((t) => _lastPlayedTrackIds.contains(t.id))
              .toList();
        } else if (baseName == 'Most Played') {
          pSongs = List.from(_allTracks);
          pSongs.sort(
            (a, b) =>
                (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
          );
          pSongs = pSongs.where((t) => (_playCounts[t.id] ?? 0) > 0).toList();
        } else if (_userPlaylists.containsKey(baseName)) {
          final trackIds = _userPlaylists[baseName]!.toSet();
          pSongs = _allTracks.where((t) => trackIds.contains(t.id)).toList();
        }

        if (_playlistCovers.containsKey(baseName)) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(
              image: ResizeImage(
                FileImage(File(_playlistCovers[baseName]!)),
                width: 600,
              ),
              fit: BoxFit.cover,
              width: 220,
              height: 220,
            ),
          );
        } else {
          Color color = Colors.grey;
          IconData icon = Icons.queue_music;
          if (baseName == 'Favourites') {
            color = const Color(0xFFE91E63);
            icon = Icons.favorite;
          } else if (baseName == 'Recently Added') {
            color = const Color(0xFF2196F3);
            icon = Icons.new_releases;
          } else if (baseName == 'Last Played') {
            color = const Color(0xFFFF9800);
            icon = Icons.history;
          } else if (baseName == 'Most Played') {
            color = const Color(0xFFF44336);
            icon = Icons.local_fire_department;
          } else if (_userPlaylists.containsKey(baseName)) {
            color = const Color(0xFF9C27B0);
            icon = Icons.queue_music;
          }

          imageWidget = Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: pSongs.isNotEmpty
                  ? _buildTrackArtwork(pSongs.first, size: 220, radius: 24)
                  : Icon(icon, size: 80, color: color),
            ),
          );
        }
      } else if (type == 'Artist') {
        pSongs = _allTracks.where((t) => t.artist == baseName).toList();
        imageWidget = pSongs.isNotEmpty
            ? _buildTrackArtwork(pSongs.first, size: 220, radius: 24)
            : const SizedBox(width: 220, height: 220);
      } else if (type == 'Album') {
        pSongs = _allTracks.where((t) => t.album == baseName).toList();
        imageWidget = pSongs.isNotEmpty
            ? _buildTrackArtwork(pSongs.first, size: 220, radius: 24)
            : const SizedBox(width: 220, height: 220);
      }

      if (_searchQuery.isNotEmpty) {
        pSongs = pSongs
            .where(
              (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      if (_detailSortBy == 'title') {
        pSongs.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      } else if (_detailSortBy == 'artist') {
        pSongs.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
      } else if (_detailSortBy == 'duration_longest') {
        pSongs.sort((a, b) => b.duration.compareTo(a.duration));
      } else if (_detailSortBy == 'duration_shortest') {
        pSongs.sort((a, b) => a.duration.compareTo(b.duration));
      }

      _cachedDetailSongs = pSongs;
      _cachedDetailImage = imageWidget;
    }

    final totalMs = _cachedDetailSongs!.fold<int>(
      0,
      (sum, t) => sum + t.duration,
    );
    final durationStr = _formatTotalDuration(totalMs);

    _lastDetailView = _buildDetailView(
      title: baseName,
      subtitle: '${_cachedDetailSongs!.length} songs • $durationStr',
      type: type,
      tracks: _cachedDetailSongs!,
      imageWidget: _cachedDetailImage!,
    );

    return _lastDetailView!;
  }

  Widget _buildDetailView({
    required String title,
    required String subtitle,
    required String type,
    required Widget imageWidget,
    required List<Track> tracks,
  }) {
    final isLight = themeModeNotifier.value == 'light';
    final scaffoldBgColor = getAppBackgroundColor(
      themeMode: themeModeNotifier.value,
      customBg: customThemeBgNotifier.value,
      artworkColor: dominantColorNotifier.value,
    );

    final header = GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          setState(() {
            _isDraggingDetail = true;
            _detailDragOffset +=
                details.primaryDelta! / MediaQuery.of(context).size.height;
          });
        } else if (details.primaryDelta! < 0) {
          if (_detailScrollController.hasClients) {
            _detailScrollController.jumpTo(
              (_detailScrollController.offset - details.primaryDelta!).clamp(
                0.0,
                _detailScrollController.position.maxScrollExtent,
              ),
            );
          }
        }
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _isDraggingDetail = false;
          if (_detailDragOffset > 0.2 ||
              (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300)) {
            _selectedPlaylistDetail = null;
            _selectedArtistDetail = null;
            _selectedAlbumDetail = null;
          }
          _detailDragOffset = 0.0;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedPlaylistDetail = null;
                        _selectedArtistDetail = null;
                        _selectedAlbumDetail = null;
                      });
                    },
                  ),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      size: 28,
                    ),
                    onPressed: () => _showDetailOptions(title, type, tracks),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isLight ? 0.15 : 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: isLight ? Colors.black45 : Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isLight ? Colors.black54 : Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    heroTag: null,
                    backgroundColor: _activeAccentColor,
                    onPressed: () {
                      if (tracks.isNotEmpty) {
                        _updatePlayingFrom();
                        setState(() {
                          _playbackQueue = List.from(tracks);
                          _shuffledIndices.clear();
                          if (_isShuffle) {
                            _shuffledIndices = List.generate(
                              _playbackQueue.length,
                              (i) => i,
                            );
                            _shuffledIndices.shuffle();
                          }
                        });
                        _playTrack(0);
                      }
                    },
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: isLight ? Colors.black45 : Colors.white54,
                      size: 30,
                    ),
                    onPressed: () {
                      if (tracks.isNotEmpty) {
                        _updatePlayingFrom();
                        final shuffledTracks = List<Track>.from(tracks)
                          ..shuffle();
                        _playTrack(0, sourceList: shuffledTracks);
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.sort_rounded,
                      color: isLight ? Colors.black54 : Colors.white70,
                      size: 26,
                    ),
                    onPressed: () {
                      _showDetailSortModal(context);
                    },
                    tooltip: 'Sort Songs',
                  ),
                  if (type == 'Playlist' &&
                      _userPlaylists.containsKey(title)) ...[
                    IconButton(
                      icon: Icon(
                        Icons.edit_note_rounded,
                        color: isLight ? Colors.black54 : Colors.white70,
                        size: 28,
                      ),
                      onPressed: () {
                        _showEditPlaylistSongsModal(context, title);
                      },
                      tooltip: 'Edit Playlist',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    final detailStack = Container(
      color: scaffoldBgColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<String>(
              valueListenable: _playerBackgroundStyleNotifier,
              builder: (context, style, child) {
                if (style == 'amoled') {
                  return Container(
                    color: isLight ? scaffoldBgColor : const Color(0xFF000000),
                  );
                } else if (style == 'blur') {
                  final firstTrack = tracks.isNotEmpty ? tracks.first : null;
                  return Stack(
                    children: [
                      Container(
                        color: isLight
                            ? scaffoldBgColor
                            : const Color(0xFF0A0A0A),
                      ),
                      if (firstTrack != null)
                        Positioned.fill(
                          child: ClipRect(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 45.0,
                                sigmaY: 45.0,
                              ),
                              child: Opacity(
                                opacity: isLight ? 0.3 : 0.55,
                                child: Transform.scale(
                                  scale: 2.2,
                                  child: _buildTrackArtwork(
                                    firstTrack,
                                    size: 400,
                                    radius: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (isLight ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.35),
                                (isLight ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.75),
                                (isLight ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (style == 'custom') {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _playerCustomBgPathNotifier,
                    builder: (context, customPath, child) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _playerCustomBgBlurNotifier,
                        builder: (context, blurVal, child) {
                          return ValueListenableBuilder<double>(
                            valueListenable: _playerCustomBgDimNotifier,
                            builder: (context, dimVal, child) {
                              return ValueListenableBuilder<double>(
                                valueListenable: _playerCustomBgScaleNotifier,
                                builder: (context, scaleVal, child) {
                                  final dimColor = isLight
                                      ? Colors.white
                                      : Colors.black;
                                  return Stack(
                                    children: [
                                      Container(
                                        color: isLight
                                            ? scaffoldBgColor
                                            : const Color(0xFF0A0A0A),
                                      ),
                                      if (customPath != null &&
                                          File(customPath).existsSync())
                                        Positioned.fill(
                                          child: ClipRect(
                                            child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: blurVal,
                                                sigmaY: blurVal,
                                              ),
                                              child: Transform.scale(
                                                scale: scaleVal,
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
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                dimColor.withValues(
                                                  alpha: dimVal * 0.5,
                                                ),
                                                dimColor.withValues(
                                                  alpha: dimVal * 1.2 > 1.0
                                                      ? 1.0
                                                      : dimVal * 1.2,
                                                ),
                                                dimColor.withValues(
                                                  alpha: dimVal * 1.8 > 1.0
                                                      ? 1.0
                                                      : dimVal * 1.8,
                                                ),
                                              ],
                                            ),
                                          ),
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
                    },
                  );
                } else {
                  return FutureBuilder<Color?>(
                    future: _detailColorFuture,
                    builder: (context, snapshot) {
                      final color = snapshot.data ?? const Color(0xFF161616);
                      return Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 400,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    color.withValues(
                                      alpha: isLight ? 0.15 : 0.4,
                                    ),
                                    scaffoldBgColor,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          _buildSongList(
            tracks,
            header: header,
            isMostPlayed: title == 'Most Played',
            controller: _detailScrollController,
          ),
        ],
      ),
    );

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          setState(() {
            _isDraggingDetail = true;
            _detailDragOffset +=
                details.primaryDelta! / MediaQuery.of(context).size.height;
          });
        }
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _isDraggingDetail = false;
          if (_detailDragOffset > 0.2 ||
              (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300)) {
            _selectedPlaylistDetail = null;
            _selectedArtistDetail = null;
            _selectedAlbumDetail = null;
          }
          _detailDragOffset = 0.0;
        });
      },
      child: detailStack,
    );
  }

  String _formatTotalDuration(int ms) {
    final seconds = (ms / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes < 60) {
      if (minutes == 0) {
        return '$remainingSeconds sec';
      }
      return '$minutes min $remainingSeconds sec';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $remainingMinutes min';
    }
  }
}
