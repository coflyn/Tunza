// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _MainAudioLogic on _MainScreenState {
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filterShortAudio = prefs.getBool('filterShortAudio') ?? false;
      _autoRegexClean = prefs.getBool('autoRegexClean') ?? false;
      _crossfadeDuration = prefs.getInt('crossfadeDuration') ?? 200;
      _pauseOnDisconnect = prefs.getBool('pauseOnDisconnect') ?? true;
      _autoPlayAfterCall = prefs.getBool('autoPlayAfterCall') ?? true;
      _playTogether = prefs.getBool('playTogether') ?? false;
      _playCountThreshold = prefs.getInt('playCountThreshold') ?? 10;
      _activeFont = prefs.getString('activeFont') ?? 'Plus Jakarta Sans';
      _fontScale = prefs.getDouble('fontScale') ?? 1.0;
      activeFontNotifier.value = _activeFont;
      fontScaleNotifier.value = _fontScale;
      _specificFolderScan = prefs.getString('specificFolderScan') ?? '';
      _skipSilence = prefs.getBool('skipSilence') ?? false;
      _stopOnLowBattery = prefs.getBool('stopOnLowBattery') ?? false;
      _monoAudio = prefs.getBool('monoAudio') ?? false;
      _sortBy = prefs.getString('sortBy') ?? 'date';
      _detailSortBy = prefs.getString('detailSortBy') ?? 'default';
      _themeAccentPreset = prefs.getString('themeAccentPreset') ?? 'spotify';
      _themeMode = prefs.getString('themeMode') ?? 'dark';
      _customThemeBg = prefs.getString('customThemeBg') ?? 'dynamic';
      _customThemeBgPath = prefs.getString('customThemeBgPath');
      _customThemeBgBlur = prefs.getDouble('customThemeBgBlur') ?? 25.0;
      _customThemeBgDim = prefs.getDouble('customThemeBgDim') ?? 0.65;
      _customThemeBgScale = prefs.getDouble('customThemeBgScale') ?? 1.0;
      double customOffsetX = prefs.getDouble('customThemeBgOffsetX') ?? 0.0;
      double customOffsetY = prefs.getDouble('customThemeBgOffsetY') ?? 0.0;
      customThemeBgOffsetXNotifier.value = customOffsetX;
      customThemeBgOffsetYNotifier.value = customOffsetY;

      _customThemeStyle = prefs.getString('customThemeStyle') ?? 'dark';
      themeModeNotifier.value = _themeMode;
      customThemeBgNotifier.value = _customThemeBg;
      customThemeBgPathNotifier.value = _customThemeBgPath;
      customThemeBgBlurNotifier.value = _customThemeBgBlur;
      customThemeBgDimNotifier.value = _customThemeBgDim;
      customThemeBgScaleNotifier.value = _customThemeBgScale;
      customThemeStyleNotifier.value = _customThemeStyle;
      _playerBackgroundStyle =
          prefs.getString('playerBackgroundStyle') ?? 'gradient';
      _playerBackgroundStyleNotifier.value = _playerBackgroundStyle;
      _playerCustomBgPath = prefs.getString('playerCustomBgPath');
      _playerCustomBgPathNotifier.value = _playerCustomBgPath;
      _playerCustomBgBlur = prefs.getDouble('playerCustomBgBlur') ?? 0.0;
      _playerCustomBgBlurNotifier.value = _playerCustomBgBlur;
      _playerCustomBgDim = prefs.getDouble('playerCustomBgDim') ?? 0.4;
      _playerCustomBgDimNotifier.value = _playerCustomBgDim;
      _playerCustomBgScale = prefs.getDouble('playerCustomBgScale') ?? 1.0;
      _playerCustomBgScaleNotifier.value = _playerCustomBgScale;

      double playerOffsetX = prefs.getDouble('playerCustomBgOffsetX') ?? 0.0;
      double playerOffsetY = prefs.getDouble('playerCustomBgOffsetY') ?? 0.0;
      playerCustomBgOffsetXNotifier.value = playerOffsetX;
      playerCustomBgOffsetYNotifier.value = playerOffsetY;

      _audioPlayer.setSkipSilenceEnabled(_skipSilence);

      final cachedSongsStr = prefs.getString('cached_tracks_list');
      if (cachedSongsStr != null) {
        try {
          final List<dynamic> decodedList = jsonDecode(cachedSongsStr);
          final loadedTracks = decodedList
              .map((item) => Track.fromMap(Map<String, dynamic>.from(item)))
              .toList();
          if (loadedTracks.isNotEmpty) {
            _allTracks = loadedTracks;
            _playbackQueue = List.from(loadedTracks);
            _isLoading = false;
          }
        } catch (_) {}
      }
    });
  }

  void _startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes == -1) {
      setState(() {
        _sleepAtEndOfTrack = true;
        _sleepTimerNotifier.value = -1;
      });
      return;
    }
    setState(() {
      _sleepAtEndOfTrack = false;
    });
    if (minutes <= 0) {
      _sleepTimerNotifier.value = 0;
      return;
    }
    _sleepTimerNotifier.value = minutes * 60;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimerNotifier.value > 0) {
        _sleepTimerNotifier.value--;
      } else {
        _sleepTimer?.cancel();
        _pauseWithFade();
      }
    });
  }

  void _updatePlayingFrom() {
    setState(() {
      if (_selectedPlaylistDetail != null) {
        _playingFromType = 'PLAYLIST';
        _playingFromName = _selectedPlaylistDetail!;
      } else if (_selectedArtistDetail != null) {
        _playingFromType = 'ARTIST';
        _playingFromName = _selectedArtistDetail!;
      } else if (_selectedAlbumDetail != null) {
        _playingFromType = 'ALBUM';
        _playingFromName = _selectedAlbumDetail!;
      } else {
        _playingFromType = 'LIBRARY';
        _playingFromName = 'All Songs';
      }
    });
  }

  Future<void> _resetAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _favoriteTrackIds.clear();
      _playCounts.clear();
      _lastPlayedTrackIds.clear();
      _userPlaylists.clear();
      _metadataOverrides.clear();
      _playlistCovers.clear();
    });
    showFlowToast("App data has been reset.");
    _loadSettings();
  }

  void _startBatteryMonitor() {
    _batteryCheckTimer?.cancel();
    _batteryCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      if (_stopOnLowBattery && _audioPlayer.playing) {
        try {
          const channel = MethodChannel('com.flow.audio/equalizer');
          final result = await channel.invokeMapMethod<String, dynamic>(
            'getBatteryStatus',
          );
          if (result != null) {
            final int level = result['level'] ?? -1;
            final bool isCharging = result['isCharging'] ?? false;
            if (level != -1 && level <= 15 && !isCharging) {
              _pauseWithFade();
              showFlowToast(
                "Battery low ($level%). Playback paused.",
                isLong: true,
              );
            }
          }
        } catch (_) {}
      }
    });
  }

  Future<Color?> _getDetailColor(Track? track, {String? playlistName}) async {
    ImageProvider? provider;
    if (playlistName != null && _playlistCovers.containsKey(playlistName)) {
      provider = ResizeImage(
        FileImage(File(_playlistCovers[playlistName]!)),
        width: 600,
      );
    } else if (track != null) {
      final customPath = _metadataOverrides[track.id]?['coverPath'];
      if (customPath != null) {
        provider = ResizeImage(FileImage(File(customPath)), width: 600);
      } else {
        final artwork = await _audioQuery.queryArtwork(
          int.parse(track.id),
          ArtworkType.AUDIO,
          size: 200,
        );
        if (artwork != null) provider = MemoryImage(artwork);
      }
    }

    if (provider != null) {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(100, 100),
      );
      return palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          palette.mutedColor?.color;
    }
    return null;
  }

  void _setupAudioStreams() {
    _audioPlayer.setLoopMode(_repeatMode == 2 ? LoopMode.one : LoopMode.off);
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (mounted) setState(() => _processingState = state);
    });

    _audioPlayer.currentIndexStream.listen((nativeIndex) {
      if (_isProgrammaticLoading) return;
      if (nativeIndex == null) return;
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        if (nativeIndex < concatenating.sequence.length) {
          final mediaItem =
              concatenating.sequence[nativeIndex].tag as MediaItem;
          final trackId = mediaItem.id;
          if (_playingTrack != null && _playingTrack!.id != trackId) {
            final newQueueIndex = _playbackQueue.indexWhere(
              (t) => t.id == trackId,
            );
            if (newQueueIndex != -1) {
              if (nativeIndex == 2) {
                _slideWindowInPlace(newQueueIndex, 1);
              } else if (nativeIndex == 0) {
                _slideWindowInPlace(newQueueIndex, -1);
              } else {
                _playTrack(newQueueIndex, playImmediately: true);
              }
            }
          }
        }
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_repeatMode == 2) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_repeatMode == 1) {
          _playNext();
        } else {
          _audioPlayer.pause();
          _audioPlayer.seek(Duration.zero);
        }
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (_playingTrack != null &&
          _lastIncrementedTrackId != _playingTrack!.id) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        final trackDuration = Duration(milliseconds: _playingTrack!.duration);
        final effectiveDuration = duration > Duration.zero
            ? duration
            : trackDuration;

        bool shouldIncrement = false;
        if (_playCountThreshold == -1) {
          if (effectiveDuration > Duration.zero) {
            shouldIncrement =
                pos >= effectiveDuration - const Duration(milliseconds: 500);
          }
        } else {
          shouldIncrement = pos.inSeconds >= _playCountThreshold;
          if (!shouldIncrement && effectiveDuration > Duration.zero) {
            if (effectiveDuration.inSeconds < _playCountThreshold &&
                pos >= effectiveDuration - const Duration(milliseconds: 500)) {
              shouldIncrement = true;
            }
          }
        }

        if (shouldIncrement) {
          _lastIncrementedTrackId = _playingTrack!.id;
          setState(() {
            _playCounts[_playingTrack!.id] =
                (_playCounts[_playingTrack!.id] ?? 0) + 1;
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('play_counts', jsonEncode(_playCounts));
          });
        }
      }

      if (_sleepAtEndOfTrack) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        if (duration > Duration.zero &&
            pos >= duration - const Duration(milliseconds: 350)) {
          setState(() {
            _sleepAtEndOfTrack = false;
            _sleepTimerNotifier.value = 0;
          });
          _pauseWithFade();
        }
      }

      final currentSource = _audioPlayer.sequenceState.currentSource;
      final mediaItem = currentSource?.tag as MediaItem?;
      final activeTrackId = mediaItem?.id;

      if (activeTrackId != null && pos.inMilliseconds < 1000) {
        _lastCrossfadedTrackId = null;
      }

      bool hasNextTrack = false;
      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
        hasNextTrack =
            currentShuffledPos + 1 < _shuffledIndices.length ||
            _repeatMode == 1;
      } else {
        hasNextTrack =
            _currentIndex + 1 < _playbackQueue.length || _repeatMode == 1;
      }

      if (_crossfadeDuration > 0 &&
          _audioPlayer.playing &&
          !_isNaturalFadingOut &&
          _repeatMode != 2 &&
          activeTrackId != null &&
          hasNextTrack &&
          _lastCrossfadedTrackId != activeTrackId) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        if (duration > Duration.zero) {
          final remaining = duration - pos;
          if (remaining.inMilliseconds <= _crossfadeDuration &&
              remaining.inMilliseconds > 0) {
            _isNaturalFadingOut = true;
            _lastCrossfadedTrackId = activeTrackId;
            Future.delayed(Duration.zero, () async {
              final int sessionId = ++_fadeSessionId;
              final int steps = 10;
              final int stepDelay = (_crossfadeDuration / steps).round();
              for (int i = steps; i >= 0; i--) {
                if (_fadeSessionId != sessionId || !_audioPlayer.playing) break;
                await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
                if (stepDelay > 0) {
                  await Future.delayed(Duration(milliseconds: stepDelay));
                }
              }
            });
          }
        }
      }
    });

    _audioPlayer.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null && sessionId != 0) {
        _applySavedEqualizerSettings(sessionId);
      }
    });
  }

  Future<void> _applySavedEqualizerSettings(int sessionId) async {
    if (sessionId == 0) return;
    try {
      const channel = MethodChannel('com.flow.audio/equalizer');
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('saved_eq_enabled') ?? false;
      if (enabled) {
        final res = await channel.invokeMapMethod<String, dynamic>(
          'initEqualizer',
          {'audioSessionId': sessionId},
        );
        if (res != null) {
          final savedLevelsStr = prefs.getString('saved_eq_levels');
          if (savedLevelsStr != null) {
            final levels = List<int>.from(jsonDecode(savedLevelsStr));
            for (int i = 0; i < levels.length; i++) {
              if (i < (res['bands'] as int)) {
                await channel.invokeMethod('setBandLevel', {
                  'band': i,
                  'level': levels[i],
                });
              }
            }
          }
          await channel.invokeMethod('setEqualizerEnabled', {'enable': true});
        }
      }
    } catch (_) {}
  }

  Future<void> _requestPermissionAndScan({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? favs = prefs.getStringList('favorite_track_ids');
      List<String>? lastPlayed = prefs.getStringList('last_played_track_ids');
      String? playCountsStr = prefs.getString('play_counts');
      String? userPlaylistsStr = prefs.getString('user_playlists');
      String? playlistCoversStr = prefs.getString('playlist_covers');
      String? metadataStr = prefs.getString('metadata_overrides');

      if (favs != null) {
        _favoriteTrackIds.clear();
        _favoriteTrackIds.addAll(favs);
      }
      List<String>? hidden = prefs.getStringList('hidden_track_ids');
      if (hidden != null) {
        _hiddenTrackIds.clear();
        _hiddenTrackIds.addAll(hidden);
      }
      if (lastPlayed != null) _lastPlayedTrackIds = lastPlayed;
      if (playCountsStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(playCountsStr);
          _playCounts = decoded.map((k, v) => MapEntry(k, v as int));
        } catch (_) {}
      }
      if (userPlaylistsStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(userPlaylistsStr);
          _userPlaylists = decoded.map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          );
        } catch (_) {}
      }
      if (playlistCoversStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(playlistCoversStr);
          _playlistCovers = decoded.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {}
      }
      if (metadataStr != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(metadataStr);
          _metadataOverrides = decoded.map(
            (k, v) => MapEntry(k, Map<String, String>.from(v)),
          );
        } catch (_) {}
      }

      bool permissionGranted = await _audioQuery.permissionsStatus();
      if (!permissionGranted) {
        permissionGranted = await _audioQuery.permissionsRequest();
      }

      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Notification Required"),
                ],
              ),
              content: const Text(
                "Flow needs the Notification permission to show music playback controls on your lock screen and background.\n\nPlease enable Notifications for Flow in your phone's App Settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: const Text("OPEN SETTINGS"),
                ),
              ],
            ),
          );
        }
      }

      if (permissionGranted) {
        final List<SongModel> songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        if (songs.isNotEmpty) {
          var filteredSongs = songs;
          if (_filterShortAudio) {
            filteredSongs = filteredSongs
                .where((s) => (s.duration ?? 0) >= 30000)
                .toList();
          }
          if (_specificFolderScan.isNotEmpty) {
            try {
              final allowedDirs = List<String>.from(
                jsonDecode(_specificFolderScan),
              );
              if (allowedDirs.isNotEmpty) {
                filteredSongs = filteredSongs.where((song) {
                  final parentDir = _getParentDirectory(song.data);
                  return allowedDirs.contains(parentDir);
                }).toList();
              }
            } catch (_) {}
          }
          _allTracks = filteredSongs
              .map((song) {
                String safeUri = (song.uri != null && song.uri!.isNotEmpty)
                    ? song.uri!
                    : 'content://media/external/audio/media/${song.id}';

                String title = song.title;
                String artist = song.artist ?? 'Unknown Artist';
                String album = song.album ?? 'Unknown Album';

                if (_metadataOverrides.containsKey(song.id.toString())) {
                  final overrides = _metadataOverrides[song.id.toString()]!;
                  title = overrides['title'] ?? title;
                  artist = overrides['artist'] ?? artist;
                  album = overrides['album'] ?? album;
                }

                if (_autoRegexClean &&
                    !_metadataOverrides.containsKey(song.id.toString())) {
                  final artistPrefix = RegExp(
                    '^${RegExp.escape(artist)}\\s*[-|:]\\s*',
                    caseSensitive: false,
                  );
                  if (artistPrefix.hasMatch(title)) {
                    title = title.replaceAll(artistPrefix, '');
                  }
                  final tagsToRemove = RegExp(
                    r'[\[\(](official|audio|video|lyric|lyrics|music video|official video|official audio|official lyric video|official music video)[\]\)]',
                    caseSensitive: false,
                  );
                  title = title.replaceAll(tagsToRemove, '').trim();

                  final artistSuffix = RegExp(
                    r'\s*[-|:]\s*' + RegExp.escape(artist) + r'$',
                    caseSensitive: false,
                  );
                  if (artistSuffix.hasMatch(title)) {
                    title = title.replaceAll(artistSuffix, '').trim();
                  }
                }

                return Track(
                  id: song.id.toString(),
                  title: title,
                  artist: artist,
                  album: album,
                  url: safeUri,
                  path: song.data,
                  lyrics: [
                    "Playing '$title'...",
                    "Brought to you by Flow Music,",
                    "Your premium local audio choice.",
                    "Feel the deep rhythm in your soul.",
                    "Let the notes carry you away,",
                    "Into the beautiful flow of the day.",
                    "Pure high fidelity local sound.",
                  ],
                  duration: song.duration ?? 0,
                );
              })
              .where((t) => !_hiddenTrackIds.contains(t.id))
              .toList();
          if (_allTracks.isNotEmpty) {
            final serialized = _allTracks.map((t) => t.toMap()).toList();
            prefs.setString('cached_tracks_list', jsonEncode(serialized));
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _cachedDetailKey = null;
        });

        if (_allTracks.isNotEmpty) {
          _playbackQueue = List.from(_allTracks);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterSongs() {
    setState(() {
      _animatedTrackIds.clear();
      _animatedPlaylistIds.clear();
      _animatedArtistIds.clear();
      _animatedAlbumIds.clear();
      _animatedDetailTrackIds.clear();
    });
  }

  Future<void> _updateDominantColor(Track track) async {
    try {
      final customPath = _metadataOverrides[track.id]?['coverPath'];
      ImageProvider? imageProvider;

      if (customPath != null) {
        imageProvider = ResizeImage(FileImage(File(customPath)), width: 600);
      } else {
        final artwork = await _audioQuery.queryArtwork(
          int.parse(track.id),
          ArtworkType.AUDIO,
          size: 200,
        );
        if (artwork != null) {
          imageProvider = MemoryImage(artwork);
        }
      }

      if (imageProvider != null) {
        final palette = await PaletteGenerator.fromImageProvider(imageProvider);
        if (mounted) {
          setState(() {
            _dominantColor =
                palette.dominantColor?.color ??
                palette.vibrantColor?.color ??
                palette.mutedColor?.color;
            _dominantColorNotifier.value = _dominantColor != null
                ? _ensureLuminance(_dominantColor!)
                : null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dominantColor = null;
            _dominantColorNotifier.value = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = null;
          _dominantColorNotifier.value = null;
        });
      }
    }
  }

  Future<Uri?> _getCoverUriForTrack(Track track) async {
    if (_metadataOverrides.containsKey(track.id) &&
        _metadataOverrides[track.id]!['coverPath'] != null) {
      return Uri.file(_metadataOverrides[track.id]!['coverPath']!);
    }
    try {
      final cacheDir = Directory.systemTemp;
      final cacheFile = File('${cacheDir.path}/album_art_${track.id}.png');
      if (await cacheFile.exists()) {
        return Uri.file(cacheFile.path);
      }
      final bytes = await _audioQuery.queryArtwork(
        int.parse(track.id),
        ArtworkType.AUDIO,
        size: 1000,
        quality: 100,
      );
      if (bytes != null) {
        await cacheFile.writeAsBytes(bytes);
        return Uri.file(cacheFile.path);
      }
    } catch (_) {}
    return null;
  }

  void _updateCurrentSourceSilently() async {
    try {
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        int nextSourceIndexInConcatenating = _currentIndex > 0 ? 2 : 1;

        if (_currentIndex + 1 < _playbackQueue.length) {
          final nextTrack = _playbackQueue[_currentIndex + 1];
          final nextUri = nextTrack.url.startsWith('/')
              ? Uri.file(nextTrack.url)
              : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
          final nextCover = await _getCoverUriForTrack(nextTrack);
          final newNextSource = AudioSource.uri(
            nextUri,
            tag: MediaItem(
              id: nextTrack.id,
              album: nextTrack.album.trim().isEmpty
                  ? 'Unknown Album'
                  : nextTrack.album,
              title: nextTrack.title.trim().isEmpty
                  ? 'Unknown Title'
                  : nextTrack.title,
              artist: nextTrack.artist.trim().isEmpty
                  ? 'Unknown Artist'
                  : nextTrack.artist,
              artUri: nextCover,
              duration: Duration(milliseconds: nextTrack.duration),
            ),
          );

          if (nextSourceIndexInConcatenating < concatenating.length) {
            await concatenating.removeAt(nextSourceIndexInConcatenating);
            await concatenating.insert(
              nextSourceIndexInConcatenating,
              newNextSource,
            );
          } else {
            await concatenating.add(newNextSource);
          }
        } else {
          if (nextSourceIndexInConcatenating < concatenating.length) {
            await concatenating.removeAt(nextSourceIndexInConcatenating);
          }
        }
      }
    } catch (_) {}
  }

  void _moveTrackInQueue(Track track, int targetIndex) {
    setState(() {
      final existingIndex = _playbackQueue.indexWhere((t) => t.id == track.id);
      int adjustedTargetIndex = targetIndex;

      if (existingIndex != -1) {
        if (existingIndex == _currentIndex) {
          return;
        }

        _playbackQueue.removeAt(existingIndex);

        _shuffledIndices.remove(existingIndex);
        for (int i = 0; i < _shuffledIndices.length; i++) {
          if (_shuffledIndices[i] > existingIndex) {
            _shuffledIndices[i]--;
          }
        }

        if (existingIndex < _currentIndex) {
          _currentIndex--;
        }

        if (adjustedTargetIndex > existingIndex) {
          adjustedTargetIndex--;
        }
      }

      if (adjustedTargetIndex > _playbackQueue.length) {
        adjustedTargetIndex = _playbackQueue.length;
      }
      if (adjustedTargetIndex < 0) {
        adjustedTargetIndex = 0;
      }

      _playbackQueue.insert(adjustedTargetIndex, track);

      for (int i = 0; i < _shuffledIndices.length; i++) {
        if (_shuffledIndices[i] >= adjustedTargetIndex) {
          _shuffledIndices[i]++;
        }
      }

      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        final currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
        if (currentShuffledPos != -1) {
          _shuffledIndices.insert(currentShuffledPos + 1, adjustedTargetIndex);
        } else {
          _shuffledIndices.add(adjustedTargetIndex);
        }
      } else {
        _shuffledIndices = List.generate(_playbackQueue.length, (i) => i);
      }
    });

    _updateCurrentSourceSilently();
  }

  void reorderUpNext(List<int> newEffectiveIndices) {
    setState(() {
      if (_isShuffle && _shuffledIndices.length == _playbackQueue.length) {
        int pos = _shuffledIndices.indexOf(_currentIndex);
        if (pos != -1) {
          final prefix = _shuffledIndices.sublist(0, pos);
          _shuffledIndices = [...prefix, ...newEffectiveIndices];
        }
      } else {
        List<Track> newQueue = [];
        if (_repeatMode == 1) {
          for (int idx in newEffectiveIndices) {
            newQueue.add(_playbackQueue[idx]);
          }
          _playbackQueue = newQueue;
          _currentIndex = 0;
        } else {
          for (int i = 0; i < _currentIndex; i++) {
            newQueue.add(_playbackQueue[i]);
          }
          for (int idx in newEffectiveIndices) {
            newQueue.add(_playbackQueue[idx]);
          }
          _playbackQueue = newQueue;
        }
      }
      _refreshAudioSourceWindow();
    });
  }

  void _toggleRepeatMode() {
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3;
      _audioPlayer.setLoopMode(_repeatMode == 2 ? LoopMode.one : LoopMode.off);
    });
  }

  Future<void> _playTrack(
    int index, {
    bool playImmediately = true,
    List<Track>? sourceList,
  }) async {
    final listToPlay = sourceList ?? _playbackQueue;
    if (listToPlay.isEmpty || index < 0 || index >= listToPlay.length) return;

    bool queueMatches = _playbackQueue.length == listToPlay.length;
    if (queueMatches && sourceList != null) {
      for (int i = 0; i < _playbackQueue.length; i++) {
        if (_playbackQueue[i].id != listToPlay[i].id) {
          queueMatches = false;
          break;
        }
      }
    }

    if (!queueMatches && sourceList != null) {
      setState(() {
        _playbackQueue = List.from(listToPlay);
        if (_isShuffle) {
          _shuffledIndices = List.generate(_playbackQueue.length, (i) => i);
          _shuffledIndices.shuffle();
        }
      });
    }

    final track = _playbackQueue[index];

    setState(() {
      _currentIndex = index;
      _playingTrack = track;
      _lastIncrementedTrackId = null;
      _isNaturalFadingOut = false;
      _lastActiveLyricsIndex = -1;
      if (_isShuffle && !queueMatches && sourceList != null) {
        _shuffledIndices.remove(_currentIndex);
        _shuffledIndices.insert(0, _currentIndex);
      }

      if (playImmediately) {
        _lastPlayedTrackIds.remove(track.id);
        _lastPlayedTrackIds.insert(0, track.id);
        if (_lastPlayedTrackIds.length > 100) _lastPlayedTrackIds.removeLast();
      }
    });

    _loadLyricsForTrack(track);

    _updateDominantColor(track);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_playing_track_id', track.id);
      if (playImmediately) {
        prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      }
    });

    _isProgrammaticLoading = true;
    try {
      final currentUri = track.url.startsWith('/')
          ? Uri.file(track.url)
          : (Uri.tryParse(track.url) ?? Uri.parse(''));
      final currentCover = await _getCoverUriForTrack(track);

      final currentSource = AudioSource.uri(
        currentUri,
        tag: MediaItem(
          id: track.id,
          album: track.album.trim().isEmpty ? 'Unknown Album' : track.album,
          title: track.title.trim().isEmpty ? 'Unknown Title' : track.title,
          artist: track.artist.trim().isEmpty ? 'Unknown Artist' : track.artist,
          artUri: currentCover,
          duration: Duration(milliseconds: track.duration),
        ),
      );

      AudioSource source;
      int initialIndex = 0;

      if (_playbackQueue.length <= 1) {
        source = currentSource;
      } else {
        final List<AudioSource> children = [];

        int prevIndex = -1;
        int nextIndex = -1;

        if (_isShuffle && _shuffledIndices.isNotEmpty) {
          int currentShuffledPos = _shuffledIndices.indexOf(index);
          if (currentShuffledPos > 0) {
            prevIndex = _shuffledIndices[currentShuffledPos - 1];
          } else if (_repeatMode == 1) {
            prevIndex = _shuffledIndices.last;
          }
          if (currentShuffledPos != -1 &&
              currentShuffledPos < _shuffledIndices.length - 1) {
            nextIndex = _shuffledIndices[currentShuffledPos + 1];
          } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
            nextIndex = _shuffledIndices.first;
          }
        } else {
          if (index > 0) {
            prevIndex = index - 1;
          } else if (_repeatMode == 1) {
            prevIndex = _playbackQueue.length - 1;
          }
          if (index < _playbackQueue.length - 1) {
            nextIndex = index + 1;
          } else if (_repeatMode == 1) {
            nextIndex = 0;
          }
        }

        // Previous track
        if (prevIndex != -1) {
          final prevTrack = _playbackQueue[prevIndex];
          final prevUri = prevTrack.url.startsWith('/')
              ? Uri.file(prevTrack.url)
              : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
          final prevCover = await _getCoverUriForTrack(prevTrack);
          children.add(
            AudioSource.uri(
              prevUri,
              tag: MediaItem(
                id: prevTrack.id,
                album: prevTrack.album.trim().isEmpty
                    ? 'Unknown Album'
                    : prevTrack.album,
                title: prevTrack.title.trim().isEmpty
                    ? 'Unknown Title'
                    : prevTrack.title,
                artist: prevTrack.artist.trim().isEmpty
                    ? 'Unknown Artist'
                    : prevTrack.artist,
                artUri: prevCover,
                duration: Duration(milliseconds: prevTrack.duration),
              ),
            ),
          );
          initialIndex = 1;
        }

        // Current track
        children.add(currentSource);

        // Next track
        if (nextIndex != -1) {
          final nextTrack = _playbackQueue[nextIndex];
          final nextUri = nextTrack.url.startsWith('/')
              ? Uri.file(nextTrack.url)
              : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
          final nextCover = await _getCoverUriForTrack(nextTrack);
          children.add(
            AudioSource.uri(
              nextUri,
              tag: MediaItem(
                id: nextTrack.id,
                album: nextTrack.album.trim().isEmpty
                    ? 'Unknown Album'
                    : nextTrack.album,
                title: nextTrack.title.trim().isEmpty
                    ? 'Unknown Title'
                    : nextTrack.title,
                artist: nextTrack.artist.trim().isEmpty
                    ? 'Unknown Artist'
                    : nextTrack.artist,
                artUri: nextCover,
                duration: Duration(milliseconds: nextTrack.duration),
              ),
            ),
          );
        }

        source = ConcatenatingAudioSource(
          children: children,
          useLazyPreparation: true,
        );
      }

      final int sessionId = ++_fadeSessionId;

      if (_audioPlayer.playing && _crossfadeDuration > 0) {
        // Smooth fade out
        final int steps = 10;
        final int stepDelay = (_crossfadeDuration / steps).round();
        for (int i = steps; i >= 0; i--) {
          if (_fadeSessionId != sessionId) return;
          await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
          if (stepDelay > 0) {
            await Future.delayed(Duration(milliseconds: stepDelay));
          }
        }
      }

      if (_fadeSessionId != sessionId) return;
      await _audioPlayer.setAudioSource(source, initialIndex: initialIndex);

      if (_fadeSessionId != sessionId) return;

      if (playImmediately) {
        await _audioPlayer.setVolume(0.0);
        _audioPlayer.play();
        if (_crossfadeDuration > 0) {
          // Smooth fade in
          final int steps = 10;
          final int stepDelay = (_crossfadeDuration / steps).round();
          for (int i = 1; i <= steps; i++) {
            if (_fadeSessionId != sessionId) return;
            await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
            if (stepDelay > 0) {
              await Future.delayed(Duration(milliseconds: stepDelay));
            }
          }
        }
        if (_fadeSessionId == sessionId) {
          await _audioPlayer.setVolume(_volume);
        }
      } else {
        await _audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('abort')) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing song: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Resync UI if a real error occurred
      final currentTag =
          _audioPlayer.sequenceState.currentSource?.tag as MediaItem?;
      setState(() {
        _processingState = ProcessingState.idle;
        if (currentTag != null) {
          final index = _playbackQueue.indexWhere((t) => t.id == currentTag.id);
          if (index != -1) {
            _currentIndex = index;
            _playingTrack = _playbackQueue[index];
            _updateDominantColor(_playingTrack!);
          }
        }
      });
    } finally {
      _isProgrammaticLoading = false;
    }
  }

  Future<void> _refreshAudioSourceWindow() async {
    if (_playbackQueue.isEmpty || _playingTrack == null) return;
    if (_playbackQueue.length <= 1) return;
    if (_audioPlayer.audioSource is! ConcatenatingAudioSource) return;

    _isProgrammaticLoading = true;
    try {
      final concatenating =
          _audioPlayer.audioSource as ConcatenatingAudioSource;
      final index = _currentIndex;

      int prevIndex = -1;
      int nextIndex = -1;

      if (_isShuffle && _shuffledIndices.isNotEmpty) {
        int currentShuffledPos = _shuffledIndices.indexOf(index);
        if (currentShuffledPos > 0) {
          prevIndex = _shuffledIndices[currentShuffledPos - 1];
        } else if (_repeatMode == 1) {
          prevIndex = _shuffledIndices.last;
        }
        if (currentShuffledPos != -1 &&
            currentShuffledPos < _shuffledIndices.length - 1) {
          nextIndex = _shuffledIndices[currentShuffledPos + 1];
        } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
          nextIndex = _shuffledIndices.first;
        }
      } else {
        if (index > 0) {
          prevIndex = index - 1;
        } else if (_repeatMode == 1) {
          prevIndex = _playbackQueue.length - 1;
        }
        if (index < _playbackQueue.length - 1) {
          nextIndex = index + 1;
        } else if (_repeatMode == 1) {
          nextIndex = 0;
        }
      }

      int playerCurrentIndex = _audioPlayer.currentIndex ?? 0;
      while (playerCurrentIndex > 0) {
        await concatenating.removeAt(0);
        playerCurrentIndex--;
      }
      while (concatenating.length > 1) {
        await concatenating.removeAt(1);
      }

      // Now insert the new adjacent tracks
      if (prevIndex != -1) {
        final prevTrack = _playbackQueue[prevIndex];
        final prevUri = prevTrack.url.startsWith('/')
            ? Uri.file(prevTrack.url)
            : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
        final prevCover = await _getCoverUriForTrack(prevTrack);
        await concatenating.insert(
          0,
          AudioSource.uri(
            prevUri,
            tag: MediaItem(
              id: prevTrack.id,
              album: prevTrack.album.trim().isEmpty
                  ? 'Unknown Album'
                  : prevTrack.album,
              title: prevTrack.title.trim().isEmpty
                  ? 'Unknown Title'
                  : prevTrack.title,
              artist: prevTrack.artist.trim().isEmpty
                  ? 'Unknown Artist'
                  : prevTrack.artist,
              artUri: prevCover,
              duration: Duration(milliseconds: prevTrack.duration),
            ),
          ),
        );
      }

      if (nextIndex != -1) {
        final nextTrack = _playbackQueue[nextIndex];
        final nextUri = nextTrack.url.startsWith('/')
            ? Uri.file(nextTrack.url)
            : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
        final nextCover = await _getCoverUriForTrack(nextTrack);
        await concatenating.add(
          AudioSource.uri(
            nextUri,
            tag: MediaItem(
              id: nextTrack.id,
              album: nextTrack.album.trim().isEmpty
                  ? 'Unknown Album'
                  : nextTrack.album,
              title: nextTrack.title.trim().isEmpty
                  ? 'Unknown Title'
                  : nextTrack.title,
              artist: nextTrack.artist.trim().isEmpty
                  ? 'Unknown Artist'
                  : nextTrack.artist,
              artUri: nextCover,
              duration: Duration(milliseconds: nextTrack.duration),
            ),
          ),
        );
      }
    } finally {
      _isProgrammaticLoading = false;
    }
  }

  Future<void> _slideWindowInPlace(int newQueueIndex, int direction) async {
    _isProgrammaticLoading = true;
    try {
      final track = _playbackQueue[newQueueIndex];
      setState(() {
        _currentIndex = newQueueIndex;
        _playingTrack = track;
        _lastIncrementedTrackId = null;
        _isNaturalFadingOut = false; // Reset the natural fade variable
        _lastActiveLyricsIndex = -1;
      });
      _loadLyricsForTrack(track);
      _updateDominantColor(track);

      if (_crossfadeDuration > 0) {
        final int sessionId = ++_fadeSessionId;
        final int steps = 10;
        final int stepDelay = (_crossfadeDuration / steps).round();
        Future.delayed(Duration.zero, () async {
          await _audioPlayer.setVolume(0.0);
          for (int i = 1; i <= steps; i++) {
            if (_fadeSessionId != sessionId) return;
            await _audioPlayer.setVolume(_volume * (i / steps.toDouble()));
            if (stepDelay > 0) {
              await Future.delayed(Duration(milliseconds: stepDelay));
            }
          }
          if (_fadeSessionId == sessionId) {
            await _audioPlayer.setVolume(_volume);
          }
        });
      } else {
        await _audioPlayer.setVolume(_volume);
      }

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_playing_track_id', track.id);
        _lastPlayedTrackIds.remove(track.id);
        _lastPlayedTrackIds.insert(0, track.id);
        if (_lastPlayedTrackIds.length > 100) _lastPlayedTrackIds.removeLast();
        prefs.setStringList('last_played_track_ids', _lastPlayedTrackIds);
      });

      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final concatenating =
            _audioPlayer.audioSource as ConcatenatingAudioSource;
        int prevIndex = -1;
        int nextIndex = -1;

        if (_isShuffle && _shuffledIndices.isNotEmpty) {
          int currentShuffledPos = _shuffledIndices.indexOf(newQueueIndex);
          if (currentShuffledPos > 0) {
            prevIndex = _shuffledIndices[currentShuffledPos - 1];
          } else if (_repeatMode == 1) {
            prevIndex = _shuffledIndices.last;
          }
          if (currentShuffledPos != -1 &&
              currentShuffledPos < _shuffledIndices.length - 1) {
            nextIndex = _shuffledIndices[currentShuffledPos + 1];
          } else if (_repeatMode == 1 && _shuffledIndices.isNotEmpty) {
            nextIndex = _shuffledIndices.first;
          }
        } else {
          if (newQueueIndex > 0) {
            prevIndex = newQueueIndex - 1;
          } else if (_repeatMode == 1) {
            prevIndex = _playbackQueue.length - 1;
          }
          if (newQueueIndex < _playbackQueue.length - 1) {
            nextIndex = newQueueIndex + 1;
          } else if (_repeatMode == 1) {
            nextIndex = 0;
          }
        }

        if (direction > 0) {
          // Slide forward: remove index 0, add new next at end
          if (concatenating.sequence.isNotEmpty) {
            await concatenating.removeAt(0);
          }
          if (nextIndex != -1) {
            final nextTrack = _playbackQueue[nextIndex];
            final nextUri = nextTrack.url.startsWith('/')
                ? Uri.file(nextTrack.url)
                : (Uri.tryParse(nextTrack.url) ?? Uri.parse(''));
            final nextCover = await _getCoverUriForTrack(nextTrack);
            await concatenating.add(
              AudioSource.uri(
                nextUri,
                tag: MediaItem(
                  id: nextTrack.id,
                  album: nextTrack.album.trim().isEmpty
                      ? 'Unknown Album'
                      : nextTrack.album,
                  title: nextTrack.title.trim().isEmpty
                      ? 'Unknown Title'
                      : nextTrack.title,
                  artist: nextTrack.artist.trim().isEmpty
                      ? 'Unknown Artist'
                      : nextTrack.artist,
                  artUri: nextCover,
                  duration: Duration(milliseconds: nextTrack.duration),
                ),
              ),
            );
          }
        } else if (direction < 0) {
          // Slide backward: remove last index, insert new prev at index 0
          if (concatenating.sequence.length > 1) {
            await concatenating.removeAt(concatenating.sequence.length - 1);
          }
          if (prevIndex != -1) {
            final prevTrack = _playbackQueue[prevIndex];
            final prevUri = prevTrack.url.startsWith('/')
                ? Uri.file(prevTrack.url)
                : (Uri.tryParse(prevTrack.url) ?? Uri.parse(''));
            final prevCover = await _getCoverUriForTrack(prevTrack);
            await concatenating.insert(
              0,
              AudioSource.uri(
                prevUri,
                tag: MediaItem(
                  id: prevTrack.id,
                  album: prevTrack.album.trim().isEmpty
                      ? 'Unknown Album'
                      : prevTrack.album,
                  title: prevTrack.title.trim().isEmpty
                      ? 'Unknown Title'
                      : prevTrack.title,
                  artist: prevTrack.artist.trim().isEmpty
                      ? 'Unknown Artist'
                      : prevTrack.artist,
                  artUri: prevCover,
                  duration: Duration(milliseconds: prevTrack.duration),
                ),
              ),
            );
          }
        }
      }
    } catch (_) {
      // Fallback if mutation fails
      _playTrack(newQueueIndex, playImmediately: true);
    } finally {
      _isProgrammaticLoading = false;
    }
  }

  void _playNext() {
    if (_playbackQueue.isEmpty) return;

    int nextIndex;
    if (_isShuffle && _shuffledIndices.isNotEmpty) {
      int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffledPos + 1 < _shuffledIndices.length) {
        nextIndex = _shuffledIndices[currentShuffledPos + 1];
      } else {
        if (_repeatMode == 1) {
          nextIndex = _shuffledIndices[0];
        } else {
          return;
        }
      }
    } else {
      nextIndex = _currentIndex + 1;
      if (nextIndex >= _playbackQueue.length) {
        if (_repeatMode == 1) {
          nextIndex = 0;
        } else {
          return;
        }
      }
    }
    _playTrack(nextIndex);
  }

  void _playPrevious() {
    if (_playbackQueue.isEmpty) return;

    if (_audioPlayer.position.inSeconds > 3) {
      _audioPlayer.seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (_isShuffle && _shuffledIndices.isNotEmpty) {
      int currentShuffledPos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShuffledPos - 1 >= 0) {
        prevIndex = _shuffledIndices[currentShuffledPos - 1];
      } else {
        if (_repeatMode == 1) {
          prevIndex = _shuffledIndices.last;
        } else {
          prevIndex = _shuffledIndices.first;
        }
      }
    } else {
      prevIndex = _currentIndex - 1;
      if (prevIndex < 0) {
        if (_repeatMode == 1) {
          prevIndex = _playbackQueue.length - 1;
        } else {
          prevIndex = 0;
        }
      }
    }
    _playTrack(prevIndex);
  }

  List<LyricsLine> _parseLrc(String lrcContent) {
    final List<LyricsLine> lines = [];
    final RegExp regExp = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\](.*)');
    for (final line in lrcContent.split('\n')) {
      final match = regExp.firstMatch(line.trim());
      if (match != null) {
        final int minutes = int.parse(match.group(1)!);
        final int seconds = int.parse(match.group(2)!);
        final int milliseconds = match.group(3) != null
            ? int.parse(match.group(3)!.padRight(3, '0').substring(0, 3))
            : 0;
        final String text = match.group(4)?.trim() ?? '';
        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        lines.add(LyricsLine(time: duration, text: text));
      }
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return lines;
  }

  Future<void> _loadLyricsForTrack(Track track) async {
    if (_lyricsScrollController.hasClients) {
      _lyricsScrollController.jumpTo(0);
    }
    _lastActiveLyricsIndex = -1;
    setState(() {
      _isLyricsLoading = true;
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final manualKey = 'lyrics_manual_${track.id}';

    if (prefs.containsKey(manualKey)) {
      final manualText = prefs.getString(manualKey) ?? '';
      _parsePlainOrLrcLyrics(manualText);
      setState(() {
        _isLyricsLoading = false;
      });
      return;
    }

    final cacheKey = 'lyrics_cache_${track.id}';
    if (prefs.containsKey(cacheKey)) {
      final cachedJson = prefs.getString(cacheKey) ?? '';
      try {
        final data = jsonDecode(cachedJson);
        _applyFetchedLyrics(data);
        setState(() {
          _isLyricsLoading = false;
        });
        return;
      } catch (_) {}
    }

    try {
      final cleanTitle = track.title;
      final cleanArtist = track.artist.trim().isEmpty
          ? 'Unknown Artist'
          : track.artist;

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse('https://lrclib.net/api/get').replace(
        queryParameters: {'artist_name': cleanArtist, 'track_name': cleanTitle},
      );

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);

        await prefs.setString(cacheKey, body);
        _applyFetchedLyrics(data);
      } else {
        _currentLyricsPlain = null;
        _currentLyricsSynced = [];
        _isLyricsSynced = false;
      }
    } catch (_) {
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLyricsLoading = false;
        });
      }
    }
  }

  void _applyFetchedLyrics(dynamic data) {
    final synced = data['syncedLyrics'] as String?;
    final plain = data['plainLyrics'] as String?;

    if (synced != null && synced.trim().isNotEmpty) {
      _currentLyricsSynced = _parseLrc(synced);
      _currentLyricsPlain = plain ?? _stripLrcTimestamps(synced);
      _isLyricsSynced = _currentLyricsSynced.isNotEmpty;
    } else if (plain != null && plain.trim().isNotEmpty) {
      _currentLyricsPlain = plain;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    } else {
      _currentLyricsPlain = null;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    }
  }

  void _parsePlainOrLrcLyrics(String text) {
    if (text.contains(RegExp(r'\[\d+:\d+'))) {
      _currentLyricsSynced = _parseLrc(text);
      _currentLyricsPlain = _stripLrcTimestamps(text);
      _isLyricsSynced = _currentLyricsSynced.isNotEmpty;
    } else {
      _currentLyricsPlain = text;
      _currentLyricsSynced = [];
      _isLyricsSynced = false;
    }
  }

  String _stripLrcTimestamps(String text) {
    return text.replaceAll(RegExp(r'\[\d+:\d+(?:\.\d+)?\]'), '').trim();
  }

  Future<void> _pauseWithFade() async {
    if (_isFading || !_isPlaying) return;
    _isFading = true;
    final currentVol = _volume;
    if (_crossfadeDuration > 0) {
      final int steps = 10;
      final int stepDelay = (_crossfadeDuration / steps).round();
      for (int i = steps; i >= 0; i--) {
        if (!mounted) break;
        await _audioPlayer.setVolume(currentVol * (i / steps.toDouble()));
        if (stepDelay > 0) {
          await Future.delayed(Duration(milliseconds: stepDelay));
        }
      }
    }
    await _audioPlayer.pause();
    await _audioPlayer.setVolume(currentVol);
    _isFading = false;
  }

  Future<void> _playWithFade() async {
    if (_isFading || _isPlaying) return;
    _isFading = true;
    final currentVol = _volume;
    await _audioPlayer.setVolume(0.0);
    _audioPlayer.play();
    if (_crossfadeDuration > 0) {
      final int steps = 10;
      final int stepDelay = (_crossfadeDuration / steps).round();
      for (int i = 0; i <= steps; i++) {
        if (!mounted) break;
        await _audioPlayer.setVolume(currentVol * (i / steps.toDouble()));
        if (stepDelay > 0) {
          await Future.delayed(Duration(milliseconds: stepDelay));
        }
      }
    }
    await _audioPlayer.setVolume(currentVol);
    _isFading = false;
  }

  Future<void> _smoothSeek(Duration position) async {
    final double originalVolume = _volume;
    final int steps = 5;
    final int stepDelay = 15; // Total fade out = 75ms

    try {
      for (int i = steps; i >= 0; i--) {
        if (!mounted) break;
        await _audioPlayer.setVolume(originalVolume * (i / steps.toDouble()));
        await Future.delayed(Duration(milliseconds: stepDelay));
      }

      await _audioPlayer.seek(position);

      for (int i = 0; i <= steps; i++) {
        if (!mounted) break;
        await _audioPlayer.setVolume(originalVolume * (i / steps.toDouble()));
        await Future.delayed(Duration(milliseconds: stepDelay));
      }
    } catch (_) {
      await _audioPlayer.seek(position);
      await _audioPlayer.setVolume(originalVolume);
    }
  }

  void _toggleFavorite(String trackId) {
    setState(() {
      if (_favoriteTrackIds.contains(trackId)) {
        _favoriteTrackIds.remove(trackId);
      } else {
        _favoriteTrackIds.add(trackId);
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('favorite_track_ids', _favoriteTrackIds.toList());
    });
  }

  void _saveUserPlaylists() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_playlists', jsonEncode(_userPlaylists));
    });
  }

  void _savePlaylistCovers() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('playlist_covers', jsonEncode(_playlistCovers));
    });
  }

  void _saveMetadataOverrides() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('metadata_overrides', jsonEncode(_metadataOverrides));
    });
  }

  Widget _buildOptionItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    final isLight = isAppLight;
    final resolvedIconColor =
        iconColor ?? (isLight ? Colors.black54 : Colors.white70);
    return ListTile(
      leading: Icon(icon, color: resolvedIconColor),
      title: Text(
        title,
        style: TextStyle(
          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          fontSize: 16,
          fontFamily: _activeFont,
        ),
      ),
      onTap: onTap,
    );
  }
}
