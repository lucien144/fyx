# Shared

Reusable services (`services/`) and widgets (`widgets/`) used across the application.

## NotificationBadge

`widgets/notification_badge.dart` marks the top-right corner of a widget with a red counter, or with a plain dot when `counter` is omitted.

```dart
NotificationBadge(widget: Icon(Icons.email_outlined), isVisible: newMails > 0, counter: newMails);
NotificationBadge(widget: Icon(MdiIcons.menu), isVisible: hasUpdate); // dot
```

## ImageCacheService

Service for managing image cache operations.

### Usage

```dart
import 'package:fyx/shared/services/image_cache_service.dart';

// Invalidate and reload a specific image
final newCacheKey = await ImageCacheService.invalidateAndReload(imageUrl);
setState(() => _cacheKey = newCacheKey);

// Remove image from cache without reload
await ImageCacheService.removeFromCache(imageUrl);

// Clear entire image cache
await ImageCacheService.clearAllCache();
```

### Methods

- **`invalidateAndReload(String imageUrl)`** - Removes image from disk and memory cache, returns new cache key with timestamp
- **`removeFromCache(String imageUrl)`** - Removes specific image from cache without generating new cache key
- **`clearAllCache()`** - Clears entire image cache (both FyxImageCacheManager and DefaultCacheManager)

### Example

```dart
// In a StatefulWidget
Future<void> _reloadImage() async {
  final url = widget.imageUrl;
  final newCacheKey = await ImageCacheService.invalidateAndReload(url);

  if (mounted) {
    setState(() => _cacheKey = newCacheKey);
  }
}
```