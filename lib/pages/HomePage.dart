import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Category.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bookmarksController = PageController(initialPage: 0);

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
                        SharedPreferences.getInstance().then((prefs) => prefs.clear());
                        Navigator.of(context, rootNavigator: true).pushNamed('/');
                      },
                    ),
                    middle: CupertinoSegmentedControl(
                      onValueChanged: (value) => _bookmarksController.animateToPage(int.parse(value), duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                      children: {
                        '0': Padding(
                          child: Text('Historie'),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        '1': Padding(
                          child: Text('Sledovane'),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      },
                    )),
                child: PageView(
                  controller: _bookmarksController,
                  pageSnapping: true,
                  children: <Widget>[
                    PullToRefreshList(dataProvider: () async {
                      var data = await ApiController().loadHistory();
                      return (data['discussions'] as List).map((discussion) => DiscussionListItem(Discussion.fromJson(discussion))).toList();
                    }),
                    PullToRefreshList(dataProvider: () async {
                      var categories = [];
                      var data = await ApiController().loadBookmarks();
                      if ((data as Map).containsKey('categories')) {
                        (data['categories'] as List).forEach((_category) {
                          var category = Category.fromJson(_category);
                          var discussion = (data['discussions'] as List)
                              .map((discussion) => DiscussionListItem(Discussion.fromJson(discussion)))
                              .where((discussion) => discussion.category == category.idCat)
                              .toList();
                          categories.add({'header': ListHeader(category), 'items': discussion});
                        });
                        return categories;
                      }
                      return [];
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
