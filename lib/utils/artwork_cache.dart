import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtworkCacheManager {
  static final Map<String, Uint8List?> _memoryCache = {};
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static bool _isPreloading = false;

  /// Retrieves the native media store artwork from memory instantly if available.
  static Uint8List? getCachedArtwork(String trackId) {
    return _memoryCache[trackId];
  }

  /// Checks if the native artwork is already cached or confirmed null.
  static bool isCached(String trackId) {
    return _memoryCache.containsKey(trackId);
  }

  static final Map<String, Future<Uint8List?>> _inFlight = {};

  /// Fetches the native artwork asynchronously and stores it in the memory cache.
  static Future<Uint8List?> fetchAndCacheNativeArtwork(String trackId) async {
    if (_memoryCache.containsKey(trackId)) {
      return _memoryCache[trackId];
    }

    if (_inFlight.containsKey(trackId)) {
      return _inFlight[trackId]!;
    }

    final future = () async {
      Uint8List? bytes;
      try {
        bytes = await _audioQuery.queryArtwork(
          int.parse(trackId),
          ArtworkType.AUDIO,
          size: 200,
          quality: 50,
        );
      } catch (e) {
        bytes = null;
      }

      _memoryCache[trackId] = bytes;
      _inFlight.remove(trackId);
      return bytes;
    }();

    _inFlight[trackId] = future;
    return future;
  }

  /// Silently preloads thumbnails in the background so scrolling is buttery smooth.
  static Future<void> preloadAllArtworks(
    List<dynamic> tracks,
    Map<String, dynamic> overrides,
  ) async {
    if (_isPreloading) return;
    _isPreloading = true;

    for (final track in tracks) {
      final trackId = track.id.toString();
      final customPath = overrides[trackId]?['coverPath'];

      if (customPath != null && customPath.isNotEmpty) {
        // Pre-resolve the low-res version into Flutter's native ImageCache
        final file = File(customPath);
        if (await file.exists()) {
          final provider = ResizeImage(FileImage(file), width: 144);
          provider.resolve(const ImageConfiguration());
        }
      } else {
        // Fetch and cache the native MediaStore thumbnail into our custom memory cache
        if (!_memoryCache.containsKey(trackId)) {
          await fetchAndCacheNativeArtwork(trackId);
        }
      }

      // Small yield to prevent blocking the main isolate UI thread
      await Future.delayed(const Duration(milliseconds: 5));
    }

    _isPreloading = false;
  }
}
