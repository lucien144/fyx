import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/DiscussionResponse.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/T.dart';

class DiscussionPageArguments {
  final int discussionId;
  final int postId;

  DiscussionPageArguments(this.discussionId, {this.postId});
}

class DiscussionPage extends StatefulWidget {
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> with WidgetsBindingObserver {
  final AsyncMemoizer _memoizer = AsyncMemoizer<DiscussionResponse>();
  int _refreshList = 0;

  Future<DiscussionResponse> _fetchData(discussionId, postId) {
    return this._memoizer.runOnce(() {
      return ApiController().loadDiscussion(discussionId, lastId: postId);
    });
  }

  refresh() {
    setState(() => _refreshList = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      this.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    DiscussionPageArguments pageArguments = ModalRoute.of(context).settings.arguments;

    return FutureBuilder<DiscussionResponse>(
        future: _fetchData(pageArguments.discussionId, pageArguments.postId),
        builder: (BuildContext context, AsyncSnapshot<DiscussionResponse> snapshot) {
          if (snapshot.hasData) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: Colors.white,
                leading: CupertinoNavigationBarBackButton(
                  color: T.COLOR_PRIMARY,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                middle: Text(snapshot.data.discussion['name'], overflow: TextOverflow.ellipsis),
              ),
              child: Stack(
                children: [
                  PullToRefreshList(
                    rebuild: _refreshList,
                    isInfinite: true,
                    dataProvider: (lastId) async {
                      var result;
                      if (lastId != null) {
                        var response = await ApiController().loadDiscussion(pageArguments.discussionId, lastId: lastId);
                        result = response.data;
                      } else {
                        result = snapshot.data.data;
                      }
                      var data = (result as List).map((post) => PostListItem(Post.fromJson(post, pageArguments.discussionId), onUpdate: this.refresh)).toList();
                      var id = Post.fromJson((result as List).last, pageArguments.discussionId).id;
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
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/discussion/new-message', arguments: NewMessageSettings(pageArguments.discussionId, onClose: this.refresh)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // TODO
            return Container(child: Text('error ${snapshot.error.toString()}'), color: Colors.white);
          } else {
            return Container(
              child: Text('loading'),
              color: Colors.white,
            );
          }
        });
  }
}
