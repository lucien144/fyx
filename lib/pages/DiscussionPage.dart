import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/Advertisement.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/components/post/SyntaxHighlighter.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  late SkinColors colors;
  int _refreshList = 0;
  bool _hasInitData = false;

  Future<DiscussionResponse> _fetchData(discussionId, postId, user, {String? search}) {
    return this._memoizer.runOnce(() {
      return Future.delayed(
          Duration(milliseconds: 300), () => ApiController().loadDiscussion(discussionId, lastId: postId, user: user, search: search));
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
    colors = Skin.of(context).theme.colors;
    DiscussionPageArguments? pageArguments = ModalRoute.of(context)?.settings.arguments as DiscussionPageArguments?;

    if (pageArguments == null) {
      return T.feedbackScreen(context, title: 'Chyba, nelze načíst diskuzi.');
    }

    return FutureBuilder<DiscussionResponse>(
        future: _fetchData(pageArguments.discussionId, pageArguments.postId, pageArguments.filterByUser, search: pageArguments.search),
        builder: (BuildContext context, AsyncSnapshot<DiscussionResponse> snapshot) {
          if (snapshot.hasError) {
            return T.feedbackScreen(context,
                isWarning: true, title: snapshot.error.toString(), label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
          }
          if (snapshot.hasData) {
            if (snapshot.data!.discussion.accessDenied) {
              return T.feedbackScreen(context,
                  title: L.ACCESS_DENIED_ERROR, icon: Icons.do_not_disturb_alt, label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
            }
            return this._createDiscussionPage(snapshot.data!, pageArguments);
          }
          return _pageScaffold(title: L.GENERAL_LOADING, body: T.feedbackScreen(context, isLoading: true));
        });
  }

  Widget _pageScaffold({required String title, required Widget body}) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            color: colors.primary,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width - 120,
              child: Tooltip(
                message: title,
                child: Text(title.replaceAll('', '\u{200B}'), style: TextStyle(color: colors.text), overflow: TextOverflow.ellipsis),
                padding: EdgeInsets.all(8.0), // needed until https://github.com/flutter/flutter/issues/86170 is fixed
                margin: EdgeInsets.all(8.0),
                showDuration: Duration(seconds: 3),
              ))),
      child: body,
    );
  }

  Widget _createDiscussionPage(DiscussionResponse discussionResponse, DiscussionPageArguments pageArguments) {
    // Save the language context for further use
    // TODO: Not ideal, probably better to use Provider. Or not?
    SyntaxHighlighter.languageContext = discussionResponse.discussion.name;

    return _pageScaffold(
        title: discussionResponse.discussion.name,
        body: Stack(
          children: [
            NotificationListener<PostDeleteFailNotification>(
              onNotification: (notification) {
                void rebuild(Element el) {
                  el.markNeedsBuild();
                  el.visitChildren(rebuild);
                }

                // Rebuild the widget tree if Dismissible didn't removed the item due to the server error.
                (context as Element).visitChildren(rebuild);
                return false;
              },
              child: PullToRefreshList(
                rebuild: _refreshList,
                isInfinite: true,
                pinnedWidget: getPinnedWidget(discussionResponse),
                sliverListBuilder: (List data, {controller}) {
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
                      final kUnreadIndex = filtered.lastIndexWhere((item) => (item as PostListItem).post.isNew);
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final postItem = AutoScrollTag(child: filtered[i], key: ValueKey(i), index: i, controller: controller);
                            if (i == kUnreadIndex) {
                              return unseenPill(postItem, kUnreadIndex + 1);
                            }
                            return postItem;
                          },
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
                  List<PostListItem> data = (result as List)
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
                  return DataProviderResult(data, lastId: id, jumpIndex: data.where((listItem) => listItem.post.isNew).length);
                },
              ),
            ),
            Visibility(
              visible: discussionResponse.discussion.accessRights.canWrite != false || discussionResponse.discussion.rights.canWrite != false,
              child: Positioned(
                right: 20,
                bottom: 20,
                child: SafeArea(
                  child: FloatingActionButton(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.background,
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
        ));
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

  Widget unseenPill(Widget postItem, unseenCount) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        postItem,
        const Divider(
          height: 8,
          thickness: 8,
        ),
        Container(
          color: colors.grey.withOpacity(.1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                child: Text(
                  '↑ Nové příspěvky ($unseenCount})',
                  style: TextStyle(color: colors.background, fontSize: FontSize.medium.size),
                ),
                decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.all(Radius.circular(12))),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              ),
            ),
          ),
        )
      ],
    );
  }
}
