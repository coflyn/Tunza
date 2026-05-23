// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _PlayerUI on _MainScreenState {
  Widget _buildMiniPlayer(Track currentTrack) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => setState(() => _isPlayerOpen = true),
        onVerticalDragStart: (details) {
          setState(() {
            _isDraggingPlayer = true;
            _isPlayerOpen = true;
            _playerDragOffset = 1.0;
          });
        },
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta != null) {
            setState(() {
              _playerDragOffset +=
                  details.primaryDelta! / MediaQuery.of(context).size.height;
              if (_playerDragOffset < 0) _playerDragOffset = 0;
              if (_playerDragOffset > 1) _playerDragOffset = 1;
            });
          }
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDraggingPlayer = false;
            if (_playerDragOffset < 0.85 ||
                (details.primaryVelocity ?? 0) < -300) {
              _isPlayerOpen = true;
              _playerDragOffset = 0.0;
            } else {
              _isPlayerOpen = false;
              _playerDragOffset = 0.0;
            }
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _isDraggingPlayer = false;
            _isPlayerOpen = false;
            _playerDragOffset = 0.0;
          });
        },
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: const Color(0xFF161616),
            end: _dominantColor != null
                ? Color.lerp(const Color(0xFF161616), _dominantColor, 0.4)
                : const Color(0xFF161616),
          ),
          duration: const Duration(milliseconds: 500),
          builder: (context, Color? color, child) {
            return Container(
              height: 60,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              _buildTrackArtwork(currentTrack, size: 44, radius: 6),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTrack.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _playPrevious(),
              ),
              _processingState == ProcessingState.loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (_isPlaying) {
                          _pauseWithFade();
                        } else {
                          _playWithFade();
                        }
                      },
                    ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _playNext(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsOverlay(Track currentTrack) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      bottom: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lyrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showLyrics = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _audioPlayer.duration ?? Duration.zero;
                      final ratio = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;
                      final highlightedIndex =
                          (ratio * currentTrack.lyrics.length).floor();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_lyricsScrollController.hasClients) {
                          final targetOffset = highlightedIndex * 42.0;
                          _lyricsScrollController.animateTo(
                            targetOffset.clamp(
                              0.0,
                              _lyricsScrollController.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: _lyricsScrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentTrack.lyrics.length,
                        itemBuilder: (context, index) {
                          final lyric = currentTrack.lyrics[index];
                          final isHighlighted = index == highlightedIndex;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              lyric,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isHighlighted
                                    ? const Color(0xFF1DB954)
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildTrackArtwork(
    Track track, {
    double size = 48,
    double radius = 8,
  }) {
    final customPath = _metadataOverrides[track.id]?['coverPath'];
    if (customPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
            image: ResizeImage(FileImage(File(customPath)), width: 600),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: int.parse(track.id),
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkBorder: BorderRadius.circular(radius),
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        size: size > 100 ? 1000 : 200,
        quality: size > 100 ? 100 : 50,
        artworkQuality: size > 100 ? FilterQuality.high : FilterQuality.low,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Icon(Icons.music_note, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildFullScreenPlayer(Track currentTrack) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          setState(() {
            _isDraggingPlayer = true;
          });
        },
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta != null) {
            setState(() {
              _playerDragOffset +=
                  details.primaryDelta! / MediaQuery.of(context).size.height;
              if (_playerDragOffset < 0) _playerDragOffset = 0;
            });
          }
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDraggingPlayer = false;
            if (_playerDragOffset > 0.15 ||
                (details.primaryVelocity ?? 0) > 300) {
              _isPlayerOpen = false;
              _showLyrics = false;
            }
            _playerDragOffset = 0.0;
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _isDraggingPlayer = false;
            _playerDragOffset = 0.0;
          });
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFF0A0A0A))),
            Positioned.fill(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: const Color(0xFF1E1E1E),
                  end: _dominantColor ?? const Color(0xFF1E1E1E),
                ),
                duration: const Duration(milliseconds: 800),
                builder: (context, Color? color, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color ?? const Color(0xFF1E1E1E),
                          color != null
                              ? Color.lerp(color, Colors.black, 0.85)!
                              : const Color(0xFF0A0A0A),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                            size: 28,
                          ),
                          onPressed: () =>
                              setState(() => _isPlayerOpen = false),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _sleepTimerNotifier,
                          builder: (context, remaining, child) {
                            if (remaining > 0) {
                              final mins = (remaining / 60)
                                  .floor()
                                  .toString()
                                  .padLeft(2, '0');
                              final secs = (remaining % 60).toString().padLeft(
                                2,
                                '0',
                              );
                              return Text(
                                'SLEEP IN $mins:$secs',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF1DB954),
                                  letterSpacing: 1.5,
                                ),
                              );
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "PLAYING FROM $_playingFromType",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: Colors.white38,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _playingFromName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          onPressed: () =>
                              _showTrackOptions(context, currentTrack),
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),

                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildTrackArtwork(
                          currentTrack,
                          size: MediaQuery.of(context).size.width * 0.85,
                          radius: 24,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTrack.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _favoriteTrackIds.contains(currentTrack.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _favoriteTrackIds.contains(currentTrack.id)
                                ? const Color(0xFF1DB954)
                                : Colors.white60,
                            size: 26,
                          ),
                          onPressed: () => _toggleFavorite(currentTrack.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final duration = _audioPlayer.duration ?? Duration.zero;
                        final currentPosition = snapshot.data ?? Duration.zero;

                        return StatefulBuilder(
                          builder: (context, setLocalState) {
                            final displayValue =
                                _dragValue ??
                                (duration.inMilliseconds > 0
                                    ? (currentPosition.inMilliseconds /
                                              duration.inMilliseconds)
                                          .clamp(0.0, 1.0)
                                    : 0.0);

                            final displayPosition = Duration(
                              milliseconds:
                                  (displayValue * duration.inMilliseconds)
                                      .toInt(),
                            );

                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackShape: const CustomTrackShape(),
                                    trackHeight: 2.5,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 3,
                                    ),
                                    activeTrackColor: Colors.white70,
                                    inactiveTrackColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    overlayColor: Colors.transparent,
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: displayValue,
                                    onChangeStart: (val) {
                                      setLocalState(() {
                                        _dragValue = val;
                                      });
                                    },
                                    onChanged: (val) {
                                      setLocalState(() {
                                        _dragValue = val;
                                      });
                                    },
                                    onChangeEnd: (val) {
                                      final newPosition = Duration(
                                        milliseconds:
                                            (val * duration.inMilliseconds)
                                                .toInt(),
                                      );
                                      _audioPlayer.seek(newPosition);
                                      _dragValue = null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(displayPosition),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '-${_formatDuration(duration - displayPosition)}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.fast_rewind,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _playPrevious();
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_processingState == ProcessingState.loading) {
                              return;
                            }
                            if (_isPlaying) {
                              _pauseWithFade();
                            } else {
                              _playWithFade();
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _processingState == ProcessingState.loading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _playNext();
                          },
                        ),
                      ],
                    ),
                    const Spacer(),

                    Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 16,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              activeTrackColor: Colors.white60,
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _volume,
                              onChanged: (val) {
                                setState(() {
                                  _volume = val;
                                });
                                _audioPlayer.setVolume(val);
                              },
                            ),
                          ),
                        ),
                        Icon(
                          Icons.volume_up,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 16,
                        ),
                      ],
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.lyrics_outlined,
                            color: _showLyrics
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Lyrics coming soon",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffle
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isShuffle = !_isShuffle;
                              if (_isShuffle) {
                                _shuffledIndices = List.generate(
                                  _playbackQueue.length,
                                  (i) => i,
                                );
                                _shuffledIndices.shuffle();
                                _shuffledIndices.remove(_currentIndex);
                                _shuffledIndices.insert(0, _currentIndex);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                            color: _repeatMode != 0
                                ? const Color(0xFF1DB954)
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: _toggleRepeatMode,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.playlist_play,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onPressed: () => _showQueueBottomSheet(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            if (_showLyrics) _buildLyricsOverlay(currentTrack),
          ],
        ),
      ),
    );
  }
}
