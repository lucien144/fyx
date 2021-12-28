import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class IconUnread extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Icon(
      Icons.markunread_mailbox,
      color: colors.text.withOpacity(0.38),
    );
  }
}
