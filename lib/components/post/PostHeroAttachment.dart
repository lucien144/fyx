import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/PostHeroAttachmentBox.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';

class GalleryArguments {
  final String imageUrl;
  final List<model.Image> images;

  GalleryArguments(this.imageUrl, {this.images});
}

class PostHeroAttachment extends StatelessWidget {
  final dynamic attachment;
  final Content content;
  final double _size;
  final bool _crop;
  final Function _onTap;
  final bool _openGallery;

  PostHeroAttachment(this.attachment, this.content, {crop = true, size = 100.0, onTap, openGallery = true})
      : this._crop = crop,
        this._size = size,
        this._onTap = onTap,
        this._openGallery = openGallery;

  @override
  Widget build(BuildContext context) {
    if (attachment is model.Image) {
      return GestureDetector(
        onTap: () {
          if (_onTap is Function) {
            _onTap();
          }
          if (_openGallery) {
            Navigator.of(context).pushNamed('/gallery', arguments: GalleryArguments((attachment as model.Image).image, images: content.images));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            alignment: Alignment.topLeft,
            imageUrl: attachment.thumb,
            placeholder: (context, url) => CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
            width: _crop ? _size : null,
            height: _crop ? _size : null,
          ),
        ),
      );
    }

    if (attachment is Link) {
      return PostHeroAttachmentBox(
        title: (attachment as Link).title,
        icon: Icons.link,
        onTap: () => PlatformTheme.openLink((attachment as Link).url),
      );
    }

    if (attachment is Video) {
      return PostHeroAttachmentBox(
        title: (attachment as Video).link.title,
        icon: Icons.play_circle_filled,
        image: (attachment as Video).thumb,
        onTap: () => PlatformTheme.openLink((attachment as Video).link.url),
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
