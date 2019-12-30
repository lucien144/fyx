import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/Post.dart';

class DiscussionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Discussion discussion = ModalRoute.of(context).settings.arguments;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(discussion.jmeno, overflow: TextOverflow.ellipsis),
        trailing: Icon(CupertinoIcons.create),
      ),
      child: PullToRefreshList(
        dataProvider: () async {
          var data = await ApiController().loadDiscussion(discussion.idKlub);
          return (data as List).map((post) => PostListItem(Post.fromJson(post))).toList();
        },
      ),
    );
  }
}
