import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryArguments _arguments;
  int _page = 1;

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_arguments == null) {
      _arguments = ModalRoute.of(context).settings.arguments;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.90)),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: PhotoViewGallery.builder(
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(imageProvider: CachedNetworkImageProvider(_arguments.post.images[index].image), onTapDown: (_, __, ___) => close(context));
            },
            itemCount: _arguments.post.images.length,
            loadingChild: CupertinoActivityIndicator(),
            onPageChanged: (i) => setState(() => _page = i + 1),
          ),
        ),
        Positioned(
          top: 30,
          right: 0,
          child: CupertinoButton(
            child: Icon(
              CupertinoIcons.clear_thick,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => close(context),
          ),
        ),
        Positioned(
            width: MediaQuery.of(context).size.width,
            child: Text(
              '$_page / ${_arguments.post.images.length}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            bottom: 40,
            left: 0)
      ],
    );
  }
}
