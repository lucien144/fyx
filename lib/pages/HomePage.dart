import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/CircleAvatar.dart' as ca;
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/NavigationBarIcon.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Category.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/provider/SettingsModel.dart';
import 'package:fyx/pages/MailboxPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:provider/provider.dart';

enum tabs { history, bookmarks }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware, WidgetsBindingObserver {
  static const int PAGE_BOOKMARK = 0;
  static const int PAGE_MAIL = 1;

  final PageController _bookmarksController = PageController(initialPage: 0);

  tabs activeTab;
  int _pageIndex = PAGE_BOOKMARK;
  int _refreshData = 0;
  bool _filterUnread = false;

  @override
  void initState() {
    super.initState();
    activeTab = tabs.history;

    WidgetsBinding.instance.addObserver(this);

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page % 1 == 0 && activeTab != tabs.values[_bookmarksController.page.toInt()]) {
        setState(() {
          activeTab = tabs.values[_bookmarksController.page.toInt()];
        });
      }
    });
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
      this.refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FyxApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  // Called when the current route has been pushed.
  void didPopNext() {
    debugPrint("didPopNext $runtimeType");
    this.refreshData();
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

  void refreshData() {
    setState(() {
      _refreshData = DateTime.now().millisecondsSinceEpoch;
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
          CupertinoActionSheetAction(child: Text('⚠️ ${L.SETTINGS_BUGREPORT}'), onPressed: () => PlatformTheme.prefillGithubIssue(L.SETTINGS_BUGREPORT_TITLE)),
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
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          onTap: (index) {
            if (_pageIndex == index && index == PAGE_BOOKMARK) {
              setState(() => _filterUnread = !_filterUnread);
            }
            _pageIndex = index;
            this.refreshData();
          },
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(_filterUnread ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark, size: 38),
            ),
            BottomNavigationBarItem(
              icon: Consumer<NotificationsModel>(
                builder: (context, notifications, child) => Stack(
                  children: <Widget>[
                    Icon(
                      CupertinoIcons.mail,
                      size: 42,
                    ),
                    Visibility(
                      visible: notifications.newMails > 0,
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          constraints: BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            notifications.newMails.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case PAGE_BOOKMARK:
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
                      middle: CupertinoSegmentedControl(
                        groupValue: activeTab,
                        onValueChanged: (value) {
                          setState(() => _refreshData = 0);
                          _bookmarksController.animateToPage(tabs.values.indexOf(value), duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        children: {
                          tabs.history: Padding(
                            child: Text('Historie'),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          tabs.bookmarks: Padding(
                            child: Text('Sledované'),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        },
                      )),
                  child: PageView(
                    controller: _bookmarksController,
                    pageSnapping: true,
                    children: <Widget>[
                      PullToRefreshList(
                          rebuild: _refreshData,
                          dataProvider: (lastId) async {
                            var result = await ApiController().loadHistory();
                            var data = result.discussions
                                .map((discussion) => Discussion.fromJson(discussion))
                                .where((discussion) => this._filterUnread ? discussion.unread > 0 : true)
                                .map((discussion) => DiscussionListItem(discussion))
                                .toList();
                            return DataProviderResult(data);
                          }),
                      PullToRefreshList(
                          rebuild: _refreshData,
                          dataProvider: (lastId) async {
                            var categories = [];
                            var result = await ApiController().loadBookmarks();

                            result.categories.forEach((_category) {
                              var category = Category.fromJson(_category);
                              var discussion = result.discussions
                                  .map((discussion) => Discussion.fromJson(discussion))
                                  .where((discussion) => this._filterUnread ? discussion.unread > 0 : true)
                                  .map((discussion) => DiscussionListItem(discussion))
                                  .where((discussionListItem) => discussionListItem.category == category.idCat)
                                  .toList();
                              categories.add({'header': ListHeader(category), 'items': discussion});
                            });
                            return DataProviderResult(categories);
                          }),
                    ],
                  ),
                );
              });
            case PAGE_MAIL:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                        backgroundColor: Colors.white,
                        leading: Consumer<SettingsModel>(
                            builder: (context, settings, child) => CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Provider.of<SettingsModel>(context, listen: false).toggleUseHeroPosts(),
                                  child: NavigationBarIcon(settings.useHeroPosts ? CupertinoIcons.lab_flask_solid : CupertinoIcons.lab_flask),
                                )),
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
                      refreshData: _refreshData,
                    ));
              });
            default:
              throw Exception('Selected undefined tab');
          }
        },
      ),
    );
  }
}
