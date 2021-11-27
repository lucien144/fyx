import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconReply extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.reply,
      color: CupertinoTheme.of(context).textTheme.textStyle.color!.withOpacity(0.38),
    );
  }
}
