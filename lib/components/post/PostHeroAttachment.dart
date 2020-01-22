import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/post/PostHeroAttachmentBox.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';

class GalleryArguments {
  final model.Image image;
  final Post post;

  GalleryArguments(this.image, {this.post});
}

class PostHeroAttachment extends StatelessWidget {
  final dynamic attachment;
  final Post post;
  final bool _crop;

  PostHeroAttachment(this.attachment, {crop = true, this.post}) : this._crop = crop;

  @override
  Widget build(BuildContext context) {
    if (attachment is model.Image) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/gallery', arguments: GalleryArguments(attachment, post: this.post)),
        child: Hero(
          tag: attachment.hashCode,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              alignment: Alignment.topLeft,
              imageUrl: attachment.thumb,
              placeholder: (context, url) => CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              width: _crop ? 100 : null,
              height: _crop ? 100 : null,
            ),
          ),
        ),
      );
    }

    if (attachment is Link) {
      return PostHeroAttachmentBox(
        title: (attachment as Link).title,
        icon: Icons.link,
      );
    }

    if (attachment is Video) {
      return PostHeroAttachmentBox(
        title: (attachment as Video).link.title,
        icon: Icons.play_circle_filled,
        image: (attachment as Video).thumb,
      );
    }

    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
    );
  }
}
