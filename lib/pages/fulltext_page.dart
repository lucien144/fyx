import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/components/discussion_page_scaffold.dart';
import 'package:fyx/components/discussion_search_list_item.dart';
import 'package:fyx/components/list_header.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/components/search/search_help_notfound.dart';
import 'package:fyx/components/search/search_help_posts.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/theme/L.dart';

class FulltextPageArguments {
  final String? searchTerm;
  final bool focus;

  FulltextPageArguments({this.searchTerm, this.focus = true});
}

class FulltextPage extends StatefulWidget {
  const FulltextPage({Key? key}) : super(key: key);

  @override
  State<FulltextPage> createState() => _FulltextPageState();
}

class _FulltextPageState extends State<FulltextPage> {
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
    FulltextPageArguments? pageArguments = ModalRoute.of(context)?.settings.arguments as FulltextPageArguments?;
    if (pageArguments?.searchTerm != null && _searchTerm == null) {
      setState(() => _searchTerm = pageArguments!.searchTerm);
    }

    Widget emptyWidget = SearchPostsHelp();
    if (this._searchTerm != null) {
      emptyWidget = SearchHelpNotFound();
    }

    return DiscussionPageScaffold(
        title: 'Hledat vše',
        child: PullToRefreshList<StateProvider<String?>>(
            rebuild: _refreshData,
            emptyWidget: emptyWidget,
            searchEnabled: true,
            searchFocus: true,
            searchLabel: 'Hledej diskuze, události a inzeráty...',
            searchTerm: _searchTerm,
            onSearch: (term) {
              setState(() => this._searchTerm = term);
              this.refreshData();
            },
            onSearchClear: () {
              setState(() => this._searchTerm = null);
              this.refreshData();
            },
            dataProvider: (lastId) async {
              var categories = [];

              try {
                if (this._searchTerm?.isNotEmpty ?? false) {
                  final result = await ApiController().searchDiscussions(this._searchTerm!);
                  result.discussion.forEach((type, list) {
                    categories.add({
                      'header': ListHeader(L.search[type] ?? ''),
                      'items': list.map((model) => DiscussionSearchListItem(discussionId: model.id, child: Text(model.discussionName))).toList()
                    });
                  });
                  return DataProviderResult(categories);
                }
              } catch (error) {}
              return DataProviderResult([]);
            }));
  }
}
