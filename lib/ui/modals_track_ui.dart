// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsTrackUI on _MainScreenState {
  void _showTrackOptions(BuildContext context, Track track) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
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
                                style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: _activeFont,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${track.artist} • ${track.album}',
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black54
                                      : Colors.white54,
                                  fontSize: 14,
                                  fontFamily: _activeFont,
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
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  _buildOptionItem(Icons.playlist_play, 'Play next', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _currentIndex + 1);
                      showFlowToast("Added to play next");
                    }
                  }),
                  _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _playbackQueue.length);
                      showFlowToast("Added to queue");
                    }
                  }),
                  _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                    Navigator.pop(context);
                    _showAddToPlaylistModal(context, [track]);
                  }),
                  _buildOptionItem(Icons.timer, 'Sleep Timer', () {
                    Navigator.pop(context);
                    _showFullSleepTimerDialog(context);
                  }),
                  _buildOptionItem(Icons.equalizer_rounded, 'Equalizer', () {
                    Navigator.pop(context);
                    MainScreen.showEqualizer(context);
                  }),
                  _buildOptionItem(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    'Favourite',
                    () {
                      _toggleFavorite(track.id);
                      setModalState(() {});
                    },
                    iconColor: isFavorited
                        ? _activeAccentColor
                        : (isLight ? Colors.black54 : Colors.white70),
                  ),
                  _buildOptionItem(Icons.album_outlined, 'Go to album', () {
                    Navigator.pop(context);
                    setState(() {
                      _isPlayerOpen = false;
                      _selectedAlbumDetail = track.album;
                      _searchQuery = '';
                      _searchController.clear();
                      final albumSongs = _allTracks
                          .where((t) => t.album == track.album)
                          .toList();
                      _detailColorFuture = _getDetailColor(
                        albumSongs.isNotEmpty ? albumSongs.first : null,
                      );
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
                      _isPlayerOpen = false;
                      _selectedArtistDetail = track.artist;
                      _searchQuery = '';
                      _searchController.clear();
                      final artistSongs = _allTracks
                          .where((t) => t.artist == track.artist)
                          .toList();
                      _detailColorFuture = _getDetailColor(
                        artistSongs.isNotEmpty ? artistSongs.first : null,
                      );
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
                  _buildOptionItem(Icons.info_outline, 'Song Info', () {
                    Navigator.pop(context);
                    _showSongInfoModal(context, track);
                  }),
                  _buildOptionItem(
                    Icons.visibility_off_outlined,
                    'Hide from library',
                    () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      _hiddenTrackIds.add(track.id);
                      await prefs.setStringList(
                        'hidden_track_ids',
                        _hiddenTrackIds.toList(),
                      );
                      setState(() {
                        _allTracks.removeWhere((t) => t.id == track.id);
                        _playbackQueue.removeWhere((t) => t.id == track.id);
                        _cachedDetailKey = null;
                      });
                      final serialized = _allTracks
                          .map((t) => t.toMap())
                          .toList();
                      await prefs.setString(
                        'cached_tracks_list',
                        jsonEncode(serialized),
                      );
                      showFlowToast("Track hidden from library");
                    },
                  ),
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
                            _cachedDetailKey = null;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          final serialized = _allTracks
                              .map((t) => t.toMap())
                              .toList();
                          await prefs.setString(
                            'cached_tracks_list',
                            jsonEncode(serialized),
                          );
                          showFlowToast("Track deleted");
                        } else {
                          showFlowToast("File not found");
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            final isLight = isAppLight;
                            return AlertDialog(
                              backgroundColor: isLight
                                  ? const Color(0xFFF0F0F3)
                                  : const Color(0xFF161616),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Permission Denied',
                                style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: _activeFont,
                                ),
                              ),
                              content: Text(
                                'Android Scoped Storage prevents Flow from directly deleting files in your device storage.\n\nWould you like to hide this track from your Flow library instead?',
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black54
                                      : Colors.white70,
                                  height: 1.4,
                                  fontFamily: _activeFont,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.black45
                                          : Colors.white54,
                                      fontFamily: _activeFont,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    _hiddenTrackIds.add(track.id);
                                    await prefs.setStringList(
                                      'hidden_track_ids',
                                      _hiddenTrackIds.toList(),
                                    );
                                    setState(() {
                                      _allTracks.removeWhere(
                                        (t) => t.id == track.id,
                                      );
                                      _playbackQueue.removeWhere(
                                        (t) => t.id == track.id,
                                      );
                                      _cachedDetailKey = null;
                                    });
                                    final serialized = _allTracks
                                        .map((t) => t.toMap())
                                        .toList();
                                    await prefs.setString(
                                      'cached_tracks_list',
                                      jsonEncode(serialized),
                                    );
                                    showFlowToast("Track hidden from library");
                                  },
                                  child: Text(
                                    'Hide Track',
                                    style: TextStyle(
                                      color: _activeAccentColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _activeFont,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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

    final isLight = isAppLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
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
                      Text(
                        'Edit Metadata',
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: _activeFont,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final String? imagePath =
                                await _showCoverSourceSelector(this.context);
                            if (imagePath != null) {
                              setModalState(() {
                                currentCoverPath = imagePath;
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.black.withValues(alpha: 0.05)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                              image: currentCoverPath != null
                                  ? DecorationImage(
                                      image: ResizeImage(
                                        FileImage(File(currentCoverPath!)),
                                        width: 600,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: currentCoverPath == null
                                ? Icon(
                                    Icons.add_a_photo,
                                    color: isLight
                                        ? Colors.black45
                                        : Colors.white54,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: _activeFont,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white54,
                            fontFamily: _activeFont,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isLight ? Colors.black12 : Colors.white24,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _activeAccentColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: artistController,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: _activeFont,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Artist',
                          labelStyle: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white54,
                            fontFamily: _activeFont,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isLight ? Colors.black12 : Colors.white24,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _activeAccentColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: albumController,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: _activeFont,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Album',
                          labelStyle: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white54,
                            fontFamily: _activeFont,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isLight ? Colors.black12 : Colors.white24,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _activeAccentColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_metadataOverrides.containsKey(track.id))
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _metadataOverrides.remove(track.id);
                                  _cachedDetailKey = null;
                                  if (_playingTrack?.id == track.id) {
                                    _updateDominantColor(_playingTrack!);
                                  }
                                });
                                _saveMetadataOverrides();
                                _requestPermissionAndScan();
                                Navigator.pop(context);
                                showFlowToast("Metadata reset to original");
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: _activeFont,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _activeAccentColor,
                              foregroundColor: Colors.white,
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
                                    duration: t.duration,
                                  );
                                }

                                if (_playingTrack?.id == track.id &&
                                    index != -1) {
                                  _playingTrack = _allTracks[index];
                                  if (currentCoverPath != null) {
                                    _updateDominantColor(_playingTrack!);
                                  }
                                }
                                _cachedDetailKey =
                                    null; // Clear cache so Lists like Recently Added auto-update
                              });
                              _saveMetadataOverrides();
                              Navigator.pop(context);
                              showFlowToast("Metadata updated locally");
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

  void _showDetailOptions(String title, String type, List<Track> tracks) {
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
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black12 : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: _activeFont,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionItem(Icons.playlist_play, 'Play Next', () {
                  Navigator.pop(context);
                  if (tracks.isNotEmpty) {
                    int insertPos = _currentIndex + 1;
                    for (final track in tracks) {
                      _moveTrackInQueue(track, insertPos);
                      insertPos++;
                    }
                    showFlowToast("Added ${tracks.length} tracks to play next");
                  }
                }),
                _buildOptionItem(Icons.queue_music, 'Add to Queue', () {
                  Navigator.pop(context);
                  if (tracks.isNotEmpty) {
                    for (final track in tracks) {
                      _moveTrackInQueue(track, _playbackQueue.length);
                    }
                    showFlowToast("Added ${tracks.length} tracks to queue");
                  }
                }),
                _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                  Navigator.pop(context);
                  _showMultiSelectSongsModal(context, candidateTracks: tracks);
                }),
                _buildOptionItem(Icons.sort_rounded, 'Sort Songs', () {
                  Navigator.pop(context);
                  _showDetailSortModal(context);
                }),
                if (type == 'Album') ...[
                  _buildOptionItem(Icons.image, 'Edit Album Cover', () async {
                    Navigator.pop(context);
                    final String? imagePath = await _showCoverSourceSelector(
                      this.context,
                    );
                    if (imagePath != null) {
                      setState(() {
                        for (final track in tracks) {
                          _metadataOverrides[track.id] ??= {
                            'title': track.title,
                            'artist': track.artist,
                            'album': track.album,
                          };
                          _metadataOverrides[track.id]!['coverPath'] =
                              imagePath;
                        }
                        _cachedDetailKey =
                            null; // Force rebuild to show new cover
                      });
                      _saveMetadataOverrides();
                      if (_playingTrack != null &&
                          tracks.any((t) => t.id == _playingTrack!.id)) {
                        _updateDominantColor(_playingTrack!);
                      }
                      showFlowToast("Album cover updated locally");
                    }
                  }),
                ],
                if (type == 'Playlist') ...[
                  _buildOptionItem(Icons.image, 'Edit Cover', () async {
                    Navigator.pop(context);
                    final String? imagePath = await _showCoverSourceSelector(
                      this.context,
                    );
                    if (imagePath != null) {
                      setState(() {
                        _playlistCovers[title] = imagePath;
                        _cachedDetailKey =
                            null; // Force rebuild to show new cover
                      });
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString(
                          'playlist_covers',
                          jsonEncode(_playlistCovers),
                        );
                      });
                    }
                  }),
                ],
                if (type == 'Playlist' &&
                    _userPlaylists.containsKey(title)) ...[
                  _buildOptionItem(Icons.edit_note_rounded, 'Edit Songs', () {
                    Navigator.pop(context);
                    _showEditPlaylistSongsModal(context, title);
                  }),
                  _buildOptionItem(Icons.add, 'Add Songs', () {
                    Navigator.pop(context);
                    _showMultiSelectSongsModal(
                      context,
                      candidateTracks: _allTracks,
                      predefinedTargetPlaylist: title,
                    );
                  }),
                  _buildOptionItem(Icons.edit, 'Rename Playlist', () {
                    Navigator.pop(context);
                    _showRenamePlaylistModal(context, title);
                  }),
                  _buildOptionItem(Icons.delete_outline, 'Delete Playlist', () {
                    Navigator.pop(context);
                    setState(() {
                      _userPlaylists.remove(title);
                      _playlistCovers.remove(title);
                      _selectedPlaylistDetail = null;
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString(
                        'user_playlists',
                        jsonEncode(_userPlaylists),
                      );
                      prefs.setString(
                        'playlist_covers',
                        jsonEncode(_playlistCovers),
                      );
                    });
                  }, iconColor: Colors.red),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildSortItem(String value, String label, IconData icon) {
              final isSelected = _sortBy == value;
              return ListTile(
                onTap: () async {
                  final nav = Navigator.of(context);
                  setState(() {
                    _sortBy = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('sortBy', value);
                  nav.pop();
                },
                leading: Icon(
                  icon,
                  color: isSelected
                      ? _activeAccentColor
                      : (isLight ? Colors.black54 : Colors.white60),
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? _activeAccentColor
                        : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontFamily: _activeFont,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: _activeAccentColor)
                    : null,
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Sort by',
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  buildSortItem(
                    'date',
                    'Recently Added (Default)',
                    Icons.calendar_today_rounded,
                  ),
                  buildSortItem(
                    'date_oldest',
                    'Oldest Added first',
                    Icons.history_toggle_off_rounded,
                  ),
                  buildSortItem(
                    'title',
                    'Title (A to Z)',
                    Icons.sort_by_alpha_rounded,
                  ),
                  buildSortItem(
                    'artist',
                    'Artist (A to Z)',
                    Icons.person_search_rounded,
                  ),
                  buildSortItem('album', 'Album (A to Z)', Icons.album_rounded),
                  buildSortItem(
                    'duration_longest',
                    'Duration (Longest first)',
                    Icons.hourglass_top_rounded,
                  ),
                  buildSortItem(
                    'duration_shortest',
                    'Duration (Shortest first)',
                    Icons.hourglass_bottom_rounded,
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

  void _showDetailSortModal(BuildContext context) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildSortItem(String value, String label, IconData icon) {
              final isSelected = _detailSortBy == value;
              return ListTile(
                onTap: () async {
                  final nav = Navigator.of(context);
                  setState(() {
                    _detailSortBy = value;
                    _cachedDetailKey =
                        null; // Invalidate cache to force instant resort
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('detailSortBy', value);
                  nav.pop();
                },
                leading: Icon(
                  icon,
                  color: isSelected
                      ? _activeAccentColor
                      : (isLight ? Colors.black54 : Colors.white60),
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? _activeAccentColor
                        : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontFamily: _activeFont,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: _activeAccentColor)
                    : null,
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Sort songs in view',
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  buildSortItem(
                    'default',
                    'Default Track Order',
                    Icons.playlist_play,
                  ),
                  buildSortItem(
                    'title',
                    'Title (A to Z)',
                    Icons.sort_by_alpha_rounded,
                  ),
                  buildSortItem(
                    'artist',
                    'Artist (A to Z)',
                    Icons.person_search_rounded,
                  ),
                  buildSortItem(
                    'duration_longest',
                    'Duration (Longest first)',
                    Icons.hourglass_top_rounded,
                  ),
                  buildSortItem(
                    'duration_shortest',
                    'Duration (Shortest first)',
                    Icons.hourglass_bottom_rounded,
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

  void _showSongInfoModal(BuildContext context, Track track) {
    final isLight = isAppLight;
    final format = track.path.split('.').last.toUpperCase();
    final fileName = track.path.split('/').last;

    String formatDuration(int ms) {
      final minutes = (ms / 60000).floor();
      final seconds = ((ms % 60000) / 1000).floor();
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    Future<String> getFileSize() async {
      try {
        final file = File(track.path);
        if (await file.exists()) {
          final bytes = await file.length();
          if (bytes < 1024) return '$bytes B';
          final kb = bytes / 1024;
          if (kb < 1024) return '${kb.toStringAsFixed(2)} KB';
          final mb = kb / 1024;
          return '${mb.toStringAsFixed(2)} MB';
        }
      } catch (_) {}
      return 'Unknown';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Song Info',
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isLight ? Colors.black54 : Colors.white54,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTrackArtwork(track, size: 54, radius: 10),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: _activeFont,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artist,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                                fontSize: 13,
                                fontFamily: _activeFont,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.album,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black38
                                    : Colors.white38,
                                fontSize: 12,
                                fontFamily: _activeFont,
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
                const SizedBox(height: 20),
                _buildInfoRow(context, 'File Name', fileName, isLight),
                _buildInfoRow(
                  context,
                  'Format',
                  format,
                  isLight,
                  isBadge: true,
                ),
                _buildInfoRow(
                  context,
                  'Duration',
                  formatDuration(track.duration),
                  isLight,
                ),
                FutureBuilder<String>(
                  future: getFileSize(),
                  builder: (context, snapshot) {
                    return _buildInfoRow(
                      context,
                      'Size',
                      snapshot.data ?? 'Loading...',
                      isLight,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'File Path',
                  style: TextStyle(
                    color: isLight ? Colors.black38 : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: _activeFont,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          track.path,
                          style: TextStyle(
                            color: isLight ? Colors.black87 : Colors.white70,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: _activeAccentColor,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: track.path));
                          showFlowToast("Path copied to clipboard");
                        },
                        tooltip: 'Copy path',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isLight
                              ? Colors.black.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditMetadataModal(context, track);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                      label: Text(
                        'Edit Metadata',
                        style: TextStyle(
                          color: isLight ? Colors.black87 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: _activeFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    bool isLight, {
    bool isBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isLight ? Colors.black54 : Colors.white54,
              fontSize: 13,
              fontFamily: _activeFont,
            ),
          ),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _activeAccentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: _activeAccentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: _activeFont,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: isLight ? const Color(0xFF1A1A1A) : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: _activeFont,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Future<String?> _showCoverSourceSelector(BuildContext context) async {
    final isLight = isAppLight;
    return await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight ? Colors.black12 : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: _activeFont,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionItem(Icons.photo_library, 'Choose from Gallery', () {
                Navigator.pop(context, 'gallery');
              }),
              _buildOptionItem(
                Icons.music_note,
                'Choose from Another Song',
                () {
                  Navigator.pop(context, 'song');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).then((source) async {
      if (source == 'gallery') {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        return image?.path;
      } else if (source == 'song') {
        if (!context.mounted) return null;
        return await _showSongCoverPicker(context);
      }
      return null;
    });
  }

  Future<String?> _showSongCoverPicker(BuildContext context) async {
    final isLight = isAppLight;
    String searchQuery = '';
    return await showModalBottomSheet<String?>(
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
            final filteredTracks = _allTracks
                .where(
                  (t) =>
                      t.title.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      t.artist.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black12 : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Song Cover',
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        onChanged: (val) =>
                            setModalState(() => searchQuery = val),
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: _activeFont,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search songs...',
                          hintStyle: TextStyle(
                            color: isLight ? Colors.black54 : Colors.white54,
                            fontFamily: _activeFont,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isLight ? Colors.black54 : Colors.white54,
                          ),
                          filled: true,
                          fillColor: isLight
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredTracks.length,
                        itemBuilder: (context, index) {
                          final track = filteredTracks[index];
                          return ListTile(
                            leading: _buildTrackArtwork(
                              track,
                              size: 40,
                              radius: 8,
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontFamily: _activeFont,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                                fontFamily: _activeFont,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              final coverUri = await _getCoverUriForTrack(
                                track,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context); // pop loading
                              if (coverUri != null &&
                                  coverUri.isScheme('file')) {
                                if (!context.mounted) return;
                                Navigator.pop(context, coverUri.toFilePath());
                              } else {
                                showFlowToast(
                                  "No cover available for this song",
                                );
                              }
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
      },
    );
  }
}
