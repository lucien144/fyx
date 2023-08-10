import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FyxImageCacheManager extends CacheManager with ImageCacheManager {
  static const String key = 'fyx_image_cache_manager';

  static Config config = Config(
    key,
    stalePeriod: const Duration(days: 5),
    maxNrOfCacheObjects: 384,
    repo: JsonCacheInfoRepository(databaseName: key),
    // fileSystem: IOFileSystem(key),
    fileService: HttpFileService(),
  );

  FyxImageCacheManager() : super(config);
}