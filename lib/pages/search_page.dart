import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/discussion_page_scaffold.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/components/search/search_help_notfound.dart';
import 'package:fyx/components/search/search_help_posts.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/DiscussionPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _refreshData = 0;
  String? _searchTerm;

  refreshData() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    AnalyticsProvider().setScreen('Search', 'Search');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyWidget = SearchPostsHelp();

    if (this._searchTerm != null) {
      emptyWidget = SearchHelpNotFound();
    }

    return DiscussionPageScaffold(
        title: 'Hledání',
        child: PullToRefreshList(
            emptyWidget: emptyWidget,
            searchEnabled: true,
            searchFocus: true,
            searchLabel: 'Hledej v příspěvcích...',
            searchTerm: this._searchTerm,
            onSearch: (term) {
              setState(() => this._searchTerm = term);
              this.refreshData();
            },
            onSearchClear: () {
              setState(() => this._searchTerm = null);
              this.refreshData();
            },
            rebuild: _refreshData,
            isInfinite: true,
            dataProvider: (lastId) async {
              var response = await ApiController().search(this._searchTerm ?? '', lastId: lastId);
              var posts = response.data['posts'] as List;

              List data = posts
                  .map((post) => Post.fromJson(post, post['discussion_id'], isCompact: MainRepository().settings.useCompactMode))
                  .where((post) => !MainRepository().settings.isPostBlocked(post.id))
                  .where((post) => !MainRepository().settings.isUserBlocked(post.nick))
                  .map((post) => Stack(children: [
                        PostListItem(
                          post,
                          onUpdate: this.refreshData,
                          disabled: true,
                        ),
                        Positioned.fill(
                            child: GestureDetector(
                                onTap: () {
                                  var arguments = DiscussionPageArguments(post.idKlub, postId: post.id + 1);
                                  Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container()))
                      ]))
                  .toList();

              int? id = posts.length > 0 ? posts.last['id'] : null;
              return DataProviderResult(data, lastId: id);
            }));
  }
}
