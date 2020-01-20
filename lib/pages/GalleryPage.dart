import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:photo_view/photo_view.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  model.Image image;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      image = ModalRoute.of(context).settings.arguments;
    }

    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.90)),
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.vertical,
        onDismissed: (int) => Navigator.of(context).pop(),
        child: PhotoView(
          backgroundDecoration: BoxDecoration(color: Colors.transparent),
          heroAttributes: PhotoViewHeroAttributes(tag: image.hashCode),
          imageProvider: CachedNetworkImageProvider(image.image),
        ),
      ),
    );
  }
}
