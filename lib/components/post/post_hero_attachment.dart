import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/components/post/post_hero_attachment_box.dart';
import 'package:fyx/components/post/post_hero_attachment_image.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/features/gallery/presentation/gallery_screen.dart';
import 'package:fyx/features/gallery/presentation/gallery_viewmodel.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/shared/services/image_cache_service.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostHeroAttachment extends StatefulWidget {
  final dynamic attachment;
  final List<model.Image> images;
  final bool crop;
  final Function? onTap;
  final bool openGallery;
  final bool blur;
  final Size size;
  final bool showStrip;

  PostHeroAttachment(
    this.attachment, {
    this.images = const <model.Image>[],
    this.crop = true,
    this.showStrip = true,
    this.size = const Size(100, 100),
    this.onTap,
    this.openGallery = true,
    this.blur = false,
  });

  @override
  State<PostHeroAttachment> createState() => _PostHeroAttachmentState();
}

class _PostHeroAttachmentState extends State<PostHeroAttachment> {
  String? _cacheKey;

  @override
  void initState() {
    _cacheKey = widget.attachment.thumb;
    super.initState();
  }

  Future<void> _reloadImage() async {
    final url = widget.attachment.thumb;
    final newCacheKey = await ImageCacheService.invalidateAndReload(url);

    if (mounted) {
      setState(() => _cacheKey = newCacheKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;

    if (widget.attachment is model.Image) {
      return GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
          if (widget.openGallery) {
            // Load images into GalleryViewModel and open gallery screen
            getIt<GalleryViewModel>().loadImages(images: widget.images, currentImageUrl: (widget.attachment as model.Image).image);
            Navigator.of(context, rootNavigator: true).pushNamed('/gallery');
          }
        },
        onLongPress: () => showCupertinoModalBottomSheet(
            context: context,
            barrierColor: colors.dark.withOpacity(0.5),
            builder: (BuildContext context) => ListView.separated(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 48),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemCount: 2,
                  itemBuilder: (_, i) => [
                    ContextMenuItem(
                        label: 'Náhled v novém okně',
                        isColumn: false,
                        icon: MdiIcons.openInNew,
                        onTap: () {
                          T.openLink(widget.attachment.thumb, mode: SettingsProvider().linksMode);
                          Navigator.of(context).pop();
                        }),
                    ContextMenuItem(
                        label: 'Reload obrázku',
                        isColumn: false,
                        icon: Icons.refresh,
                        onTap: () {
                          Navigator.of(context).pop();
                          _reloadImage();
                        }),
                  ][i],
                )),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              PostHeroAttachmentImage(
                crop: widget.crop,
                size: widget.size,
                url: widget.attachment.thumb,
                cacheKey: _cacheKey,
              ),
              if (widget.blur) Positioned.fill(child: T.nsfwMask())
            ],
          ),
        ),
      );
    }

    if (widget.attachment is Link) {
      return PostHeroAttachmentBox(
        showStrip: widget.showStrip,
        title: (widget.attachment as Link).title,
        icon: Icons.link,
        size: widget.size,
        onTap: () => T.openLink((widget.attachment as Link).url, mode: SettingsProvider().linksMode),
      );
    }

    if (widget.attachment is Video) {
      var link = (widget.attachment as Video).link;
      return PostHeroAttachmentBox(
        title: link == null ? '' : link.title,
        showStrip: widget.showStrip,
        icon: Icons.play_circle_filled,
        image: (widget.attachment as Video).thumb,
        size: widget.size,
        onTap: link == null ? null : () => T.openLink(link.url, mode: SettingsProvider().linksMode),
      );
    }

    // TODO: Show an error message and open a github issue.
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
    );
  }
}
