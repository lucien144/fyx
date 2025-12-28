import 'package:flutter/foundation.dart';

/// State for gallery screen holding cache keys for each image
@immutable
class GalleryState {
  /// Map of image URLs to their cache keys (with timestamp for reload)
  final Map<String, String> imageCacheKeys;

  const GalleryState({
    this.imageCacheKeys = const {},
  });

  /// Initialize cache keys for a list of image URLs
  factory GalleryState.fromImageUrls(List<String> imageUrls) {
    final cacheKeys = <String, String>{};
    for (final url in imageUrls) {
      cacheKeys[url] = url; // Initially, cache key is the same as URL
    }
    return GalleryState(imageCacheKeys: cacheKeys);
  }

  /// Get cache key for a specific image URL
  String getCacheKey(String imageUrl) {
    return imageCacheKeys[imageUrl] ?? imageUrl;
  }

  /// Create a copy with updated cache keys
  GalleryState copyWith({
    Map<String, String>? imageCacheKeys,
  }) {
    return GalleryState(
      imageCacheKeys: imageCacheKeys ?? this.imageCacheKeys,
    );
  }
}