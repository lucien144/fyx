import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../FyxApp.dart';

class DiscussionPageArguments {
  final int discussionId;
  final int postId;

  DiscussionPageArguments(this.discussionId, {this.postId});
}

class DiscussionPage extends StatefulWidget {
  static int deeplinkDepth = 0;

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> with RouteAware, WidgetsBindingObserver {
  final AsyncMemoizer _memoizer = AsyncMemoizer<DiscussionResponse>();
  int _refreshList = 0;
  bool _hasBackToRootButton = false;
  bool _hasInitData = false;

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
    FyxApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent) {
      this.refresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FyxApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  void didPush() {
    if (DiscussionPage.deeplinkDepth < 0) {
      DiscussionPage.deeplinkDepth = 0;
    }
    setState(() => _hasBackToRootButton = DiscussionPage.deeplinkDepth > 0);
  }

  void didPop() {
    DiscussionPage.deeplinkDepth--;
    if (DiscussionPage.deeplinkDepth < 0) {
      DiscussionPage.deeplinkDepth = 0;
    }
    setState(() => _hasBackToRootButton = DiscussionPage.deeplinkDepth > 0);
  }

  @override
  Widget build(BuildContext context) {
    DiscussionPageArguments pageArguments = ModalRoute.of(context).settings.arguments;

    return FutureBuilder<DiscussionResponse>(
        future: _fetchData(pageArguments.discussionId, pageArguments.postId),
        builder: (BuildContext context, AsyncSnapshot<DiscussionResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.discussion.accessDenied) {
              return PlatformTheme.feedbackScreen(title: L.ACCESS_DENIED_ERROR, icon: Icons.do_not_disturb_alt, label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
            }
            return this._createDiscussionPage(snapshot.data, pageArguments);
          } else if (snapshot.hasError) {
            return PlatformTheme.feedbackScreen(isWarning: true, title: snapshot.error.toString(), label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
          } else {
            return PlatformTheme.feedbackScreen(isLoading: true);
          }
        });
  }

  Widget _createDiscussionPage(DiscussionResponse discussionResponse, DiscussionPageArguments pageArguments) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: CupertinoNavigationBarBackButton(
          color: T.COLOR_PRIMARY,
          onPressed: () {
            DiscussionPage.deeplinkDepth = 0;
            Navigator.of(context).pop();
          },
        ),
        middle: Text(discussionResponse.discussion.name, overflow: TextOverflow.ellipsis),
      ),
      child: Stack(
        children: [
          PullToRefreshList(
            rebuild: _refreshList,
            isInfinite: true,
            sliverListBuilder: (List data) {
              return ValueListenableBuilder(
                valueListenable: MainRepository().settings.box.listenable(keys: ['blockedPosts', 'blockedUsers']),
                builder: (BuildContext context, value, Widget child) {
                  var filtered = data;
                  if (data[0] is PostListItem) {
                    filtered = data
                        .where((item) => !MainRepository().settings.isPostBlocked((item as PostListItem).post.id))
                        .where((item) => !MainRepository().settings.isUserBlocked((item as PostListItem).post.nick))
                        .toList();
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => filtered[i],
                      childCount: filtered.length,
                    ),
                  );
                },
              );
            },
            dataProvider: (lastId) async {
              var result;
              if (lastId != null) {
                // If we load next page(s)
                var response = await ApiController().loadDiscussion(pageArguments.discussionId, lastId: lastId);
                result = response.data;
              } else {
                // If we load init data or we refresh data on pull
                if (!this._hasInitData) {
                  // If we load init data, use the data from FutureBuilder
                  result = discussionResponse.data;
                  this._hasInitData = true;
                } else {
                  // If we just pull to refresh, load a fresh data
                  var response = await ApiController().loadDiscussion(pageArguments.discussionId);
                  result = response.data;
                }
              }
              var data = (result as List)
                  .map((post) {
                    return Post.fromJson(post, pageArguments.discussionId);
                  })
                  .where((post) => !MainRepository().settings.isPostBlocked(post.id))
                  .where((post) => !MainRepository().settings.isUserBlocked(post.nick))
                  .map((post) => PostListItem(post, onUpdate: this.refresh, isHighlighted: post.id > discussionResponse.discussion.lastVisit))
                  .toList();

              int id;
              try {
                id = Post.fromJson((result as List).last, pageArguments.discussionId).id;
              } catch (error) {}
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
                onPressed: () => Navigator.of(context).pushNamed('/new-message',
                    arguments: NewMessageSettings(
                        onClose: this.refresh,
                        onSubmit: (String inputField, String message, Map<String, dynamic> attachment) async {
                          var result = await ApiController().postDiscussionMessage(pageArguments.discussionId, message, attachment: attachment);
                          return result.isOk;
                        })),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
