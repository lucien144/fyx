import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/libs/fyx_image_cache_manager.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostHeroAttachmentImage extends StatelessWidget {
  const PostHeroAttachmentImage({Key? key, required this.crop, required this.size, required this.url, this.cacheKey}) : super(key: key);

  final bool crop;
  final Size size;
  final String url;
  final String? cacheKey;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      alignment: Alignment.topLeft,
      imageUrl: url,
      placeholder: (context, url) => CupertinoActivityIndicator(),
      errorWidget: (context, url, error) {
        LogService.captureError(error);
        return Icon(MdiIcons.imageBroken);
      },
      fit: BoxFit.cover,
      width: crop ? size.width : null,
      height: crop ? size.height : null,
      memCacheWidth: (MediaQuery.of(context).size.width * 0.5 * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheManager: MainRepository().settings.useFyxImageCache ? FyxImageCacheManager() : null,
      cacheKey: cacheKey,
    );
  }
}
