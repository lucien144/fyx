import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/CircleAvatar.dart' as ca;
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/MailboxPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart';

enum ETabs { history, bookmarks }
enum ERefreshData { bookmarks, mail, all }

class HomePageArguments {
  final pageIndex;

  HomePageArguments(this.pageIndex);
}

class HomePage extends StatefulWidget {
  static const int PAGE_BOOKMARK = 0;
  static const int PAGE_MAIL = 1;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware, WidgetsBindingObserver {
  PageController _bookmarksController;

  ETabs activeTab;
  int _pageIndex;
  Map<String, int> _refreshData = {'bookmarks': 0, 'mail': 0};
  bool _filterUnread = false;
  DefaultView _defaultView;
  List<int> _toggledCategories = [];
  HomePageArguments _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _defaultView = MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;
    _filterUnread = [DefaultView.bookmarksUnread, DefaultView.historyUnread].indexOf(_defaultView) >= 0;

    activeTab = [DefaultView.history, DefaultView.historyUnread].indexOf(_defaultView) >= 0 ? ETabs.history : ETabs.bookmarks;
    if (activeTab == ETabs.bookmarks) {
      _bookmarksController = PageController(initialPage: 1);
    } else {
      _bookmarksController = PageController(initialPage: 0);
    }

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page % 1 == 0 && activeTab != ETabs.values[_bookmarksController.page.toInt()]) {
        setState(() {
          activeTab = ETabs.values[_bookmarksController.page.toInt()];
        });
      }
    });

    // Request for push notifications
    MainRepository().notifications.request();

    AnalyticsProvider().setUser(MainRepository().credentials.nickname);
    AnalyticsProvider().setUserProperty('photoWidth', MainRepository().settings.photoWidth.toString());
    AnalyticsProvider().setUserProperty('photoQuality', MainRepository().settings.photoQuality.toString());
    AnalyticsProvider().setUserProperty('autocorrect', MainRepository().settings.useAutocorrect.toString());
    AnalyticsProvider().setUserProperty('compactMode', MainRepository().settings.useCompactMode.toString());
    AnalyticsProvider().setUserProperty('defaultView', MainRepository().settings.defaultView.toString());
    AnalyticsProvider().setUserProperty('blockedMails', MainRepository().settings.blockedMails.length.toString());
    AnalyticsProvider().setUserProperty('blockedPosts', MainRepository().settings.blockedPosts.length.toString());
    AnalyticsProvider().setUserProperty('blockedUsers', MainRepository().settings.blockedUsers.length.toString());
    AnalyticsProvider().setScreen('Home', 'HomePage');
  }

  @override
  void dispose() {
    _bookmarksController.dispose();
    FyxApp.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If we omit the Route check, there's very rare issue during authorization
    // See: https://github.com/lucien144/fyx/issues/57
    if (state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent) {
      this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? ERefreshData.mail : ERefreshData.bookmarks);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FyxApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  // Called when the current route has been pushed.
  void didPopNext() {
    this.refreshData(ERefreshData.bookmarks);
  }

  void didPush() {
    // Called when the current route has been pushed.
  }

  void didPop() {
    // Called when the current route has been popped off.
  }

  void didPushNext() {
    // Called when a new route has been pushed, and the current route is no longer visible.
  }

  void refreshData(ERefreshData type) {
    setState(() {
      switch (type) {
        case ERefreshData.bookmarks:
          _refreshData['bookmarks'] = DateTime.now().millisecondsSinceEpoch;
          break;
        case ERefreshData.mail:
          _refreshData['mail'] = DateTime.now().millisecondsSinceEpoch;
          break;
        default:
          _refreshData['bookmarks'] = DateTime.now().millisecondsSinceEpoch;
          _refreshData['mail'] = DateTime.now().millisecondsSinceEpoch;
          break;
      }
    });
  }

  Widget actionSheet(BuildContext context) {
    return CupertinoActionSheet(
        title: Text('Přihlášen jako: ${MainRepository().credentials.nickname}'),
        actions: <Widget>[
          CupertinoActionSheetAction(
              child: Text(L.SETTINGS),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pushNamed('/settings');
              }),
          CupertinoActionSheetAction(
              child: Text('⚠️ ${L.SETTINGS_BUGREPORT}'),
              onPressed: () {
                T.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials.nickname);
                AnalyticsProvider().logEvent('reportBug');
              }),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text(L.GENERAL_CANCEL),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (ApiController().buildContext == null || ApiController().buildContext.hashCode != context.hashCode) {
      ApiController().buildContext = context;
    }

    if (_pageIndex == null) {
      if (_arguments == null) {
        _arguments = ModalRoute.of(context).settings.arguments as HomePageArguments;
        _pageIndex = _arguments?.pageIndex ?? HomePage.PAGE_BOOKMARK;
      } else {
        _pageIndex = _arguments.pageIndex;
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _pageIndex,
          onTap: (index) {
            if (_pageIndex == index && index == HomePage.PAGE_BOOKMARK) {
              setState(() {
                _filterUnread = !_filterUnread;
                // Reset the category toggle
                _toggledCategories = [];
                this.updateLatestView();
              });
            }
            setState(() => _pageIndex = index);
            this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? ERefreshData.mail : ERefreshData.bookmarks);
          },
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(_filterUnread ? Icons.bookmarks : Icons.bookmarks_outlined, size: 34),
            ),
            BottomNavigationBarItem(
              icon: Consumer<NotificationsModel>(
                builder: (context, notifications, child) => NotificationBadge(
                    widget: Icon(
                      Icons.email_outlined,
                      size: 42,
                    ),
                    counter: notifications.newMails,
                    isVisible: notifications.newMails > 0),
              ),
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case HomePage.PAGE_BOOKMARK:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                      backgroundColor: Colors.white,
                      leading: Consumer<NotificationsModel>(
                          builder: (context, notifications, child) => NotificationBadge(
                              widget: GestureDetector(
                                  child: Icon(
                                    Icons.notifications_none,
                                    size: 30,
                                  ),
                                  onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/notices')),
                              isVisible: notifications.newNotices > 0,
                              counter: notifications.newNotices)),
                      trailing: GestureDetector(
                        child: ca.CircleAvatar(
                          MainRepository().credentials.avatar,
                          size: 30,
                          isHighlighted: true,
                        ),
                        onTap: () {
                          showCupertinoModalPopup(context: context, builder: (BuildContext context) => actionSheet(context));
                        },
                      ),
                      middle: CupertinoSegmentedControl(
                        groupValue: activeTab,
                        onValueChanged: (value) {
                          _bookmarksController.animateToPage(ETabs.values.indexOf(value), duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                          rebuild: _refreshData['bookmarks'],
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
                          rebuild: _refreshData['bookmarks'],
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
                                  this.refreshData(ERefreshData.bookmarks);
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
            case HomePage.PAGE_MAIL:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                        backgroundColor: Colors.white,
                        trailing: GestureDetector(
                          child: ca.CircleAvatar(
                            MainRepository().credentials.avatar,
                            size: 30,
                          ),
                          onTap: () {
                            showCupertinoModalPopup(context: context, builder: (BuildContext context) => actionSheet(context));
                          },
                        ),
                        middle: Text('Pošta')),
                    child: MailboxPage(
                      refreshData: _refreshData['mail'],
                    ));
              });
            default:
              throw Exception('Selected undefined tab');
          }
        },
      ),
    );
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
}
