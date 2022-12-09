import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class TextIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;

  const TextIcon(this.label, {Key? key, required this.icon, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          this.icon,
          color: this.iconColor,
        ),
        SizedBox(
          width: 8,
        ),
        Text(this.label, style: TextStyle(color: this.iconColor != null ? this.iconColor : colors.text.withOpacity(0.38), fontSize: 14))
      ],
    );
  }
}
