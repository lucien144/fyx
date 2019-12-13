import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/ListHeader.dart';
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
        middle: Text(discussion.jmeno, overflow: TextOverflow.ellipsis),
        trailing: Icon(CupertinoIcons.create),
      ),
      child: PullToRefreshList<PostListItem, ListHeader>(
        itemBuilder: (dynamic data) => (data as List).map((post) => PostListItem(Post.fromJson(post))).toList(),
        loadData: () => ApiController().loadDiscussion(discussion.idKlub),
      ),
    );
  }
}
