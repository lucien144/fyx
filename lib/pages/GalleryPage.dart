import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryArguments _arguments;
  int _page = 1;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_arguments.images.length > 1) {
        _arguments.images.asMap().forEach((key, image) {
          if (image.image == _arguments.imageUrl) {
            _controller.jumpToPage(key);
          }
        });
      }
    });

    AnalyticsProvider().setScreen('Gallery', 'GalleryPage');
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
            pageController: _controller,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(imageProvider: CachedNetworkImageProvider(_arguments.images[index].image), onTapDown: (_, __, ___) => close(context));
            },
            itemCount: _arguments.images.length,
            loadingBuilder: (context, chunkEvent) => CupertinoActivityIndicator(radius: 16,),
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
            child: CupertinoButton(
              onPressed: () => close(context),
              child: Text(
                '$_page / ${_arguments.images.length}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
            bottom: 30,
            left: 0)
      ],
    );
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
