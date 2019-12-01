import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/Discussion.dart';

class DiscussionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Discussion discussion = ModalRoute.of(context).settings.arguments;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(discussion.jmeno, overflow: TextOverflow.ellipsis),
        trailing: Icon(CupertinoIcons.create),
      ),
      child: Container(),
    );
  }
}
