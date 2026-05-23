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
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _activeAccentColor,
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
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Mirrored with Now Playing View)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _showLyrics = false),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "LYRICS",
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
                            currentTrack.title,
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
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white70,
                        size: 26,
                      ),
                      tooltip: 'Edit Lyrics',
                      onPressed: () => _showManualLyricsEditor(currentTrack),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content area based on loading & sync state
                Expanded(
                  child: _isLyricsLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: _activeAccentColor,
                          ),
                        )
                      : (_isLyricsSynced
                            ? _buildSyncedLyricsList(currentTrack)
                            : _buildPlainLyricsView(currentTrack)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncedLyricsList(Track currentTrack) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportHeight = constraints.maxHeight;
        final double itemHeight = 70.0;
        final double verticalPadding = (viewportHeight / 2) - (itemHeight / 2);

        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;

            // Find activeIndex
            int activeIndex = -1;
            for (int i = 0; i < _currentLyricsSynced.length; i++) {
              if (position >= _currentLyricsSynced[i].time) {
                activeIndex = i;
              } else {
                break;
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_lyricsScrollController.hasClients &&
                  activeIndex != -1 &&
                  activeIndex != _lastActiveLyricsIndex) {
                _lastActiveLyricsIndex = activeIndex;
                final targetOffset = activeIndex * itemHeight;
                _lyricsScrollController.animateTo(
                  targetOffset.clamp(
                    0.0,
                    _lyricsScrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              }
            });

            return ListView.builder(
              controller: _lyricsScrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              itemCount: _currentLyricsSynced.length,
              itemBuilder: (context, index) {
                final line = _currentLyricsSynced[index];
                final isHighlighted = index == activeIndex;

                return GestureDetector(
                  onTap: () {
                    _smoothSeek(line.time);
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: itemHeight),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      width: double.infinity,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          fontSize: isHighlighted ? 22 : 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: _activeFont,
                          color: isHighlighted
                              ? _activeAccentColor
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        child: Text(line.text, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlainLyricsView(Track currentTrack) {
    if (_currentLyricsPlain == null || _currentLyricsPlain!.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lyrics_outlined, color: Colors.white30, size: 48),
            const SizedBox(height: 12),
            Text(
              'No lyrics found online.',
              style: TextStyle(
                color: Colors.white54,
                fontFamily: _activeFont,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showManualLyricsEditor(currentTrack),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Lyrics Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeAccentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          _currentLyricsPlain!,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            fontFamily: _activeFont,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showManualLyricsEditor(Track currentTrack) {
    final textController = TextEditingController(
      text: _currentLyricsPlain ?? '',
    );

    SharedPreferences.getInstance().then((prefs) {
      final manualKey = 'lyrics_manual_${currentTrack.id}';
      if (prefs.containsKey(manualKey)) {
        textController.text = prefs.getString(manualKey) ?? '';
      } else {
        final cacheKey = 'lyrics_cache_${currentTrack.id}';
        if (prefs.containsKey(cacheKey)) {
          try {
            final data = jsonDecode(prefs.getString(cacheKey) ?? '');
            if (data['syncedLyrics'] != null) {
              textController.text = data['syncedLyrics'];
            } else if (data['plainLyrics'] != null) {
              textController.text = data['plainLyrics'];
            }
          } catch (_) {}
        }
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit/Add Lyrics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: _activeFont,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paste plain lyrics or synced LRC format lyrics below.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: _activeFont,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type or paste lyrics here...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final cleanTitle = currentTrack.title;
                    final cleanArtist = currentTrack.artist.trim().isEmpty
                        ? 'Unknown Artist'
                        : currentTrack.artist;
                    final query = Uri.encodeComponent(
                      '$cleanArtist $cleanTitle lyrics',
                    );
                    final url = Uri.parse(
                      'https://www.google.com/search?q=$query',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search on Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final prefs = await SharedPreferences.getInstance();
                final manualKey = 'lyrics_manual_${currentTrack.id}';
                final text = textController.text.trim();
                if (text.isEmpty) {
                  await prefs.remove(manualKey);
                } else {
                  await prefs.setString(manualKey, text);
                }
                navigator.pop();
                _loadLyricsForTrack(currentTrack);
                showTunzaToast('Lyrics updated!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeAccentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
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
            ValueListenableBuilder<String>(
              valueListenable: _playerBackgroundStyleNotifier,
              builder: (context, style, child) {
                if (style == 'amoled') {
                  return Positioned.fill(
                    child: Container(color: const Color(0xFF000000)),
                  );
                } else if (style == 'blur') {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Container(color: const Color(0xFF0A0A0A)),
                      ),
                      Positioned.fill(
                        child: ClipRect(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 45.0,
                              sigmaY: 45.0,
                            ),
                            child: Opacity(
                              opacity: 0.55,
                              child: Transform.scale(
                                scale: 2.2,
                                child: _buildTrackArtwork(
                                  currentTrack,
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
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.75),
                                Colors.black.withValues(alpha: 0.95),
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
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          color: const Color(0xFF0A0A0A),
                                        ),
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
                                                Colors.black.withValues(
                                                  alpha: dimVal * 0.5,
                                                ),
                                                Colors.black.withValues(
                                                  alpha: dimVal * 1.2 > 1.0
                                                      ? 1.0
                                                      : dimVal * 1.2,
                                                ),
                                                Colors.black.withValues(
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
                  return Positioned.fill(
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
                  );
                }
              },
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _activeAccentColor,
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
                                ? _activeAccentColor
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
                                      _smoothSeek(newPosition);
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
                                ? _activeAccentColor
                                : Colors.white54,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showLyrics = !_showLyrics;
                            });
                            if (_showLyrics) {
                              _loadLyricsForTrack(currentTrack);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffle
                                ? _activeAccentColor
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
                                ? _activeAccentColor
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
