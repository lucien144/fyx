import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/components/discussion_page_scaffold.dart';
import 'package:fyx/components/post/advertisement.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/Settings.dart';
import 'package:fyx/model/enums/DiscussionTypeEnum.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/pages/discussion_home_page.dart';
import 'package:fyx/state/batch_actions_provider.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tap_canvas/tap_canvas.dart';

class DiscussionPageArguments {
  final int discussionId;
  final int? postId;
  final String? filterByUser;
  final String? search;

  DiscussionPageArguments(this.discussionId, {this.postId, this.filterByUser, this.search});
}

class DiscussionPage extends ConsumerStatefulWidget {
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  final AsyncMemoizer<DiscussionResponse> _memoizer = AsyncMemoizer<DiscussionResponse>();
  late SkinColors colors;
  int _refreshList = 0;
  bool _hasInitData = false;

  // Did we close the context menu by tapping outside?
  // Tapping on menu button is outside click. -> This toggle solves the issue of closing and immediate opening
  // the menu when the menu is open and user clicks on three dots...
  bool _closedByOutsideTap = false;

  // Display the context menu?
  bool _popupMenu = false;

  // Is the discussion saved in bookmarks?
  bool? _bookmark;

  String? _searchTerm;

  // Progress indicator if some posts are being deleted...
  bool _deleting = false;

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
            if (snapshot.data!.error) {
              return T.feedbackScreen(context,
                  isWarning: true,
                  title: 'Něco se pokazilo.\nChybu, prosím, nahlašte ID LUCIEN.',
                  label: L.GENERAL_CLOSE,
                  onPress: () => Navigator.of(context).pop());
            } else if (snapshot.data!.discussion.accessDenied) {
              return T.feedbackScreen(context,
                  title: L.ACCESS_DENIED_ERROR, icon: Icons.do_not_disturb_alt, label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
            }
            _bookmark ??= (snapshot.data!.discussion.bookmark?.bookmark ?? false);
            return this._createDiscussionPage(snapshot.data!, pageArguments);
          }
          return _pageScaffold(title: L.GENERAL_LOADING, body: T.feedbackScreen(context, isLoading: true));
        });
  }

  Widget _pageScaffold({required String title, required Widget body, DiscussionResponse? discussionResponse}) {
    return DiscussionPageScaffold(
        title: title,
        child: body,
        trailing: Visibility(
          visible: discussionResponse != null && discussionResponse.discussion.type == DiscussionTypeEnum.discussion,
          child: GestureDetector(
            onTap: () {
              if (_closedByOutsideTap) {
                setState(() => _closedByOutsideTap = false); // reset _closedByOutsideTap
                return;
              }
              setState(() => _popupMenu = true);
            },
            child: Icon(Icons.more_horiz),
          ),
        ));
  }

  Widget _createDiscussionPage(DiscussionResponse discussionResponse, DiscussionPageArguments pageArguments) {
    // Save the language context for further use
    // TODO: Not ideal, probably better to use Provider. Or not?
    SyntaxHighlighter.languageContext = discussionResponse.discussion.name;

    final textStyleContext = TextStyle(fontSize: Settings().fontSize);

    return _pageScaffold(
        discussionResponse: discussionResponse,
        title: discussionResponse.discussion.name,
        body: Stack(
          children: [
            PullToRefreshList<AutoDisposeStateProvider<String?>>(
              searchLabel: 'Hledej @nick a nebo text...',
              searchTerm: this._searchTerm,
              onSearch: (term) {
                setState(() => this._searchTerm = term);
                this.refresh();
              },
              onSearchClear: () {
                setState(() => this._searchTerm = '');
                this.refresh();
              },
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
                  var response = await ApiController()
                      .loadDiscussion(pageArguments.discussionId, lastId: lastId, user: pageArguments.filterByUser, search: this._searchTerm);
                  result = response.posts;
                } else {
                  // If we load init data or we refresh data on pull
                  if (!this._hasInitData) {
                    // If we load init data, use the data from FutureBuilder
                    result = discussionResponse.posts;
                    this._hasInitData = true;
                  } else {
                    // If we just pull to refresh, load a fresh data
                    var response =
                        await ApiController().loadDiscussion(pageArguments.discussionId, user: pageArguments.filterByUser, search: this._searchTerm);
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
                return DataProviderResult(data,
                    lastId: id, postId: pageArguments.postId, jumpIndex: data.where((listItem) => listItem.post.isNew).length);
              },
            ),
            Visibility(
              visible: discussionResponse.discussion.accessRights.canWrite != false || discussionResponse.discussion.rights.canWrite != false,
              child: Positioned(
                right: 20,
                left: 20,
                bottom: 20,
                child: SafeArea(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: ref.watch(PostsSelection.provider).isEmpty ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                    children: [
                      if (ref.watch(PostsSelection.provider).isNotEmpty)
                        FloatingActionButton(
                          backgroundColor: _deleting ? colors.danger.withOpacity(.5) : colors.danger,
                          foregroundColor: colors.background,
                          child: Stack(alignment: Alignment.bottomCenter, children: [
                            Opacity(opacity: _deleting ? 0.2 : 1, child: Icon(Icons.delete, size: 40)),
                            Positioned(
                              bottom: 5,
                              child: Opacity(
                                opacity: _deleting ? 0.2 : 1,
                                child: Text(
                                  ref.read(PostsSelection.provider).length.toString(),
                                  style: TextStyle(color: colors.danger),
                                ),
                              ),
                            ),
                            if (_deleting) Positioned.fill(child: CupertinoActivityIndicator()),
                          ]),
                          onPressed: _deleting
                              ? null
                              : () async {
                                  setState(() => _deleting = true);
                                  try {
                                    await Future.wait(ref
                                        .read(PostsSelection.provider)
                                        .map((id) => ApiController().deleteDiscussionMessage(discussionResponse.discussion.idKlub, id).then((_) {
                                              ref.read(PostsToDelete.provider.notifier).add(id);
                                              ref.read(PostsSelection.provider.notifier).remove(id);
                                            })));
                                    T.success('Smazáno.');
                                  } catch (error) {
                                    T.warn('Některé příspěvky se nepodařilo smazat.');
                                  } finally {
                                    setState(() => _deleting = false);
                                  }
                                },
                        ),
                      if (ref.watch(PostsSelection.provider).isNotEmpty)
                        FloatingActionButton(
                          backgroundColor: colors.text,
                          foregroundColor: colors.background,
                          child: Icon(Icons.cancel_rounded),
                          onPressed: () => ref.read(PostsSelection.provider.notifier).reset(),
                        ),
                      if (ref.watch(PostsSelection.provider).isEmpty)
                        FloatingActionButton(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.background,
                          child: Icon(Icons.add),
                          onPressed: () => Navigator.of(context).pushNamed('/new-message',
                              arguments: NewMessageSettings(
                                  onClose: this.refresh,
                                  onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                                    var result =
                                        await ApiController().postDiscussionMessage(pageArguments.discussionId, message, attachments: attachments);
                                    return result.isOk;
                                  })),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            TapOutsideDetectorWidget(
              onTappedOutside: () {
                if (_popupMenu) {
                  setState(() {
                    _popupMenu = false;
                    _closedByOutsideTap = true;
                  });
                  return;
                }
                setState(() => _closedByOutsideTap = false); // reset _closedByOutsideTap
              },
              child: Positioned(
                top: 10,
                right: 12,
                child: AnimatedOpacity(
                  opacity: _popupMenu ? 1 : 0,
                  duration: Duration(milliseconds: 280),
                  curve: Curves.linearToEaseOut,
                  child: AnimatedScale(
                    curve: Curves.linearToEaseOut,
                    scale: _popupMenu ? 1 : 0,
                    alignment: Alignment.topRight,
                    duration: Duration(milliseconds: 280),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              color: colors.grey.withOpacity(0.4), //New
                              blurRadius: 15.0,
                              offset: Offset(0, 0))
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: colors.barBackground),
                        child: IntrinsicWidth(
                          child: Column(children: [
                            Visibility(
                              visible: _bookmark != null,
                              child: GestureDetector(
                                onTap: () {
                                  ApiController().bookmarkDiscussion(discussionResponse.discussion.idKlub, !_bookmark!);
                                  setState(() {
                                    _bookmark = !_bookmark!;
                                    _popupMenu = false;
                                    T.success(_bookmark! ? 'Přidáno do sledovaných.' : 'Odebráno ze sledovaných', duration: 1);
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(child: Text(_bookmark! ? 'Klub sleduješ' : 'Klub nesleduješ', style: textStyleContext)),
                                    _bookmark! ? Icon(MdiIcons.pin) : Icon(MdiIcons.pinOutline),
                                  ],
                                ),
                              ),
                            ),
                            if (discussionResponse.discussion.hasHeader)
                              Divider(
                                color: colors.grey,
                                height: 26,
                              ),
                            if (discussionResponse.discussion.hasHeader)
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/discussion/header', arguments: new DiscussionHomePageArguments(discussionResponse)),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Záhlaví', style: textStyleContext)),
                                    Icon(MdiIcons.pageLayoutHeader),
                                  ],
                                ),
                              ),
                            if (discussionResponse.discussion.hasHome)
                              Divider(
                                color: colors.grey,
                                height: 26,
                              ),
                            if (discussionResponse.discussion.hasHome)
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/discussion/home', arguments: new DiscussionHomePageArguments(discussionResponse)),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Nástěnka', style: textStyleContext)),
                                    Icon(MdiIcons.viewDashboardOutline),
                                  ],
                                ),
                              ),
                            Divider(
                              color: colors.grey,
                              height: 26,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  this._searchTerm = this._searchTerm == null ? '' : null;
                                  this._popupMenu = false;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(this._searchTerm == null ? 'Hledat v diskuzi' : 'Zavřít hledání', style: textStyleContext),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(child: Icon(this._searchTerm == null ? MdiIcons.magnify : MdiIcons.magnifyRemoveOutline)),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
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
                  '↑ Nové příspěvky ($unseenCount)',
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
