import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/post/Image.dart' as model;

class PostFooterImage extends StatelessWidget {
  final model.Image image;

  PostFooterImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          alignment: Alignment.topLeft,
          imageUrl: image.thumb,
          placeholder: (context, url) => CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
