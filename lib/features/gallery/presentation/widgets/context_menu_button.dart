import 'package:flutter/cupertino.dart';
import 'package:fyx/features/gallery/presentation/widgets/download_button.dart';
import 'package:fyx/features/gallery/presentation/widgets/open_button.dart';
import 'package:fyx/features/gallery/presentation/widgets/reload_button.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ContextMenuButton extends StatelessWidget {
  const ContextMenuButton({Key? key, required this.attachment}) : super(key: key);
  final model.Image attachment;

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    return CupertinoButton(
        padding: EdgeInsets.zero,
        color: colors.primary,
        child: Icon(
          MdiIcons.dotsHorizontal,
          color: colors.background,
          size: 32,
        ),
        onPressed: () => showCupertinoModalBottomSheet(
            context: context,
            barrierColor: colors.dark.withOpacity(0.5),
            builder: (BuildContext context) => ListView.separated(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 48),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemCount: 3,
                  itemBuilder: (_, i) => [
                    DownloadButton(url: attachment.image),
                    OpenButton(url: attachment.image),
                    ReloadButton(url: attachment.image),
                  ][i],
                )));
  }
}
