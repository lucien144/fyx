import 'package:flutter/cupertino.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OpenButton extends StatelessWidget {
  const OpenButton({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    return ContextMenuItem(
      isColumn: false,
      icon: MdiIcons.openInNew,
      onTap: () {
        T.openLink(url, mode: SettingsProvider().linksMode);
        Navigator.of(context).pop();
      },
      label: 'Otevřít v prohlížeči',
    );
  }
}
