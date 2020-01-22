import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryArguments _arguments;

  @override
  Widget build(BuildContext context) {
    if (_arguments == null) {
      _arguments = ModalRoute.of(context).settings.arguments;
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
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(_arguments.post.images[index].image),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(tag: _arguments.post.images[index].hashCode),
            );
          },
          itemCount: _arguments.post.images.length,
          loadingChild: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}
