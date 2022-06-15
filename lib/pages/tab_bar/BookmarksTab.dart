import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/discussion_search_list_item.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/TabsEnum.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/reponses/BookmarksHistoryResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart' as provider;

final searchHistoryProvider = StateProvider<String?>(
  // We return the default sort type, here name.
  (ref) => null,
);

final searchBookmarksProvider = StateProvider<String?>(
  // We return the default sort type, here name.
  (ref) => null,
);

class BookmarksTab extends ConsumerStatefulWidget {
  // Unread filter toggle
  final bool filterUnread;

  final int refreshTimestamp;

  const BookmarksTab({Key? key, this.filterUnread = false, this.refreshTimestamp = 0}) : super(key: key);

  @override
  _BookmarksTabState createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab> {
  late PageController _bookmarksController;
  bool _filterUnread = false;

  TabsEnum activeTab = TabsEnum.history;
  List<int> _toggledCategories = [];
  int _refreshData = 0;

  @override
  void initState() {
    _filterUnread = widget.filterUnread;

    final defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;

    activeTab = [DefaultView.history, DefaultView.historyUnread].indexOf(defaultView) >= 0 ? TabsEnum.history : TabsEnum.bookmarks;
    if (activeTab == TabsEnum.bookmarks) {
      _bookmarksController = PageController(initialPage: 1);
    } else {
      _bookmarksController = PageController(initialPage: 0);
    }

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page! % 1 == 0 && activeTab != TabsEnum.values[_bookmarksController.page!.toInt()]) {
        setState(() {
          activeTab = TabsEnum.values[_bookmarksController.page!.toInt()];
        });
      }
    });

    super.initState();
  }

  // isInverted
  // Sometimes the activeTab var is changed after the listener where we call updateLatestView() finishes.
  // Therefore, the var activeTab needs to be handled as inverted.
  void updateLatestView({bool isInverted: false}) {
    DefaultView latestView = activeTab == TabsEnum.history ? DefaultView.history : DefaultView.bookmarks;
    if (isInverted) {
      latestView = activeTab == TabsEnum.history ? DefaultView.bookmarks : DefaultView.history;
    }

    if (_filterUnread) {
      latestView = latestView == DefaultView.bookmarks ? DefaultView.bookmarksUnread : DefaultView.historyUnread;
    }
    MainRepository().settings.latestView = latestView;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filterUnread != widget.filterUnread) {
      setState(() {
        _filterUnread = widget.filterUnread;
        _toggledCategories = [];
      });
      this.refreshData();
      this.updateLatestView();
    } else if (widget.refreshTimestamp > oldWidget.refreshTimestamp) {
      this.refreshData();
    }
  }

  refreshData() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    _bookmarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            trailing: GestureDetector(child: (() {
              if (activeTab == TabsEnum.history) {
                return ref.watch(searchHistoryProvider) == null ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_alt);
              }
              return ref.watch(searchBookmarksProvider) == null ? Icon(Icons.search) : Icon(Icons.search_off);
            })(), onTap: () {
              if (activeTab == TabsEnum.history) {
                if (ref.read(searchHistoryProvider.notifier).state == null) {
                  ref.read(searchHistoryProvider.notifier).state = ''; // Open the searchbox
                } else {
                  ref.read(searchHistoryProvider.notifier).state = null; // Close the searchbox
                  this.refreshData(); // ... and reset the List
                }
              } else {
                if (ref.read(searchBookmarksProvider.notifier).state == null) {
                  ref.read(searchBookmarksProvider.notifier).state = ''; // Open the searchbox
                } else {
                  ref.read(searchBookmarksProvider.notifier).state = null; // Close the searchbox
                  this.refreshData(); // ... and reset the List
                }
              }
            }),
            leading: provider.Consumer<NotificationsModel>(
                builder: (context, notifications, child) => NotificationBadge(
                    widget: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: kMinInteractiveDimensionCupertino - 10,
                        child: Icon(
                          Icons.notifications_none,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed('/notices')),
                    isVisible: notifications.newNotices > 0,
                    counter: notifications.newNotices)),
            middle: CupertinoSegmentedControl(
              groupValue: activeTab,
              onValueChanged: (value) {
                _bookmarksController.animateToPage(TabsEnum.values.indexOf(value as TabsEnum),
                    duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              children: {
                TabsEnum.history: Padding(
                  child: Text('Historie'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                TabsEnum.bookmarks: Padding(
                  child: Text('Sledované'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              },
            )),
        child: PageView(
          controller: _bookmarksController,
          onPageChanged: (int index) => this.updateLatestView(isInverted: true),
          pageSnapping: true,
          children: <Widget>[
            // -----
            // HISTORY PULL TO REFRESH
            // -----
            PullToRefreshList(
                rebuild: _refreshData,
                searchLabel: 'Filtruj kluby v historii...',
                searchProvider: searchHistoryProvider,
                onSearch: (term) => this.refreshData(),
                onSearchClear: () => this.refreshData(),
                dataProvider: (lastId) async {
                  List<DiscussionListItem> withReplies = [];
                  String? searchTerm = ref.read(searchHistoryProvider.notifier).state;
                  BookmarksHistoryResponse result = await ApiController().loadHistory();

                  var data = result.discussions
                      .map((discussion) => BookmarkedDiscussion.fromJson(discussion))
                      .where((discussion) => this._filterUnread ? discussion.unread > 0 : true)
                      .where((discussion) => searchTerm != null ? discussion.name.contains(RegExp(searchTerm, caseSensitive: false)) : true)
                      .map((discussion) => DiscussionListItem(discussion))
                      .where((discussionListItem) {
                    if (discussionListItem.discussion.replies > 0) {
                      withReplies.add(discussionListItem);
                      return false;
                    }
                    return true;
                  }).toList();
                  data.insertAll(0, withReplies);
                  return DataProviderResult(data);
                }),
            // -----
            // BOOKMARKS PULL TO REFRESH
            // -----
            PullToRefreshList(
                rebuild: _refreshData,
                searchLabel: 'Hledej diskuze, události a inzeráty...',
                searchProvider: searchBookmarksProvider,
                onSearch: (term) => this.refreshData(),
                onSearchClear: () => this.refreshData(),
                dataProvider: (lastId) async {
                  var categories = [];

                  try {
                    if (ref.read(searchBookmarksProvider.notifier).state != null && ref.read(searchBookmarksProvider.notifier).state != '') {
                      if (ref.read(searchBookmarksProvider.notifier).state!.length < 3) {
                        T.warn('Zkus hledat víc jak 3 znaky...');
                      } else {
                        final term = ref.read(searchBookmarksProvider.notifier).state;
                        final result = await ApiController().searchDiscussions(term!);
                        result.discussion.forEach((type, list) {
                          categories.add({
                            'header': ListHeader(L.search[type] ?? ''),
                            'items': list.map((model) => DiscussionSearchListItem(discussionId: model.id, child: Text(model.discussionName))).toList()
                          });
                        });
                        return DataProviderResult(categories);
                      }
                    }
                  } catch (error) {}

                  var result = await ApiController().loadBookmarks();
                  result.bookmarks.forEach((_bookmark) {
                    List<DiscussionListItem> withReplies = [];
                    var discussion = _bookmark.discussions
                        .where((discussion) {
                          // Filter by tapping on category headers
                          // If unread filter is ON
                          if (this._filterUnread) {
                            if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                              // If unread filter is ON and category toggle is ON, display discussions
                              return true;
                            } else {
                              // If unread filter is ON and category toggle is OFF, display unread discussions only
                              return discussion.unread > 0;
                            }
                          } else {
                            if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                              // If unread filter is OFF and category toggle is ON, hide discussions
                              return false;
                            }
                          }
                          // If unread filter is OFF and category toggle is OFF, show discussions
                          return true;
                        })
                        .map((discussion) => DiscussionListItem(discussion))
                        .where((discussionListItem) {
                          if (discussionListItem.discussion.replies > 0) {
                            withReplies.add(discussionListItem);
                            return false;
                          }
                          return true;
                        })
                        .toList();
                    discussion.insertAll(0, withReplies);
                    categories.add({
                      'header': ListHeader(_bookmark.categoryName, onTap: () {
                        if (_toggledCategories.indexOf(_bookmark.categoryId) >= 0) {
                          // Hide discussions in the category
                          setState(() => _toggledCategories.remove(_bookmark.categoryId));
                        } else {
                          // Show discussions in the category
                          setState(() => _toggledCategories.add(_bookmark.categoryId));
                        }
                        this.refreshData();
                      }),
                      'items': discussion
                    });
                  });
                  return DataProviderResult(categories);
                }),
          ],
        ),
      );
    });
  }
}
