import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fyx/components/post/post_hero_attachment_box.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/theme/T.dart';

class GalleryArguments {
  final String imageUrl;
  final List<model.Image> images;

  GalleryArguments(this.imageUrl, {this.images = const []});
}

class PostHeroAttachment extends StatelessWidget {
  final dynamic attachment;
  final List<model.Image> _images;
  final bool _crop;
  final Function? _onTap;
  final bool _openGallery;
  final bool blur;
  Size size;
  bool showStrip;

  PostHeroAttachment(this.attachment,
      {images = const <model.Image>[], crop = true, this.showStrip = true, this.size = const Size(100, 100), onTap, openGallery = true, this.blur = false})
      : this._crop = crop,
        this._onTap = onTap,
        this._openGallery = openGallery,
        this._images = images;

  @override
  Widget build(BuildContext context) {
    if (attachment is model.Image) {
      return GestureDetector(
        onTap: () {
          if (_onTap != null) {
            _onTap!();
          }
          if (_openGallery) {
            Navigator.of(context, rootNavigator: true)
                .pushNamed('/gallery', arguments: GalleryArguments((attachment as model.Image).image, images: _images));
          }
        },
        onLongPress: () {
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(attachment.thumb),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () async {
                    try {
                      await DefaultCacheManager().removeFile(attachment.thumb);
                      T.success('Cache smazána.');
                    } catch (error) {
                      T.warn('Cache se nepodařilo smazat.');
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Reset cache obrázku?'),
                ),
                if (_openGallery)
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () async {
                      try {
                        await Future.forEach(_images, (image) => DefaultCacheManager().removeFile((image as model.Image).image));
                        T.success('Cache galerie smazána.');
                      } catch (error) {
                        T.warn('Cache se nepodařilo smazat.');
                      } finally {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Reset cache celé galerie?'),
                  ),
              ],
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                alignment: Alignment.topLeft,
                imageUrl: attachment.thumb,
                placeholder: (context, url) => CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                width: _crop ? size.width : null,
                height: _crop ? size.height : null,
                cacheManager: CacheManager(Config(attachment.thumb, stalePeriod: const Duration(days: 7))),
              ),
              if (blur) Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container()))
            ],
          ),
        ),
      );
    }

    if (attachment is Link) {
      return PostHeroAttachmentBox(
        showStrip: this.showStrip,
        title: (attachment as Link).title,
        icon: Icons.link,
        size: size,
        onTap: () => T.openLink((attachment as Link).url, mode: SettingsProvider().linksMode),
      );
    }

    if (attachment is Video) {
      var link = (attachment as Video).link;
      return PostHeroAttachmentBox(
        title: link == null ? '' : link.title,
        showStrip: this.showStrip,
        icon: Icons.play_circle_filled,
        image: (attachment as Video).thumb,
        size: size,
        onTap: link == null ? null : () => T.openLink(link.url, mode: SettingsProvider().linksMode),
      );
    }

    // TODO: Show an error message and open a github issue.
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
    );
  }
}
