import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';

class ListHeader extends StatelessWidget {
  final String title;

  const ListHeader({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PlatformTheme.of(context).primaryColor,
      padding: EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
