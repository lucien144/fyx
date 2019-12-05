import 'dart:convert';

import 'package:dio/dio.dart';
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

class HomePage extends StatelessWidget {
  final PageController _bookmarksController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
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
                    PullToRefreshList<DiscussionListItem, ListHeader>(
                      itemBuilder: (Response<dynamic> response) =>
                          (jsonDecode(response.data)['data']['discussions'] as List).map((discussion) => DiscussionListItem(Discussion.fromJson(discussion))).toList(),
                      headerBuilder: (Response<dynamic> response) {
                        if ((jsonDecode(response.data)['data'] as Map).containsKey('categories')) {
                          return (jsonDecode(response.data)['data']['categories'] as List).map((category) => ListHeader(Category.fromJson(category))).toList();
                        }
                        return [];
                      },
                      loadData: () => ApiController.loadBookmarks(),
                    ),
                    PullToRefreshList<DiscussionListItem, ListHeader>(
                      itemBuilder: (Response<dynamic> response) {
                        return (jsonDecode(response.data)['data']['discussions'] as List).map((discussion) => DiscussionListItem(Discussion.fromJson(discussion))).toList();
                      },
                      loadData: () => ApiController.loadHistory(),
                    ),
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
