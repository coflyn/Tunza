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
              color: const Color(0xFF1DB954).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Color(0xFF1DB954)),
          ),
          title: const Text(
            'Create New Playlist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1DB954),
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
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8, left: 8),
            child: Text(
              'My Playlists',
              style: TextStyle(
                color: Colors.white,
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
    final artists = _allTracks.map((t) => t.artist).toSet().toList();
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '$songCount songs',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
            size: 14,
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    final albums = _allTracks.map((t) => t.album).toSet().toList();
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '$songCount songs',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
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
            onTap: () => _playTrack(trackIndex, sourceList: list),
            leading: _buildTrackArtwork(track, size: 44, radius: 6),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? const Color(0xFF1DB954) : Colors.white,
              ),
            ),
            subtitle: Text(
              isMostPlayed
                  ? '${_playCounts[track.id] ?? 0} plays • ${track.artist}'
                  : track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Transform.translate(
              offset: const Offset(8, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    MiniMusicVisualizer(
                      color: const Color(0xFF1DB954),
                      width: 4,
                      height: 14,
                      radius: 2,
                      animate: _isPlaying,
                    )
                  else
                    Text(
                      _formatDuration(Duration(milliseconds: track.duration)),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white54,
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
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (val) {
          _searchQuery = val;
          _filterSongs();
        },
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, or albums...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 16,
                  ),
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
    );
  }

  Widget _buildFilterCapsules() {
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
                    color: isSelected ? Colors.white : const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
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
