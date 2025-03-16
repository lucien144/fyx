import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/components/throw_it_away.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/exceptions/UnsupportedDownloadFormatException.dart';
import 'package:fyx/libs/fyx_image_cache_manager.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryArguments? _arguments;
  int _page = 1;
  bool _saving = false;
  bool _throwAway = true;
  bool _hideUI = false;

  final pageController = PageController();
  final photoController = PhotoViewController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_arguments != null && _arguments!.images.length > 1) {
        _arguments!.images.asMap().forEach((key, image) {
          if (image.image == _arguments!.imageUrl) {
            pageController.jumpToPage(key);
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
          child: PhotoViewGallery.builder(
            scaleStateChangedCallback: (_) => setState(() => _throwAway = !_.isScaleStateZooming),
            pageController: pageController,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions.customChild(
                  controller: photoController,
                  minScale: 1.0,
                  child: ThrowItAway(
                    enabled: _throwAway,
                    onTap: () => setState(() => _hideUI = !_hideUI),
                    onDoubleTap: (details) {
                      var x = (details.globalPosition.dx - MediaQuery.of(context).size.width / 2);
                      var y = (details.globalPosition.dy - MediaQuery.of(context).size.height / 2);
                      if (photoController.scale == 1) {
                        photoController.scale = 2;
                        photoController.position = Offset(-x * 2, -y * 2);
                      } else {
                        setState(() => _throwAway = true);
                        photoController.scale = 1;
                      }
                    },
                    onDismiss: () {
                      close(context);
                    },
                    child: CachedNetworkImage(
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        progressIndicatorBuilder: (context, url, progress) => Center(
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                child: CircularProgressIndicator(value: progress.progress, color: colors.primary),
                              ),
                            ),
                        imageUrl: _arguments!.images[index].image,
                        memCacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt(),
                        cacheManager: MainRepository().settings.useFyxImageCache ? FyxImageCacheManager() : null),
                  ));
            },
            itemCount: _arguments!.images.length,
            onPageChanged: (i) => setState(() => _page = i + 1),
          ),
        ),
        Positioned(
          top: 50,
          right: 30,
          child: Visibility(
            visible: !_hideUI,
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
        ),
        Positioned(
            width: 100,
            bottom: 30,
            left: (MediaQuery.of(context).size.width - 100) / 2,
            child: Visibility(
                visible: !_hideUI,
                child: CupertinoButton(
                  color: colors.primary,
                  padding: EdgeInsets.zero,
                  onPressed: () => close(context),
                  child: Text(
                    '$_page / ${_arguments!.images.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.background),
                  ),
                ))),
        Positioned(
            bottom: 30,
            right: 30,
            child: Visibility(
                visible: !_hideUI,
                child: Column(
                  children: [
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: colors.primary,
                        child: Icon(
                          MdiIcons.openInNew,
                          color: colors.background,
                          size: 32,
                        ),
                        onPressed: () {
                          String url = _arguments!.images[_page - 1].image;
                          T.openLink(url, mode: SettingsProvider().linksMode);
                        }),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: colors.primary,
                      child: _saving
                          ? CupertinoActivityIndicator()
                          : Icon(
                              MdiIcons.download,
                              color: colors.background,
                              size: 32,
                            ),
                      onPressed: () async {
                        if (_saving) {
                          return;
                        }

                        setState(() => _saving = true);
                        try {
                          PermissionStatus status = await Permission.storage.request();
                          var isGranted = status.isGranted;

                          if (Platform.isAndroid) {
                            // https://pub.dev/packages/permission_handler#requesting-storage-permissions-always-returns-denied-on-android-13-what-can-i-do
                            DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
                            final androidInfo = await deviceInfoPlugin.androidInfo;
                            isGranted = androidInfo.version.sdkInt >= 33 || isGranted;
                          }

                          if (isGranted) {
                            // See https://github.com/lucien144/fyx/issues/304#issuecomment-1094851596

                            var appDocDir = await getTemporaryDirectory();
                            String url = _arguments!.images[_page - 1].image;
                            String savePath = '${appDocDir.path}/${Helpers.uuid(6)}';
                            await Dio().download(url, savePath);

                            File file = new File(savePath);
                            Uint8List headerBytes = file.readAsBytesSync();
                            var ext = extensionFromMime(lookupMimeType(savePath, headerBytes: headerBytes.getRange(0, 20).toList()) ?? '');
                            ext = ext == 'jpe' ? 'jpg' : ext; // https://github.com/dart-lang/mime/issues/55
                            if (!['jpg', 'png', 'gif', 'heic'].contains(ext)) {
                              file.delete();
                              throw UnsupportedDownloadFormatException('Nelze uložit. Neznámý typ souboru ($ext).');
                            }

                            file = await file.rename('$savePath.$ext');
                            final result = await ImageGallerySaver.saveFile('$savePath.$ext', isReturnPathOfIOS: Platform.isIOS);
                            if (!result['isSuccess']) {
                              throw Error();
                            }
                            T.success(L.TOAST_IMAGE_SAVE_OK, bg: colors.success);
                            file.delete();
                          } else {
                            T.error('Nelze uložit. Povolte ukládání, prosím.', bg: colors.danger);
                          }
                        } on UnsupportedDownloadFormatException catch (exception) {
                          T.error(exception.message, bg: colors.danger);
                        } catch (error) {
                          T.error(L.TOAST_IMAGE_SAVE_ERROR, bg: colors.danger);
                          print((error as Error).stackTrace);
                          LogService.captureError(error, stack: (error as Error).stackTrace);
                        } finally {
                          setState(() => _saving = false);
                        }
                      },
                    ),
                  ],
                )))
      ],
    );
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
