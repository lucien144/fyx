import 'package:flutter/foundation.dart';
import 'package:fyx/model/post/Image.dart' as model;

/// State for gallery screen holding images, current selection, and cache keys
@immutable
class GalleryState {
  /// List of all images in the gallery
  final List<model.Image> images;

  /// URL of the currently selected image
  final String currentImageUrl;

  /// Map of image URLs to their cache keys (with timestamp for reload)
  final Map<String, String> imageCacheKeys;

  const GalleryState({
    this.images = const [],
    this.currentImageUrl = '',
    this.imageCacheKeys = const {},
  });

  /// Initialize state with images and current image URL
  factory GalleryState.initial({
    required List<model.Image> images,
    required String currentImageUrl,
  }) {
    final cacheKeys = <String, String>{};
    for (final image in images) {
      cacheKeys[image.image] = image.image; // Initially, cache key is the same as URL
    }
    return GalleryState(
      images: images,
      currentImageUrl: currentImageUrl,
      imageCacheKeys: cacheKeys,
    );
  }

  /// Get cache key for a specific image URL
  String getCacheKey(String imageUrl) {
    return imageCacheKeys[imageUrl] ?? imageUrl;
  }

  /// Create a copy with updated values
  GalleryState copyWith({
    List<model.Image>? images,
    String? currentImageUrl,
    Map<String, String>? imageCacheKeys,
  }) {
    return GalleryState(
      images: images ?? this.images,
      currentImageUrl: currentImageUrl ?? this.currentImageUrl,
      imageCacheKeys: imageCacheKeys ?? this.imageCacheKeys,
    );
  }
}