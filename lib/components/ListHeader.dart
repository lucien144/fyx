import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';

class ListHeader extends StatelessWidget {
  final String label;
  final Function onTap;

  ListHeader(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.onTap is Function ? this.onTap() : null,
      child: Container(
        decoration: BoxDecoration(color: PlatformTheme.of(context).primaryColor, border: Border(bottom: BorderSide(width: 1, color: Colors.white38))),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
