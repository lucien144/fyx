import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class _HomePageState extends State<HomePage> {
  final PageController _bookmarksController = PageController(initialPage: 0);

  tabs activeTab;

  @override
  void initState() {
    activeTab = tabs.history;

    _bookmarksController.addListener(() {
      // If the CupertinoTabView is sliding and the animation is finished, change the active tab
      if (_bookmarksController.page % 1 == 0 && activeTab != tabs.values[_bookmarksController.page.toInt()]) {
        setState(() {
          activeTab = tabs.values[_bookmarksController.page.toInt()];
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _bookmarksController.dispose();
    super.dispose();
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
                    PullToRefreshList(dataProvider: (lastId) async {
                      var result = await ApiController().loadHistory();
                      var data = (result['discussions'] as List).map((discussion) => DiscussionListItem(Discussion.fromJson(discussion))).toList();
                      return DataProviderResult(data);
                    }),
                    PullToRefreshList(dataProvider: (lastId) async {
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
