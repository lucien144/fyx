import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/theme/T.dart';

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

    if (attachment is Link) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: T.COLOR_PRIMARY,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Icon(
                Icons.link,
                color: Colors.white,
                size: 40,
              ),
            ),
            Container(
              color: Color.fromRGBO(255, 255, 255, 0.6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  attachment.fancyUrl,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
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
