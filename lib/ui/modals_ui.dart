// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsUI on _MainScreenState {
  void _showTrackOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${track.artist} • ${track.album}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
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
                  const Divider(color: Colors.white10, height: 1),
                  _buildOptionItem(Icons.playlist_play, 'Play next', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _currentIndex + 1);
                      Fluttertoast.showToast(msg: "Added to play next");
                    }
                  }),
                  _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                    Navigator.pop(context);
                    if (_playbackQueue.isNotEmpty) {
                      _moveTrackInQueue(track, _playbackQueue.length);
                      Fluttertoast.showToast(msg: "Added to queue");
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
                  _buildOptionItem(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    'Favourite',
                    () {
                      _toggleFavorite(track.id);
                      setModalState(() {});
                    },
                    iconColor: isFavorited
                        ? const Color(0xFF1DB954)
                        : Colors.white,
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
                      Fluttertoast.showToast(msg: "Track hidden from library");
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
                          Fluttertoast.showToast(msg: "Track deleted");
                        } else {
                          Fluttertoast.showToast(msg: "File not found");
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF161616),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Permission Denied',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Android Scoped Storage prevents Tunza from directly deleting files in your device storage.\n\nWould you like to hide this track from your Tunza library instead?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
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
                                    Fluttertoast.showToast(
                                      msg: "Track hidden from library",
                                    );
                                  },
                                  child: const Text(
                                    'Hide Track',
                                    style: TextStyle(
                                      color: Color(0xFF1DB954),
                                      fontWeight: FontWeight.bold,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Songs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                                      Fluttertoast.showToast(
                                        msg:
                                            "Added ${selectedTrackIds.length} songs to $predefinedTargetPlaylist",
                                      );
                                    } else {
                                      // Prompt for playlist selection
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
                                    ? Colors.white24
                                    : const Color(0xFF1DB954),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10),
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
                              style: const TextStyle(color: Colors.white),
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
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF1DB954),
                              checkColor: Colors.black,
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

  void _showAddToPlaylistModal(BuildContext context, List<Track> tracksToAdd) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Add to Playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.add, color: Color(0xFF1DB954)),
                    title: const Text(
                      'Create New Playlist',
                      style: TextStyle(color: Color(0xFF1DB954)),
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
                    const Divider(color: Colors.white10, height: 1),
                  ..._userPlaylists.keys.map((playlistName) {
                    return ListTile(
                      leading: const Icon(
                        Icons.queue_music,
                        color: Colors.white,
                      ),
                      title: Text(
                        playlistName,
                        style: const TextStyle(color: Colors.white),
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
                            Fluttertoast.showToast(
                              msg:
                                  "'${tracksToAdd.first.title}' is already in $playlistName",
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  "Added '${tracksToAdd.first.title}' to $playlistName",
                            );
                          }
                        } else {
                          if (addedCount == 0) {
                            Fluttertoast.showToast(
                              msg:
                                  "Selected songs are already in $playlistName",
                            );
                          } else if (skippedCount > 0) {
                            Fluttertoast.showToast(
                              msg:
                                  "Added $addedCount songs to $playlistName ($skippedCount skipped)",
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Added $addedCount songs to $playlistName",
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'New Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
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
                  Fluttertoast.showToast(msg: "Playlist '$name' created");
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Color(0xFF1DB954)),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                      const Text(
                        'Edit Metadata',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                              color: Colors.white10,
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
                                ? const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white54,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: artistController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Artist',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: albumController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Album',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1DB954)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
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
                              Fluttertoast.showToast(
                                msg: "Metadata updated locally",
                              );
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Rename Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'New playlist name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
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
                  Fluttertoast.showToast(msg: "Playlist renamed");
                } else if (_userPlaylists.containsKey(newName)) {
                  Fluttertoast.showToast(msg: "Playlist name already exists");
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailOptions(String title, String type, List<Track> tracks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                  Fluttertoast.showToast(
                    msg: "Added ${tracks.length} tracks to play next",
                  );
                }
              }),
              _buildOptionItem(Icons.queue_music, 'Add to Queue', () {
                Navigator.pop(context);
                if (tracks.isNotEmpty) {
                  for (final track in tracks) {
                    _moveTrackInQueue(track, _playbackQueue.length);
                  }
                  Fluttertoast.showToast(
                    msg: "Added ${tracks.length} tracks to queue",
                  );
                }
              }),
              _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                Navigator.pop(context);
                _showMultiSelectSongsModal(context, candidateTracks: tracks);
              }),
              if (type == 'Playlist' && _userPlaylists.containsKey(title)) ...[
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

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildOptionItem(Icons.play_arrow, 'Play all', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playTrack(0, sourceList: songs);
                } else {
                  Fluttertoast.showToast(msg: "Playlist is empty");
                }
              }),
              _buildOptionItem(Icons.queue_music, 'Add to queue', () {
                Navigator.pop(context);
                if (songs.isNotEmpty) {
                  _playbackQueue.addAll(songs);
                  Fluttertoast.showToast(
                    msg: "Added ${songs.length} songs to queue",
                  );
                }
              }),
              _buildOptionItem(Icons.playlist_add, 'Add to Playlist', () {
                Navigator.pop(context);
                _showMultiSelectSongsModal(context, candidateTracks: songs);
              }),
              if (isCustomPlaylist) ...[
                const Divider(color: Colors.white10, height: 1),
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
                    Fluttertoast.showToast(msg: "Playlist cover updated");
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
                    Fluttertoast.showToast(msg: "Playlist deleted");
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
              const Center(
                child: Text(
                  'Sleep timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
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
            return FutureBuilder<List<SongModel>>(
              future: queryFuture,
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

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No music folders found',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
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
                            'Specific Folder Scan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                              child: const Text(
                                'Reset Filter',
                                style: TextStyle(
                                  color: Color(0xFF1DB954),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select which folders to display in your library. Unselected folders will be hidden.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
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
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                activeThumbColor: const Color(0xFF1DB954),
                                activeTrackColor: const Color(
                                  0xFF1DB954,
                                ).withValues(alpha: 0.2),
                                inactiveThumbColor: Colors.white24,
                                inactiveTrackColor: Colors.white12,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.folder,
                                      color: Color(0xFF1DB954),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${songsInFolder.length}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
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
                                    style: const TextStyle(
                                      color: Colors.white30,
                                      fontSize: 11,
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
}
