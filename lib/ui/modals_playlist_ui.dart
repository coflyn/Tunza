// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsPlaylistUI on _MainScreenState {
  void _showMultiSelectSongsModal(
    BuildContext context, {
    required List<Track> candidateTracks,
    String? predefinedTargetPlaylist,
  }) {
    Set<String> selectedTrackIds = {};

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
                                      showFlowToast(
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
                          ? Colors.black.withValues(alpha: 0.08)
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
                          ? Colors.black.withValues(alpha: 0.08)
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
                                              showFlowToast(
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
                          ? Colors.black.withValues(alpha: 0.08)
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
                        ? Colors.black.withValues(alpha: 0.08)
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
                          ? Colors.black.withValues(alpha: 0.08)
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
                            showFlowToast(
                              "'${tracksToAdd.first.title}' is already in $playlistName",
                            );
                          } else {
                            showFlowToast(
                              "Added '${tracksToAdd.first.title}' to $playlistName",
                            );
                          }
                        } else {
                          if (addedCount == 0) {
                            showFlowToast(
                              "Selected songs are already in $playlistName",
                            );
                          } else if (skippedCount > 0) {
                            showFlowToast(
                              "Added $addedCount songs to $playlistName ($skippedCount skipped)",
                            );
                          } else {
                            showFlowToast(
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
    final isLight = isAppLight;
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
                  showFlowToast("Playlist '$name' created");
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

  void _showRenamePlaylistModal(BuildContext context, String oldName) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    final isLight = isAppLight;
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
                  showFlowToast("Playlist renamed");
                } else if (_userPlaylists.containsKey(newName)) {
                  showFlowToast("Playlist name already exists");
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

  void _showPlaylistOptions(
    BuildContext context,
    String title,
    List<Track> songs,
  ) {
    final isCustomPlaylist = _userPlaylists.containsKey(title);
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
                _buildOptionItem(Icons.play_arrow, 'Play all', () {
                  Navigator.pop(context);
                  if (songs.isNotEmpty) {
                    _playTrack(0, sourceList: songs);
                  } else {
                    showFlowToast("Playlist is empty");
                  }
                }),
                _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                  Navigator.pop(context);
                  if (songs.isNotEmpty) {
                    _playbackQueue.addAll(songs);
                    showFlowToast("Added ${songs.length} songs to queue");
                  }
                }),
                _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                  Navigator.pop(context);
                  _showMultiSelectSongsModal(context, candidateTracks: songs);
                }),
                _buildOptionItem(Icons.image, 'Edit cover', () async {
                  Navigator.pop(context);
                  final String? imagePath = await _showCoverSourceSelector(
                    this.context,
                  );
                  if (imagePath != null) {
                    setState(() {
                      _playlistCovers[title] = imagePath;
                    });
                    _savePlaylistCovers();
                    showFlowToast("Playlist cover updated");
                  }
                }),
                if (isCustomPlaylist) ...[
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
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
                      showFlowToast("Playlist deleted");
                    },
                    iconColor: Colors.redAccent,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
