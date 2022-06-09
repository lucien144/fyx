import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/Avatar.dart' as ca;
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/MailboxPage.dart';
import 'package:fyx/pages/tab_bar/BookmarksTab.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
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
  late PageController _bookmarksController;

  ETabs activeTab = ETabs.history;
  int _pageIndex = 0;
  Map<String, int> _refreshData = {'bookmarks': 0, 'mail': 0};
  bool _filterUnread = false;
  DefaultView _defaultView = DefaultView.history;
  List<int> _toggledCategories = [];
  HomePageArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    _defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;
    _filterUnread = [DefaultView.bookmarksUnread, DefaultView.historyUnread].indexOf(_defaultView) >= 0;

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

    // Request for push notifications
    MainRepository().notifications.request();

    AnalyticsProvider().setUser(MainRepository().credentials!.nickname);
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
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If we omit the Route check, there's very rare issue during authorization
    // See: https://github.com/lucien144/fyx/issues/57
    if (state == AppLifecycleState.resumed && ModalRoute.of(context)!.isCurrent) {
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
        title: Text('Přihlášen jako: ${MainRepository().credentials!.nickname}'),
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
                T.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials!.nickname);
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
    SkinColors colors = Skin.of(context).theme.colors;

    if (ApiController().buildContext == null || ApiController().buildContext.hashCode != context.hashCode) {
      ApiController().buildContext = context;
    }

    final Object? _objArguments = ModalRoute.of(context)?.settings.arguments;
    if (_objArguments != null) {
      _arguments = _objArguments as HomePageArguments;
      _pageIndex = _arguments?.pageIndex;
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
              });
            }
            setState(() => _pageIndex = index);
            this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? ERefreshData.mail : ERefreshData.bookmarks);
          },
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
              return BookmarksTab(filterUnread: _filterUnread, isActivated: _pageIndex == index);
            case HomePage.PAGE_MAIL:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                        trailing: GestureDetector(
                          child: ca.Avatar(
                            MainRepository().credentials!.avatar,
                            size: 26,
                          ),
                          onTap: () {
                            showCupertinoModalPopup(context: context, builder: (BuildContext context) => actionSheet(context));
                          },
                        ),
                        middle: Text(
                          'Pošta',
                          style: TextStyle(color: colors.text),
                        )),
                    child: MailboxPage(
                      refreshData: _refreshData['mail'] ?? 0,
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
