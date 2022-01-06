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
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/provider/DiscussionPageNotifier.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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
              child: Text(title, style: TextStyle(color: colors.text), overflow: TextOverflow.ellipsis))),
      child: body,
    );
  }

  Widget _createDiscussionPage(DiscussionResponse discussionResponse, DiscussionPageArguments pageArguments) {
    // Save the language context for further use
    // TODO: Not ideal, probably better to use Provider. Or not?
    SyntaxHighlighter.languageContext = discussionResponse.discussion.name;

    return _pageScaffold(
        title: discussionResponse.discussion.name.replaceAll('', '\u{200B}'),
        body: Stack(
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
                          .where((item) => (item as PostListItem).post.id != Provider.of<DiscussionPageNotifier>(context).deletedPostId)
                          .toList();
                    }
                    // Do not keep the id of the deleted post.
                    Provider.of<DiscussionPageNotifier>(context, listen: false).resetPostId();
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
}
