import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconUnread extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.markunread_mailbox,
      color: CupertinoTheme.of(context).textTheme.textStyle.color!.withOpacity(0.38),
    );
  }
}
