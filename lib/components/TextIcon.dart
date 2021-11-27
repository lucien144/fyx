import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;

  const TextIcon(this.label, {Key? key, required this.icon, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Text(this.label)
      ],
    );
  }
}
