import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/Advertisement.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/components/post/SyntaxHighlighter.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/DiscussionOwner.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DiscussionPageArguments {
  final int discussionId;
  final int? postId;
  final String? filterByUser;
  final String? search;

  DiscussionPageArguments(this.discussionId, {this.postId, this.filterByUser, this.search});
}

class DiscussionPage extends StatefulWidget {
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final AsyncMemoizer<DiscussionResponse> _memoizer = AsyncMemoizer<DiscussionResponse>();
  int _refreshList = 0;
  bool _hasInitData = false;

  Future<DiscussionResponse> _fetchData(discussionId, postId, user, {String? search}) {
    return this._memoizer.runOnce(() {
      return ApiController().loadDiscussion(discussionId, lastId: postId, user: user, search: search);
    });
  }

  refresh() {
    setState(() => _refreshList = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    super.initState();
    AnalyticsProvider().setScreen('Discussion', 'DiscussionPage');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    DiscussionPageArguments? pageArguments = ModalRoute.of(context)?.settings.arguments as DiscussionPageArguments?;

    if (pageArguments == null) {
      return T.feedbackScreen(title: 'Chyba, nelze načíst diskuzi.');
    }

    return FutureBuilder<DiscussionResponse>(
        future: _fetchData(pageArguments.discussionId, pageArguments.postId, pageArguments.filterByUser, search: pageArguments.search),
        builder: (BuildContext context, AsyncSnapshot<DiscussionResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.discussion.accessDenied) {
              return T.feedbackScreen(title: L.ACCESS_DENIED_ERROR, icon: Icons.do_not_disturb_alt, label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
            }
            return this._createDiscussionPage(snapshot.data!, pageArguments);
          } else if (snapshot.hasError) {
            return T.feedbackScreen(isWarning: true, title: snapshot.error.toString(), label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
          } else {
            return T.feedbackScreen(isLoading: true);
          }
        });
  }

  Widget _createDiscussionPage(DiscussionResponse discussionResponse, DiscussionPageArguments pageArguments) {
    // Save the language context for further use
    // TODO: Not ideal, probably better to use Provider. Or not?
    SyntaxHighlighter.languageContext = discussionResponse.discussion.name;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: CupertinoNavigationBarBackButton(
            color: T.COLOR_PRIMARY,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width - 120,
              child: Text(discussionResponse.discussion.name.replaceAll('', '\u{200B}'), overflow: TextOverflow.ellipsis))),
      child: Stack(
        children: [
          PullToRefreshList(
            rebuild: _refreshList,
            isInfinite: true,
            pinnedWidget: getPinnedWidget(discussionResponse),
            sliverListBuilder: (List data) {
              return ValueListenableBuilder(
                valueListenable: MainRepository().settings.box.listenable(keys: ['blockedPosts', 'blockedUsers']),
                builder: (BuildContext context, value, Widget? child) {
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
                var response = await ApiController().loadDiscussion(pageArguments.discussionId, lastId: lastId, user: pageArguments.filterByUser);
                result = response.posts;
              } else {
                // If we load init data or we refresh data on pull
                if (!this._hasInitData) {
                  // If we load init data, use the data from FutureBuilder
                  result = discussionResponse.posts;
                  this._hasInitData = true;
                } else {
                  // If we just pull to refresh, load a fresh data
                  var response = await ApiController().loadDiscussion(pageArguments.discussionId, user: pageArguments.filterByUser);
                  result = response.posts;
                }
              }
              List<Widget> data = (result as List)
                  .map((post) {
                    return Post.fromJson(post, pageArguments.discussionId, isCompact: MainRepository().settings.useCompactMode);
                  })
                  .where((post) => !MainRepository().settings.isPostBlocked(post.id))
                  .where((post) => !MainRepository().settings.isUserBlocked(post.nick))
                  .map((post) => PostListItem(post, onUpdate: this.refresh, isHighlighted: post.isNew))
                  .toList();

              int? id;
              try {
                id = Post.fromJson((result as List).last, pageArguments.discussionId, isCompact: MainRepository().settings.useCompactMode).id;
              } catch (error) {}
              return DataProviderResult(data, lastId: id);
            },
          ),
          Visibility(
            visible: discussionResponse.discussion.accessRights.canWrite != false || discussionResponse.discussion.rights.canWrite != false,
            child: Positioned(
              right: 20,
              bottom: 20,
              child: SafeArea(
                child: FloatingActionButton(
                  backgroundColor: T.COLOR_PRIMARY,
                  child: Icon(Icons.add),
                  onPressed: () => Navigator.of(context).pushNamed('/new-message',
                      arguments: NewMessageSettings(
                          onClose: this.refresh,
                          onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                            var result = await ApiController().postDiscussionMessage(pageArguments.discussionId, message, attachments: attachments);
                            return result.isOk;
                          })),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? getPinnedWidget(DiscussionResponse discussionResponse) {
    switch (discussionResponse.discussion.advertisement.runtimeType) {
      case ContentAdvertisement:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Advertisement(
            discussionResponse.discussion.advertisement!,
            title: discussionResponse.discussion.name,
            username: discussionResponse.discussion.owner != null ? discussionResponse.discussion.owner!.username : '',
          ),
        );
      default:
        return null;
    }
  }
}
