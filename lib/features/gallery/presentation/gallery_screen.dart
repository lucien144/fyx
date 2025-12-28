import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/features/gallery/presentation/gallery_viewmodel.dart';
import 'package:fyx/features/gallery/presentation/widgets/context_menu_button.dart';
import 'package:fyx/features/gallery/presentation/widgets/throw_it_away.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/libs/fyx_image_cache_manager.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryScreen extends WatchingStatefulWidget {
  @override
  State createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  GalleryArguments? _arguments;
  int _page = 1;
  bool _throwAway = true;
  bool _hideUI = false;

  final pageController = PageController();
  final photoController = PhotoViewController();

  @override
  void dispose() {
    pageController.dispose();
    getIt.unregister<GalleryViewModel>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Register ViewModel as singleton for this gallery session
    getIt.registerSingleton<GalleryViewModel>(GalleryViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_arguments != null) {
        // Initialize ViewModel with image URLs
        final viewModel = getIt<GalleryViewModel>();
        final imageUrls = _arguments!.images.map((img) => img.image).toList();
        viewModel.initialize(imageUrls);

        if (_arguments!.images.length > 1) {
          _arguments!.images.asMap().forEach((key, image) {
            if (image.image == _arguments!.imageUrl) {
              pageController.jumpToPage(key);
            }
          });
        }
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
    final viewModel = watchIt<GalleryViewModel>();
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
                        key: ValueKey(viewModel.getCacheKey(_arguments!.images[index].image)),
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
                        cacheKey: viewModel.getCacheKey(_arguments!.images[index].image),
                        errorWidget: (context, url, error) {
                          LogService.captureError(error);
                          return Icon(
                            MdiIcons.imageBroken,
                            size: 64,
                            color: colors.light.withOpacity(0.5),
                          );
                        },
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
              child: ContextMenuButton(attachment: _arguments!.images[_page - 1]),
            ))
      ],
    );
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
