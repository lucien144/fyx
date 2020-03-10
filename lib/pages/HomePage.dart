import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Category.dart';
import 'package:fyx/model/Discussion.dart';

enum tabs { history, bookmarks }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware, WidgetsBindingObserver {
  final PageController _bookmarksController = PageController(initialPage: 0);

  tabs activeTab;
  int _refreshData = 0;

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
    if (state == AppLifecycleState.resumed) {
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
    debugPrint("didPopNext ${runtimeType}");
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

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark),
            title: Text('Sledované'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mail),
            title: Text('Posta'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                    backgroundColor: Colors.white,
                    trailing: CupertinoButton(
                      child: Icon(CupertinoIcons.padlock_solid),
                      onPressed: () {
                        ApiController().logout();
                        Navigator.of(context, rootNavigator: true).pushNamed('/');
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
                          var data = (result['discussions'] as List).map((discussion) => DiscussionListItem(Discussion.fromJson(discussion))).toList();
                          return DataProviderResult(data);
                        }),
                    PullToRefreshList(
                        rebuild: _refreshData,
                        dataProvider: (lastId) async {
                          var categories = [];
                          var result = await ApiController().loadBookmarks();
                          if ((result as Map).containsKey('categories')) {
                            (result['categories'] as List).forEach((_category) {
                              var category = Category.fromJson(_category);
                              var discussion = (result['discussions'] as List)
                                  .map((discussion) => DiscussionListItem(Discussion.fromJson(discussion)))
                                  .where((discussion) => discussion.category == category.idCat)
                                  .toList();
                              categories.add({'header': ListHeader(category), 'items': discussion});
                            });
                            return DataProviderResult(categories);
                          }
                          return DataProviderResult([]);
                        }),
                  ],
                ),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Container(),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Container(),
              );
            });
          default:
            throw Exception('Selected undefined tab');
        }
      },
    );
  }
}
