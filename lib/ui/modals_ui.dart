// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsUI on _MainScreenState {
  void _showTrackOptions(BuildContext context, Track track) {
    final isLight = themeModeNotifier.value == 'light';
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
                        ? Colors.black.withOpacity(0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  _buildOptionItem(Icons.playlist_play, 'Play next', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _currentIndex + 1);
                      showTunzaToast("Added to play next");
                    }
                  }),
                  _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _playbackQueue.length);
                      showTunzaToast("Added to queue");
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
                      showTunzaToast("Track hidden from library");
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
                          showTunzaToast("Track deleted");
                        } else {
                          showTunzaToast("File not found");
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            final isLight = themeModeNotifier.value == 'light';
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
                                'Android Scoped Storage prevents Tunza from directly deleting files in your device storage.\n\nWould you like to hide this track from your Tunza library instead?',
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
                                    showTunzaToast("Track hidden from library");
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

  void _showMultiSelectSongsModal(
    BuildContext context, {
    required List<Track> candidateTracks,
    String? predefinedTargetPlaylist,
  }) {
    Set<String> selectedTrackIds = {};

    final isLight = themeModeNotifier.value == 'light';

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Songs',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: _activeFont,
                            ),
                          ),
                          TextButton(
                            onPressed: selectedTrackIds.isEmpty
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    final selectedTracks = candidateTracks
                                        .where(
                                          (t) =>
                                              selectedTrackIds.contains(t.id),
                                        )
                                        .toList();
                                    if (predefinedTargetPlaylist != null) {
                                      setState(() {
                                        _userPlaylists[predefinedTargetPlaylist]!
                                            .addAll(selectedTrackIds);
                                        _cachedDetailKey = null;
                                        _saveUserPlaylists();
                                      });
                                      showTunzaToast(
                                        "Added ${selectedTrackIds.length} songs to $predefinedTargetPlaylist",
                                      );
                                    } else {
                                      _showAddToPlaylistModal(
                                        context,
                                        selectedTracks,
                                      );
                                    }
                                  },
                            child: Text(
                              predefinedTargetPlaylist != null
                                  ? 'Save'
                                  : 'Next',
                              style: TextStyle(
                                color: selectedTrackIds.isEmpty
                                    ? (isLight
                                          ? Colors.black12
                                          : Colors.white24)
                                    : _activeAccentColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withOpacity(0.08)
                          : Colors.white10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: candidateTracks.length,
                        itemBuilder: (context, index) {
                          final track = candidateTracks[index];
                          final isSelected = selectedTrackIds.contains(
                            track.id,
                          );
                          return ListTile(
                            leading: _buildTrackArtwork(
                              track,
                              size: 44,
                              radius: 6,
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
                                fontSize: 12,
                                fontFamily: _activeFont,
                              ),
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: _activeAccentColor,
                              checkColor: isLight ? Colors.white : Colors.black,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    selectedTrackIds.add(track.id);
                                  } else {
                                    selectedTrackIds.remove(track.id);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedTrackIds.remove(track.id);
                                } else {
                                  selectedTrackIds.add(track.id);
                                }
                              });
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

  void _showEditPlaylistSongsModal(BuildContext context, String playlistName) {
    final trackIds = _userPlaylists[playlistName] ?? <String>[];
    final playlistSongs = _allTracks
        .where((t) => trackIds.contains(t.id))
        .toList();

    Set<String> selectedForDeletion = {};
    final isLight = themeModeNotifier.value == 'light';

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
            final hasSelection = selectedForDeletion.isNotEmpty;
            final isAllSelected =
                playlistSongs.isNotEmpty &&
                selectedForDeletion.length == playlistSongs.length;

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Edit "$playlistName"',
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: _activeFont,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: _activeAccentColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withOpacity(0.08)
                          : Colors.white10,
                    ),

                    // Toolbar for Add Songs, Select All, and Delete
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Add Songs Pill
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showMultiSelectSongsModal(
                                context,
                                candidateTracks: _allTracks,
                                predefinedTargetPlaylist: playlistName,
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: isLight ? Colors.black87 : Colors.white,
                            ),
                            label: Text(
                              'Add Songs',
                              style: TextStyle(
                                color: isLight ? Colors.black87 : Colors.white,
                                fontSize: 12,
                                fontFamily: _activeFont,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isLight
                                    ? Colors.black12
                                    : Colors.white24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Select All text
                          TextButton(
                            onPressed: playlistSongs.isEmpty
                                ? null
                                : () {
                                    setModalState(() {
                                      if (isAllSelected) {
                                        selectedForDeletion.clear();
                                      } else {
                                        selectedForDeletion = playlistSongs
                                            .map((t) => t.id)
                                            .toSet();
                                      }
                                    });
                                  },
                            child: Text(
                              isAllSelected ? 'Deselect All' : 'Select All',
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 12,
                                fontFamily: _activeFont,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Delete Selected button (trash bin)
                          IconButton(
                            onPressed: !hasSelection
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: isLight
                                            ? const Color(0xFFF0F0F3)
                                            : const Color(0xFF1E1E1E),
                                        title: Text(
                                          'Remove Songs?',
                                          style: TextStyle(
                                            color: isLight
                                                ? const Color(0xFF1A1A1A)
                                                : Colors.white,
                                            fontFamily: _activeFont,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to remove ${selectedForDeletion.length} songs from "$playlistName"?',
                                          style: TextStyle(
                                            color: isLight
                                                ? Colors.black54
                                                : Colors.white70,
                                            fontFamily: _activeFont,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: isLight
                                                    ? Colors.black38
                                                    : Colors.white38,
                                                fontFamily: _activeFont,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              setState(() {
                                                _userPlaylists[playlistName]!
                                                    .removeWhere(
                                                      (id) =>
                                                          selectedForDeletion
                                                              .contains(id),
                                                    );
                                                _cachedDetailKey = null;
                                                _saveUserPlaylists();
                                              });
                                              Navigator.pop(
                                                context,
                                              ); // Close sheet
                                              showTunzaToast(
                                                'Removed ${selectedForDeletion.length} songs',
                                              );
                                            },
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: _activeFont,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Icons.delete_outline,
                              color: hasSelection
                                  ? Colors.redAccent
                                  : (isLight ? Colors.black12 : Colors.white24),
                            ),
                            tooltip: 'Delete Selected',
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withOpacity(0.08)
                          : Colors.white10,
                    ),

                    Expanded(
                      child: playlistSongs.isEmpty
                          ? Center(
                              child: Text(
                                'No songs in playlist',
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black38
                                      : Colors.white30,
                                  fontFamily: _activeFont,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: playlistSongs.length,
                              itemBuilder: (context, index) {
                                final track = playlistSongs[index];
                                final isSelected = selectedForDeletion.contains(
                                  track.id,
                                );
                                return ListTile(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedForDeletion.remove(track.id);
                                      } else {
                                        selectedForDeletion.add(track.id);
                                      }
                                    });
                                  },
                                  leading: _buildTrackArtwork(
                                    track,
                                    size: 44,
                                    radius: 6,
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
                                      fontSize: 12,
                                      fontFamily: _activeFont,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    activeColor: Colors.redAccent,
                                    onChanged: (val) {
                                      setModalState(() {
                                        if (isSelected) {
                                          selectedForDeletion.remove(track.id);
                                        } else {
                                          selectedForDeletion.add(track.id);
                                        }
                                      });
                                    },
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

  void _showAddToPlaylistModal(BuildContext context, List<Track> tracksToAdd) {
    final isLight = themeModeNotifier.value == 'light';
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
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Add to Playlist',
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: _activeFont,
                      ),
                    ),
                  ),
                  Divider(
                    color: isLight
                        ? Colors.black.withOpacity(0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(Icons.add, color: _activeAccentColor),
                    title: Text(
                      'Create New Playlist',
                      style: TextStyle(
                        color: _activeAccentColor,
                        fontFamily: _activeFont,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreatePlaylistModal(
                        context,
                        tracksToAdd: tracksToAdd,
                      );
                    },
                  ),
                  if (_userPlaylists.isNotEmpty)
                    Divider(
                      color: isLight
                          ? Colors.black.withOpacity(0.08)
                          : Colors.white10,
                      height: 1,
                    ),
                  ..._userPlaylists.keys.map((playlistName) {
                    return ListTile(
                      leading: Icon(
                        Icons.queue_music,
                        color: isLight ? Colors.black54 : Colors.white70,
                      ),
                      title: Text(
                        playlistName,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: _activeFont,
                        ),
                      ),
                      onTap: () {
                        int addedCount = 0;
                        int skippedCount = 0;
                        setState(() {
                          for (final track in tracksToAdd) {
                            if (!_userPlaylists[playlistName]!.contains(
                              track.id,
                            )) {
                              _userPlaylists[playlistName]!.add(track.id);
                              addedCount++;
                            } else {
                              skippedCount++;
                            }
                          }
                          if (addedCount > 0) {
                            _cachedDetailKey = null;
                            _saveUserPlaylists();
                          }
                        });
                        Navigator.pop(context);
                        if (tracksToAdd.length == 1) {
                          if (skippedCount > 0) {
                            showTunzaToast(
                              "'${tracksToAdd.first.title}' is already in $playlistName",
                            );
                          } else {
                            showTunzaToast(
                              "Added '${tracksToAdd.first.title}' to $playlistName",
                            );
                          }
                        } else {
                          if (addedCount == 0) {
                            showTunzaToast(
                              "Selected songs are already in $playlistName",
                            );
                          } else if (skippedCount > 0) {
                            showTunzaToast(
                              "Added $addedCount songs to $playlistName ($skippedCount skipped)",
                            );
                          } else {
                            showTunzaToast(
                              "Added $addedCount songs to $playlistName",
                            );
                          }
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistModal(
    BuildContext context, {
    List<Track>? tracksToAdd,
  }) {
    final TextEditingController nameController = TextEditingController();
    final isLight = themeModeNotifier.value == 'light';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLight
              ? const Color(0xFFF0F0F3)
              : const Color(0xFF282828),
          title: Text(
            'New Playlist',
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: _activeFont,
            ),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: _activeFont,
            ),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(
                color: isLight ? Colors.black38 : Colors.white54,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isLight ? Colors.black45 : Colors.white54,
                  fontFamily: _activeFont,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty && !_userPlaylists.containsKey(name)) {
                  setState(() {
                    _userPlaylists[name] = tracksToAdd != null
                        ? tracksToAdd.map((t) => t.id).toList()
                        : [];
                    _cachedDetailKey = null;
                    _saveUserPlaylists();
                  });
                  Navigator.pop(context);
                  showTunzaToast("Playlist '$name' created");
                }
              },
              child: Text(
                'Create',
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

    final isLight = themeModeNotifier.value == 'light';

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
                            final XFile? image = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setModalState(() {
                                currentCoverPath = image.path;
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.black.withOpacity(0.05)
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
                              showTunzaToast("Metadata updated locally");
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

  void _showRenamePlaylistModal(BuildContext context, String oldName) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    final isLight = themeModeNotifier.value == 'light';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLight
              ? const Color(0xFFF0F0F3)
              : const Color(0xFF282828),
          title: Text(
            'Rename Playlist',
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: _activeFont,
            ),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: _activeFont,
            ),
            decoration: InputDecoration(
              hintText: 'New playlist name',
              hintStyle: TextStyle(
                color: isLight ? Colors.black38 : Colors.white54,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isLight ? Colors.black45 : Colors.white54,
                  fontFamily: _activeFont,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty &&
                    newName != oldName &&
                    !_userPlaylists.containsKey(newName)) {
                  setState(() {
                    final tracks = _userPlaylists.remove(oldName);
                    _userPlaylists[newName] = tracks!;
                    if (_playlistCovers.containsKey(oldName)) {
                      _playlistCovers[newName] = _playlistCovers.remove(
                        oldName,
                      )!;
                      _savePlaylistCovers();
                    }
                    if (_selectedPlaylistDetail == oldName) {
                      _selectedPlaylistDetail = newName;
                    }
                    _saveUserPlaylists();
                  });
                  Navigator.pop(context);
                  showTunzaToast("Playlist renamed");
                } else if (_userPlaylists.containsKey(newName)) {
                  showTunzaToast("Playlist name already exists");
                }
              },
              child: Text(
                'Save',
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

  void _showDetailOptions(String title, String type, List<Track> tracks) {
    final isLight = themeModeNotifier.value == 'light';
    showModalBottomSheet(
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
                  showTunzaToast("Added ${tracks.length} tracks to play next");
                }
              }),
              _buildOptionItem(Icons.queue_music, 'Add to Queue', () {
                Navigator.pop(context);
                if (tracks.isNotEmpty) {
                  for (final track in tracks) {
                    _moveTrackInQueue(track, _playbackQueue.length);
                  }
                  showTunzaToast("Added ${tracks.length} tracks to queue");
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
              if (type == 'Playlist' && _userPlaylists.containsKey(title)) ...[
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
                _buildOptionItem(Icons.image, 'Edit Cover', () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _playlistCovers[title] = image.path;
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
        );
      },
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    String title,
    List<Track> songs,
  ) {
    final isCustomPlaylist = _userPlaylists.containsKey(title);
    final isLight = themeModeNotifier.value == 'light';

    showModalBottomSheet(
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: _activeFont,
                  ),
                ),
              ),
              Divider(
                color: isLight
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white10,
                height: 1,
              ),
              _buildOptionItem(Icons.play_arrow, 'Play all', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playTrack(0, sourceList: songs);
                } else {
                  showTunzaToast("Playlist is empty");
                }
              }),
              _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playbackQueue.addAll(songs);
                  showTunzaToast("Added ${songs.length} songs to queue");
                }
              }),
              _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                Navigator.pop(context);
                _showMultiSelectSongsModal(context, candidateTracks: songs);
              }),
              if (isCustomPlaylist) ...[
                Divider(
                  color: isLight
                      ? Colors.black.withOpacity(0.08)
                      : Colors.white10,
                  height: 1,
                ),
                _buildOptionItem(Icons.add, 'Add Songs', () {
                  Navigator.pop(context);
                  _showMultiSelectSongsModal(
                    context,
                    candidateTracks: _allTracks,
                    predefinedTargetPlaylist: title,
                  );
                }),
                _buildOptionItem(Icons.edit, 'Rename playlist', () {
                  Navigator.pop(context);
                  _showRenamePlaylistModal(context, title);
                }),
                _buildOptionItem(Icons.image, 'Edit cover', () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _playlistCovers[title] = image.path;
                    });
                    _savePlaylistCovers();
                    showTunzaToast("Playlist cover updated");
                  }
                }),
                _buildOptionItem(
                  Icons.delete_outline,
                  'Delete playlist',
                  () {
                    Navigator.pop(context);
                    setState(() {
                      _userPlaylists.remove(title);
                      _playlistCovers.remove(title);
                      _savePlaylistCovers();
                      if (_selectedPlaylistDetail == title) {
                        _selectedPlaylistDetail = null;
                      }
                    });
                    _saveUserPlaylists();
                    showTunzaToast("Playlist deleted");
                  },
                  iconColor: Colors.redAccent,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFullSleepTimerDialog(BuildContext context) {
    final isLight = themeModeNotifier.value == 'light';
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
                    ? Colors.black.withOpacity(0.08)
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
    final isLight = themeModeNotifier.value == 'light';
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

    final isLight = themeModeNotifier.value == 'light';

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
                        'No music folders found',
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
                            'Specific Folder Scan',
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
                                'Reset Filter',
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
                        'Select which folders to display in your library. Unselected folders will be hidden.',
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
                                    ? Colors.black.withOpacity(0.04)
                                    : const Color(0xFF22222B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                activeThumbColor: _activeAccentColor,
                                activeTrackColor: _activeAccentColor
                                    .withOpacity(0.2),
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
                                            ? 'Root'
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
                                            ? Colors.black.withOpacity(0.05)
                                            : Colors.white.withOpacity(0.05),
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

  void _showSortModal(BuildContext context) {
    final isLight = themeModeNotifier.value == 'light';
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
                        ? Colors.black.withOpacity(0.08)
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
    final isLight = themeModeNotifier.value == 'light';
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
                        ? Colors.black.withOpacity(0.08)
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
  static const _channel = MethodChannel('com.tunza.audio/equalizer');
  bool _initialized = false;
  bool _enabled = false;
  int _bands = 0;
  int _minLevel = -1500;
  int _maxLevel = 1500;
  List<int> _frequencies = [];
  List<int> _levels = [];
  String? _error;
  String _activePreset = 'Custom';

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
        _error = "Play a song first to initialize the Equalizer!";
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
          _activePreset = prefs.getString('saved_eq_preset') ?? 'Custom';
          _initialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Equalizer is not supported on this device";
        _initialized = true;
      });
    }
  }

  Future<void> _updateBandLevel(int band, int value) async {
    if (!_enabled) return;
    setState(() {
      _levels[band] = value;
      _activePreset = 'Custom';
    });
    try {
      await _channel.invokeMethod('setBandLevel', {
        'band': band,
        'level': value,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_eq_levels', jsonEncode(_levels));
      await prefs.setString('saved_eq_preset', 'Custom');
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
                'System Equalizer',
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
                      'System Equalizer',
                      style: textStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sculpt your sound waves in real-time',
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
