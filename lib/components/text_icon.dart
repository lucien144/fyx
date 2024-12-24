import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class TextIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final bool shader;

  const TextIcon(this.label, {Key? key, required this.icon, this.iconColor, this.shader = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var _icon = Icon(
      this.icon,
      color: this.iconColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(this.shader) ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => LinearGradient(
            stops: [.3, .4, .7],
            colors: [
              Colors.white,
              Colors.red,
              Colors.blue,
            ],
          ).createShader(bounds),
          child: _icon,
        ),
        if (!this.shader) _icon,
        SizedBox(width: 8,),
        Text(this.label, style: TextStyle(color: this.iconColor != null ? this.iconColor : colors.text.withOpacity(0.38), fontSize: 14))
      ],
    );
  }
}
