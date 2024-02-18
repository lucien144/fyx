import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/WhatsNew.dart';
import 'package:fyx/components/bottom_tab_bar.dart';
import 'package:fyx/components/notification_badge.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/RefreshDataEnum.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/tab_bar/bookmarks_tab.dart';
import 'package:fyx/pages/tab_bar/MailboxTab.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  bool _showSubmenu = false;
  HomePageArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final defaultView =
        MainRepository().settings.defaultView == DefaultView.latest ? MainRepository().settings.latestView : MainRepository().settings.defaultView;
    _filterUnread = [DefaultView.bookmarksUnread, DefaultView.historyUnread].indexOf(defaultView) >= 0;

    () async {
      await Future.delayed(Duration.zero);
      final Object? _objArguments = ModalRoute.of(context)?.settings.arguments;
      if (_objArguments != null) {
        _arguments = _objArguments as HomePageArguments;
        setState(() => _pageIndex = _arguments?.pageIndex);
      }
    }();

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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _showSubmenu = false);

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
    SkinColors colors = Skin.of(context).theme.colors;
    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';
    if (SettingsProvider().whatsNew != version) {
      SettingsProvider().whatsNew = version;
      Future.delayed(Duration(seconds: 2), () {
        showCupertinoModalBottomSheet(
          context: context,
          expand: false,
          builder: (context) => WhatsNew(),
          backgroundColor: colors.barBackground,
          barrierColor: colors.dark.withOpacity(0.5),
        );
      });
    }
  }

  void didPop() {
    // Called when the current route has been popped off.
  }

// Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    setState(() => _showSubmenu = false);
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

  @override
  Widget build(BuildContext context) {
    if (ApiController().buildContext == null || ApiController().buildContext.hashCode != context.hashCode) {
      ApiController().buildContext = context;
    }

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = Skin.of(context).theme.colors;
    final tabs = [
      BookmarksTab(filterUnread: _filterUnread, refreshTimestamp: _refreshData[RefreshDataEnum.bookmarks] ?? 0),
      MailboxTab(refreshTimestamp: _refreshData[RefreshDataEnum.mail] ?? 0),
    ];

    return Stack(children: [
      Positioned.fill(
        // Do not prevent the scroll down if the submenu is up. Only hide the submenu and keep scrolling...
        child: GestureDetector(
          child: tabs[_pageIndex],
          onVerticalDragDown: (_) => _showSubmenu ? setState(() => _showSubmenu = false) : null,
        ),
        bottom: 50 + bottomPadding,
      ),
      Positioned.fill(
        // Prevent the tap if submenu is up!
        child: GestureDetector(
          behavior: _showSubmenu ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
          onTap: () => _showSubmenu ? setState(() => _showSubmenu = false) : null,
          child: BottomTabBar(
            activeSubmenu: _showSubmenu,
            onTap: (index) {
              if (index == tabs.length) {
                setState(() => _showSubmenu = !_showSubmenu);
                return;
              }

              if (_pageIndex == index && index == HomePage.PAGE_BOOKMARK) {
                setState(() => _filterUnread = !_filterUnread);
              }
              setState(() {
                _pageIndex = index;
                _showSubmenu = false;
              });
              this.refreshData(_pageIndex == HomePage.PAGE_MAIL ? RefreshDataEnum.mail : RefreshDataEnum.bookmarks);
            },
            items: [
              Icon(_filterUnread ? Icons.bookmarks : Icons.bookmarks_outlined, size: 34, color: _pageIndex == 0 ? colors.primary : colors.grey),
              Consumer<NotificationsModel>(
                builder: (context, notifications, child) => NotificationBadge(
                    widget: Icon(Icons.email_outlined, size: 42, color: _pageIndex == 1 ? colors.primary : colors.grey),
                    counter: notifications.newMails,
                    isVisible: notifications.newMails > 0),
              ),
              Center(
                  child: Icon(
                MdiIcons.menu,
                size: 34,
              ))
            ],
          ),
        ),
      )
    ]);
  }
}
