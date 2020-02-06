import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/T.dart';

class DiscussionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Discussion discussion = ModalRoute.of(context).settings.arguments;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(discussion.jmeno, overflow: TextOverflow.ellipsis),
      ),
      child: Stack(
        children: [
          PullToRefreshList(
            isInfinite: true,
            dataProvider: (lastId) async {
              var result = await ApiController().loadDiscussion(discussion.idKlub, lastId: lastId);
              var data = (result as List).map((post) => PostListItem(Post.fromJson(post))).toList();
              var id = Post.fromJson((result as List).last).id;
              return DataProviderResult(data, lastId: id);
            },
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: FloatingActionButton(
                backgroundColor: T.COLOR_PRIMARY,
                child: Icon(Icons.add),
                onPressed: () => Navigator.of(context).pushNamed('/discussion/new-message', arguments: discussion),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
