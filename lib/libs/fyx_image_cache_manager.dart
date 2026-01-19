import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FyxImageCacheManager extends CacheManager with ImageCacheManager {
  static const String key = 'fyx_image_cache_manager';

  static Config instance = Config(
    key,
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
    repo: JsonCacheInfoRepository(databaseName: key),
    // fileSystem: IOFileSystem(key),
    fileService: HttpFileService(),
  );

  FyxImageCacheManager() : super(instance);
}