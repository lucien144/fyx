import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/post/Image.dart' as model;

class PostHeroAttachment extends StatelessWidget {
  final dynamic attachment;

  PostHeroAttachment(this.attachment);

  @override
  Widget build(BuildContext context) {
    if (attachment is model.Image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          alignment: Alignment.topLeft,
          imageUrl: attachment.thumb,
          placeholder: (context, url) => CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
    );
  }
}
