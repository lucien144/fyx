import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/NotificationBadge.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/RefreshDataEnum.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/tab_bar/BookmarksTab.dart';
import 'package:fyx/pages/tab_bar/MailboxTab.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart';

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
  int _pageIndex = 0;
  Map<RefreshDataEnum, int> _refreshData = {RefreshDataEnum.bookmarks: 0, RefreshDataEnum.mail: 0};
  bool _filterUnread = false;
  HomePageArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    final defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;
    _filterUnread = [DefaultView.bookmarksUnread, DefaultView.historyUnread].indexOf(defaultView) >= 0;

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
    FyxApp.routeObserver.unsubscribe(this);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If we omit the Route check, there's very rare issue during authorization
    // See: https://github.com/lucien144/fyx/issues/57
    if (state == AppLifecycleState.resumed && ModalRoute.of(context)!.isCurrent) {
      this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? RefreshDataEnum.mail : RefreshDataEnum.bookmarks);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FyxApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  // Called when the current route has been pushed.
  void didPopNext() {
    this.refreshData(RefreshDataEnum.bookmarks);
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

  void refreshData(RefreshDataEnum type) {
    setState(() {
      switch (type) {
        case RefreshDataEnum.bookmarks:
          _refreshData[RefreshDataEnum.bookmarks] = DateTime.now().millisecondsSinceEpoch;
          break;
        case RefreshDataEnum.mail:
          _refreshData[RefreshDataEnum.mail] = DateTime.now().millisecondsSinceEpoch;
          break;
        default:
          _refreshData[RefreshDataEnum.bookmarks] = DateTime.now().millisecondsSinceEpoch;
          _refreshData[RefreshDataEnum.mail] = DateTime.now().millisecondsSinceEpoch;
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
              setState(() => _filterUnread = !_filterUnread);
            }
            setState(() => _pageIndex = index);
            this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? RefreshDataEnum.mail : RefreshDataEnum.bookmarks);
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
              return BookmarksTab(filterUnread: _filterUnread, refreshTimestamp: _refreshData[RefreshDataEnum.bookmarks] ?? 0);
            case HomePage.PAGE_MAIL:
              return MailboxTab(refreshTimestamp: _refreshData[RefreshDataEnum.mail] ?? 0);
            default:
              throw Exception('Selected undefined tab');
          }
        },
      ),
    );
  }
}
