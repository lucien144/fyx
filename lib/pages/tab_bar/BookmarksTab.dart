import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:provider/provider.dart';

class BookmarksTab extends StatefulWidget {
  // Unread filter toggle
  final bool filterUnread;

  // Boolean to refresh data only if the BookmarksTab is activated on the screen
  final bool isActivated;

  const BookmarksTab({Key? key, this.filterUnread = false, this.isActivated = false}) : super(key: key);

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  late PageController _bookmarksController;
  bool _filterUnread = false;
  bool _isActivated = false;

  ETabs activeTab = ETabs.history;
  DefaultView _defaultView = DefaultView.history;
  List<int> _toggledCategories = [];
  int _refreshData = 0;

  @override
  void initState() {
    _filterUnread = widget.filterUnread;
    _isActivated = widget.isActivated;

    _defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;
    _filterUnread = widget.filterUnread;

    activeTab = [DefaultView.history, DefaultView.historyUnread].indexOf(_defaultView) >= 0 ? ETabs.history : ETabs.bookmarks;
    if (activeTab == ETabs.bookmarks) {
      _bookmarksController = PageController(initialPage: 1);
    } else {
      _bookmarksController = PageController(initialPage: 0);
    }

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page! % 1 == 0 && activeTab != ETabs.values[_bookmarksController.page!.toInt()]) {
        setState(() {
          activeTab = ETabs.values[_bookmarksController.page!.toInt()];
        });
      }
    });

    super.initState();
  }

  // isInverted
  // Sometimes the activeTab var is changed after the listener where we call updateLatestView() finishes.
  // Therefore, the var activeTab needs to be handled as inverted.
  void updateLatestView({bool isInverted: false}) {
    DefaultView latestView = activeTab == ETabs.history ? DefaultView.history : DefaultView.bookmarks;
    if (isInverted) {
      latestView = activeTab == ETabs.history ? DefaultView.bookmarks : DefaultView.history;
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
      setState(() => _filterUnread = widget.filterUnread);
      setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
    } else if (widget.isActivated && widget.isActivated != oldWidget.isActivated) {
      setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            trailing: GestureDetector(
                child: Icon(Icons.settings),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushNamed('/settings');
                }),
            leading: Consumer<NotificationsModel>(
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
                _bookmarksController.animateToPage(ETabs.values.indexOf(value as ETabs),
                    duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              children: {
                ETabs.history: Padding(
                  child: Text('Historie'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                ETabs.bookmarks: Padding(
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
                dataProvider: (lastId) async {
                  List<DiscussionListItem> withReplies = [];
                  var result = await ApiController().loadHistory();
                  var data = result.discussions
                      .map((discussion) => BookmarkedDiscussion.fromJson(discussion))
                      .where((discussion) => this._filterUnread ? discussion.unread > 0 : true)
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
                dataProvider: (lastId) async {
                  var categories = [];
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
                        setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
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
