// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _TabsUI on _MainScreenState {
  Widget _buildBodyContent() {
    if (_allTracks.isEmpty) {
      return _buildEmptyState();
    }

    final isDetailView =
        (_currentPageIndex == 1 && _selectedPlaylistDetail != null) ||
        (_currentPageIndex == 2 && _selectedArtistDetail != null) ||
        (_currentPageIndex == 3 && _selectedAlbumDetail != null);

    return PageView(
      controller: _pageController,
      physics: isDetailView
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: [
        _buildSongsTab(),
        _buildPlaylistsTab(),
        _buildArtistsTab(),
        _buildAlbumsTab(),
      ],
    );
  }

  Widget _buildSongsTab() {
    List<Track> songs = List<Track>.from(_allTracks);
    if (_searchQuery.isNotEmpty) {
      songs = songs
          .where(
            (t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.album.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_sortBy == 'title') {
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortBy == 'artist') {
      songs.sort(
        (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
      );
    } else if (_sortBy == 'album') {
      songs.sort(
        (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
      );
    } else if (_sortBy == 'date_oldest') {
      songs = songs.reversed.toList();
    } else if (_sortBy == 'duration_longest') {
      songs.sort((a, b) => b.duration.compareTo(a.duration));
    } else if (_sortBy == 'duration_shortest') {
      songs.sort((a, b) => a.duration.compareTo(b.duration));
    }

    return _buildSongList(songs);
  }

  Widget _buildPlaylistsTab() {
    final favorites = _allTracks
        .where((t) => _favoriteTrackIds.contains(t.id))
        .toList();
    final recentlyAdded = List<Track>.from(_allTracks);
    final lastPlayed = _lastPlayedTrackIds
        .map(
          (id) => _allTracks.firstWhere(
            (t) => t.id == id,
            orElse: () => _allTracks[0],
          ),
        )
        .where((t) => _lastPlayedTrackIds.contains(t.id))
        .toList();
    var mostPlayed = List<Track>.from(_allTracks);
    mostPlayed.sort(
      (a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
    );
    mostPlayed = mostPlayed.where((t) => (_playCounts[t.id] ?? 0) > 0).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: _playingTrack != null ? 84 : 12,
      ),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _activeAccentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: _activeAccentColor),
          ),
          title: Text(
            'Create New Playlist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _activeAccentColor,
            ),
          ),
          onTap: () => _showCreatePlaylistModal(context),
        ),
        _buildPlaylistCard(
          'Favourites',
          favorites,
          const Color(0xFFE91E63),
          Icons.favorite,
        ),
        _buildPlaylistCard(
          'Recently Added',
          recentlyAdded,
          const Color(0xFF2196F3),
          Icons.new_releases,
        ),
        _buildPlaylistCard(
          'Last Played',
          lastPlayed,
          const Color(0xFFFF9800),
          Icons.history,
        ),
        _buildPlaylistCard(
          'Most Played',
          mostPlayed,
          const Color(0xFFF44336),
          Icons.local_fire_department,
        ),
        if (_userPlaylists.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
            child: Text(
              'My Playlists',
              style: TextStyle(
                color: themeModeNotifier.value == 'light'
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ..._userPlaylists.entries.map((entry) {
          final songs = _allTracks
              .where((t) => entry.value.contains(t.id))
              .toList();
          return _buildPlaylistCard(
            entry.key,
            songs,
            const Color(0xFF9C27B0),
            Icons.queue_music,
          );
        }),
      ],
    );
  }

  Widget _buildArtistsTab() {
    final List<String> artists = [];
    final seenArtists = <String>{};

    if (_sortBy == 'date') {
      for (final t in _allTracks) {
        if (seenArtists.add(t.artist)) {
          artists.add(t.artist);
        }
      }
    } else if (_sortBy == 'date_oldest') {
      for (final t in _allTracks.reversed) {
        if (seenArtists.add(t.artist)) {
          artists.add(t.artist);
        }
      }
    } else if (_sortBy == 'duration_longest') {
      final Map<String, int> maxDuration = {};
      for (final t in _allTracks) {
        final current = maxDuration[t.artist] ?? 0;
        if (t.duration > current) {
          maxDuration[t.artist] = t.duration;
        }
      }
      final allUnique = _allTracks.map((t) => t.artist).toSet().toList();
      allUnique.sort(
        (a, b) => (maxDuration[b] ?? 0).compareTo(maxDuration[a] ?? 0),
      );
      artists.addAll(allUnique);
    } else if (_sortBy == 'duration_shortest') {
      final Map<String, int> minDuration = {};
      for (final t in _allTracks) {
        final current = minDuration[t.artist] ?? 99999999;
        if (t.duration < current) {
          minDuration[t.artist] = t.duration;
        }
      }
      final allUnique = _allTracks.map((t) => t.artist).toSet().toList();
      allUnique.sort(
        (a, b) => (minDuration[a] ?? 0).compareTo(minDuration[b] ?? 0),
      );
      artists.addAll(allUnique);
    } else {
      final allUnique = _allTracks.map((t) => t.artist).toSet().toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      artists.addAll(allUnique);
    }

    if (_searchQuery.isNotEmpty) {
      artists.retainWhere(
        (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: _playingTrack != null ? 84 : 12,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        final songCount = _allTracks.where((t) => t.artist == artist).length;
        final firstTrack = _allTracks.firstWhere((t) => t.artist == artist);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedArtistDetail = artist;
              _searchQuery = '';
              _searchController.clear();
              final artistSongs = _allTracks
                  .where((t) => t.artist == artist)
                  .toList();
              _detailColorFuture = _getDetailColor(
                artistSongs.isNotEmpty ? artistSongs.first : null,
              );
            });
          },
          leading: _buildTrackArtwork(firstTrack, size: 44, radius: 22),
          title: Text(
            artist,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: themeModeNotifier.value == 'light'
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
            ),
          ),
          subtitle: Text(
            '$songCount songs',
            style: TextStyle(
              color: themeModeNotifier.value == 'light'
                  ? Colors.black45
                  : Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: themeModeNotifier.value == 'light'
                ? Colors.black26
                : Colors.white24,
            size: 14,
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    final List<String> albums = [];
    final seenAlbums = <String>{};

    if (_sortBy == 'date') {
      for (final t in _allTracks) {
        if (seenAlbums.add(t.album)) {
          albums.add(t.album);
        }
      }
    } else if (_sortBy == 'date_oldest') {
      for (final t in _allTracks.reversed) {
        if (seenAlbums.add(t.album)) {
          albums.add(t.album);
        }
      }
    } else if (_sortBy == 'duration_longest') {
      final Map<String, int> maxDuration = {};
      for (final t in _allTracks) {
        final current = maxDuration[t.album] ?? 0;
        if (t.duration > current) {
          maxDuration[t.album] = t.duration;
        }
      }
      final allUnique = _allTracks.map((t) => t.album).toSet().toList();
      allUnique.sort(
        (a, b) => (maxDuration[b] ?? 0).compareTo(maxDuration[a] ?? 0),
      );
      albums.addAll(allUnique);
    } else if (_sortBy == 'duration_shortest') {
      final Map<String, int> minDuration = {};
      for (final t in _allTracks) {
        final current = minDuration[t.album] ?? 99999999;
        if (t.duration < current) {
          minDuration[t.album] = t.duration;
        }
      }
      final allUnique = _allTracks.map((t) => t.album).toSet().toList();
      allUnique.sort(
        (a, b) => (minDuration[a] ?? 0).compareTo(minDuration[b] ?? 0),
      );
      albums.addAll(allUnique);
    } else {
      final allUnique = _allTracks.map((t) => t.album).toSet().toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      albums.addAll(allUnique);
    }

    if (_searchQuery.isNotEmpty) {
      albums.retainWhere(
        (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: _playingTrack != null ? 84 : 12,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final songCount = _allTracks.where((t) => t.album == album).length;
        final firstTrack = _allTracks.firstWhere((t) => t.album == album);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () {
            setState(() {
              _selectedAlbumDetail = album;
              _searchQuery = '';
              _searchController.clear();
              final albumSongs = _allTracks
                  .where((t) => t.album == album)
                  .toList();
              _detailColorFuture = _getDetailColor(
                albumSongs.isNotEmpty ? albumSongs.first : null,
              );
            });
          },
          leading: _buildTrackArtwork(firstTrack, size: 44, radius: 6),
          title: Text(
            album,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: themeModeNotifier.value == 'light'
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
            ),
          ),
          subtitle: Text(
            '$songCount songs',
            style: TextStyle(
              color: themeModeNotifier.value == 'light'
                  ? Colors.black45
                  : Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: themeModeNotifier.value == 'light'
                ? Colors.black26
                : Colors.white24,
            size: 14,
          ),
        );
      },
    );
  }

  Widget _buildSongList(
    List<Track> list, {
    Widget? header,
    bool isMostPlayed = false,
    ScrollController? controller,
  }) {
    if (list.isEmpty && header == null) {
      return Center(
        child: Text(
          'No matching songs found',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: _playingTrack != null ? 84 : 12,
      ),
      itemCount: list.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final trackIndex = header != null ? index - 1 : index;
        final track = list[trackIndex];
        final isSelected =
            _playingTrack != null && track.id == _playingTrack!.id;

        return Container(
          key: ValueKey("list_item_${track.id}"),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            onTap: () {
              _updatePlayingFrom();
              _playTrack(trackIndex, sourceList: list);
            },
            leading: _buildTrackArtwork(track, size: 44, radius: 6),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected
                    ? _activeAccentColor
                    : (themeModeNotifier.value == 'light'
                          ? const Color(0xFF1A1A1A)
                          : Colors.white),
              ),
            ),
            subtitle: Text(
              isMostPlayed
                  ? '${_playCounts[track.id] ?? 0} plays • ${track.artist}'
                  : track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: themeModeNotifier.value == 'light'
                    ? Colors.black45
                    : Colors.white38,
                fontSize: 12,
              ),
            ),
            trailing: Transform.translate(
              offset: const Offset(8, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    MiniMusicVisualizer(
                      color: _activeAccentColor,
                      width: 4,
                      height: 14,
                      radius: 2,
                      animate: _isPlaying,
                    )
                  else
                    Text(
                      _formatDuration(Duration(milliseconds: track.duration)),
                      style: TextStyle(
                        color: themeModeNotifier.value == 'light'
                            ? Colors.black45
                            : Colors.white38,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: themeModeNotifier.value == 'light'
                          ? Colors.black45
                          : Colors.white54,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showTrackOptions(context, track),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final isLight = themeModeNotifier.value == 'light';
    final searchBgColor = isLight
        ? Colors.black.withOpacity(0.05)
        : const Color(0xFF161616);
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final hintColor = isLight
        ? Colors.black38
        : Colors.white.withValues(alpha: 0.3);
    final iconColor = isLight ? Colors.black45 : Colors.white54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: searchBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (val) {
                  _searchQuery = val;
                  _filterSongs();
                },
                style: TextStyle(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, or albums...',
                  hintStyle: TextStyle(color: hintColor, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: iconColor, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery = '';
                            _filterSongs();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showSortModal(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: searchBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sort_rounded,
                color: isLight ? Colors.black87 : Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCapsules() {
    final isLight = themeModeNotifier.value == 'light';
    final filters = ['Songs', 'Playlists', 'Artists', 'Albums'];
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: SizedBox(
        height: 32,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = _currentPageIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == filters.length - 1 ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isLight ? const Color(0xFF1A1A1A) : Colors.white)
                        : (isLight
                              ? Colors.black.withOpacity(0.05)
                              : const Color(0xFF161616)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? (isLight ? Colors.white : Colors.black)
                            : (isLight ? Colors.black54 : Colors.white70),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
