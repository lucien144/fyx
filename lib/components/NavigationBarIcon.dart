import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';

class NavigationBarIcon extends StatelessWidget {
  final IconData icon;
  final Color _color;
  final double _size;

  NavigationBarIcon(this.icon, {Color color = T.COLOR_PRIMARY, double size = 28.0})
      : this._color = color,
        this._size = size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          color: _color,
          fontSize: _size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    );
  }
}
