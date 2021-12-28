import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

import 'skin/Skin.dart';

class IconReply extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Icon(
      Icons.reply,
      color: colors.text.withOpacity(0.38),
    );
  }
}
