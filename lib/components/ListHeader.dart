import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  final String label;
  final Function? onTap;

  ListHeader(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.onTap!(),
      child: Container(
        decoration: BoxDecoration(color: CupertinoTheme.of(context).primaryColor, border: Border(bottom: BorderSide(width: 1, color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.38)))),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(color: CupertinoTheme.of(context).scaffoldBackgroundColor),
        ),
      ),
    );
  }
}
