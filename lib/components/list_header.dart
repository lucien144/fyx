import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class ListHeader extends StatelessWidget {
  final String label;
  final GestureTapCallback? onTap;

  ListHeader(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        decoration: BoxDecoration(color: colors.primary, border: Border(bottom: BorderSide(width: 1, color: colors.background.withOpacity(0.38)))),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(color: colors.background),
        ),
      ),
    );
  }
}
