import 'package:flutter/foundation.dart';
import 'package:fyx/features/gallery/presentation/gallery_state.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/shared/services/image_cache_service.dart';

/// ViewModel for gallery screen managing images and cache keys
class GalleryViewModel extends ChangeNotifier {
  GalleryState _state = const GalleryState();

  GalleryState get state => _state;

  /// Fill gallery with images and current image URL
  void loadImages({
    required List<model.Image> images,
    required String currentImageUrl,
  }) {
    _state = GalleryState.initial(
      images: images,
      currentImageUrl: currentImageUrl,
    );
    notifyListeners();
  }

  /// Get the index of the current image in the images list
  /// Returns 0 if not found or if there's only one image
  int getInitialPageIndex() {
    if (_state.images.length <= 1) {
      return 0;
    }

    for (int i = 0; i < _state.images.length; i++) {
      if (_state.images[i].image == _state.currentImageUrl) {
        return i;
      }
    }

    return 0; // Fallback to first image if current URL not found
  }

  /// Get cache key for a specific image URL
  String getCacheKey(String imageUrl) {
    return _state.getCacheKey(imageUrl);
  }

  /// Invalidate and reload a specific image
  Future<void> reloadImage(String imageUrl) async {
    // Invalidate cache and get new cache key
    final newCacheKey = await ImageCacheService.invalidateAndReload(imageUrl);

    // Update state with new cache key
    final updatedKeys = Map<String, String>.from(_state.imageCacheKeys);
    updatedKeys[imageUrl] = newCacheKey;

    _state = _state.copyWith(imageCacheKeys: updatedKeys);
    notifyListeners();
  }

  /// Clear all image cache
  Future<void> clearAllCache() async {
    await ImageCacheService.clearAllCache();

    // Reset all cache keys to original URLs
    final resetKeys = <String, String>{};
    _state.imageCacheKeys.forEach((url, _) {
      resetKeys[url] = url;
    });

    _state = _state.copyWith(imageCacheKeys: resetKeys);
    notifyListeners();
  }
}
