import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fyx/libs/fyx_image_cache_manager.dart';
import 'package:fyx/model/MainRepository.dart';

/// Service for managing image cache operations
class ImageCacheService {
  /// Invalidates and reloads an image from cache
  ///
  /// This method:
  /// 1. Removes the image from disk cache (FyxImageCacheManager or DefaultCacheManager)
  /// 2. Evicts the image from memory cache
  /// 3. Returns a new cache key with timestamp to force reload
  ///
  /// Returns: A new cache key string with timestamp appended
  static Future<String> invalidateAndReload(String imageUrl) async {
    // Remove from cache managers
    removeFromCache(imageUrl);

    // Return new cache key with timestamp to force reload
    return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Clears entire image cache
  static Future<void> clearAllCache() async {
    if (MainRepository().settings.useFyxImageCache) {
      await FyxImageCacheManager().emptyCache();
    } else {
      await DefaultCacheManager().emptyCache();
    }
  }

  /// Removes a specific image from cache without reload
  static Future<void> removeFromCache(String imageUrl) async {
    if (MainRepository().settings.useFyxImageCache) {
      await FyxImageCacheManager().removeFile(imageUrl);
    } else {
      await DefaultCacheManager().removeFile(imageUrl);
    }
    await CachedNetworkImageProvider(imageUrl).evict();
  }
}