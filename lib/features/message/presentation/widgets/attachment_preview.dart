import 'package:flutter/material.dart';
import 'package:fyx/features/message/domain/entities/attachment.dart';
import 'package:fyx/features/message/domain/enums/image_quality.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AttachmentPreview extends StatefulWidget {
  final Attachment attachment;

  const AttachmentPreview({Key? key, required this.attachment}) : super(key: key);

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  final double kSize = 40;

  Widget defaultPreview({required Widget child, required SkinColors colors}) {
    return Container(
      alignment: Alignment.center,
      width: kSize,
      height: kSize,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: colors.grey.withOpacity(0.1)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    final viewModel = getIt<MessageViewModel>();
    final attachment = widget.attachment;
    final isImage = attachment.mediaType.type == 'image';
    final isVideo = ['video'].contains(attachment.mediaType.type);
    final isFile = !['image', 'video'].contains(attachment.mediaType.type);

    return Container(
      decoration: BoxDecoration(color: colors.barBackground, borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: switch (attachment.mediaType.type) {
                'image' => Image.memory(attachment.bytes,
                    width: kSize,
                    height: kSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => defaultPreview(
                          child: Icon(MdiIcons.alert),
                          colors: colors,
                        )),
                'video' => defaultPreview(child: Icon(MdiIcons.video), colors: colors),
                _ => defaultPreview(
                    child: Text(
                      '.${attachment.extension}',
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 10),
                    ),
                    colors: colors)
              },
            ),
          ),
          Expanded(
              child: Text(
            (isFile || isVideo) ? attachment.filename : '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12),
          )),
          const SizedBox(width: 6),
          if (isImage)
            Container(
              height: 30,
              child: ToggleButtons(
                children: ImageQuality.values.map((iq) {
                  if (iq == ImageQuality.url) {
                    return Icon(MdiIcons.linkVariant, size: 14,);
                  }
                  return Text(iq.name.toUpperCase(), style: TextStyle(fontSize: 11));
                }).toList(),
                isSelected: ImageQuality.values.map((q) => q == attachment.quality).toList(),
                borderRadius: BorderRadius.circular(8),
                onPressed: (index) {
                  viewModel.updateAttachmentQuality(attachment, ImageQuality.values[index]);
                },
              ),
            ),
          const SizedBox(width: 6),
          GestureDetector(
            child: Icon(MdiIcons.trashCanOutline),
            onTap: () => viewModel.removeAttachment(attachment.bytes),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
