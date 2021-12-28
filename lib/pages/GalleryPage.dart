import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryArguments? _arguments;
  int _page = 1;
  bool _saving = false;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_arguments != null && _arguments!.images.length > 1) {
        _arguments!.images.asMap().forEach((key, image) {
          if (image.image == _arguments!.imageUrl) {
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
      _arguments = ModalRoute.of(context)!.settings.arguments as GalleryArguments;
    }

    SkinColors colors = Skin.of(context).theme.colors;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: colors.dark.withOpacity(0.90)),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: SafeArea(
            child: PhotoViewGallery.builder(
              pageController: _controller,
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(_arguments!.images[index].image), onTapDown: (_, __, ___) => close(context));
              },
              itemCount: _arguments!.images.length,
              loadingBuilder: (context, chunkEvent) => CupertinoActivityIndicator(
                radius: 16,
              ),
              onPageChanged: (i) => setState(() => _page = i + 1),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 30,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: colors.primary,
            child: Icon(
              CupertinoIcons.clear_thick,
              color: colors.background,
              size: 32,
            ),
            onPressed: () => close(context),
          ),
        ),
        Positioned(
            width: 100,
            bottom: 30,
            left: (MediaQuery.of(context).size.width - 100) / 2,
            child: CupertinoButton(
              color: colors.primary,
              padding: EdgeInsets.zero,
              onPressed: () => close(context),
              child: Text(
                '$_page / ${_arguments!.images.length}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.background),
              ),
            )),
        Positioned(
            bottom: 30,
            right: 30,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: colors.primary,
              child: _saving
                  ? CupertinoActivityIndicator()
                  : Icon(
                      Icons.save_alt_rounded,
                      color: colors.background,
                      size: 32,
                    ),
              onPressed: () async {
                if (_saving) {
                  return;
                }

                setState(() => _saving = true);
                try {
                  var appDocDir = await getTemporaryDirectory();
                  String url = _arguments!.images[_page - 1].image;
                  String filename = basename(url).split('?')[0].split('#')[0];
                  String savePath = appDocDir.path + '/$filename';

                  await Dio().download(url, savePath);
                  final result = await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: Platform.isIOS);
                  if (!result['isSuccess']) {
                    throw Error();
                  }
                  T.success(L.TOAST_IMAGE_SAVE_OK, bg: colors.success);
                } catch (error) {
                  T.error(L.TOAST_IMAGE_SAVE_ERROR, bg: colors.danger);
                  Sentry.captureException(error);
                } finally {
                  setState(() => _saving = false);
                }
              },
            ))
      ],
    );
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
