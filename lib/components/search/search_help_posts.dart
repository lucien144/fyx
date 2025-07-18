import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/list_header.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/search_page.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchPostsHelp extends StatelessWidget {
  const SearchPostsHelp({Key? key, this.hasSavedSearch = false}) : super(key: key);

  final bool hasSavedSearch;

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (SettingsProvider().savedSearch.isNotEmpty && this.hasSavedSearch) ListHeader('️Uložená hledání'),
            if (SettingsProvider().savedSearch.isNotEmpty && this.hasSavedSearch) ...SettingsProvider().savedSearch.map((term) => _widgetSavedSearchItem(context, term)).toList(),
            if (SettingsProvider().savedSearch.isNotEmpty && this.hasSavedSearch) SizedBox(height: 10),
            _widgetHowTo(colors),
          ],
        ),
      ),
    );
  }

  _widgetHowTo(colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: colors.primary.withOpacity(0.3)),
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(MdiIcons.informationOutline, size: 16),
                SizedBox(width: 8),
                Text(
                  'Příklady hledání:',
                  style: TextStyle(color: colors.primary, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: 'foo bar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – začínající na '),
                  TextSpan(
                    text: 'foo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' a '),
                  TextSpan(
                    text: 'bar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: '=foo =bar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – hledá přesnou shodu'),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: 'foo -bar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – odfiltruje výskyty '),
                  TextSpan(
                    text: 'bar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: 'hledaná fráze @uživatel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – hledá v příspěvcích '),
                  TextSpan(
                    text: 'uživatele',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: '"hledaná fráze"',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – hledá frázi'),
                ],
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              style: TextStyle(fontSize: 12),
              TextSpan(
                children: [
                  TextSpan(text: '• '),
                  TextSpan(
                    text: '@uživatel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' – hledá uživatele'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _widgetSavedSearchItem(context, String term) {
    final SkinColors colors = Skin.of(context).theme.colors;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.grey.withOpacity(.12)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(term),
                ),
                onTap: () {
                  final arguments = SearchPageArguments(searchTerm: term, focus: false);
                  Navigator.of(context, rootNavigator: true).pushNamed('/search', arguments: arguments);
                  AnalyticsProvider().logEvent('filter_saved_search');
                }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: GestureDetector(
              onTap: () => SettingsProvider().toggleSavedSearch(term),
              child: GestureDetector(
                child: ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['savedSearch']),
                  builder: (BuildContext context, value, Widget? child) {
                  return Icon(
                    SettingsProvider().isSearchTermSaved(term) ? MdiIcons.heart : MdiIcons.heartOutline,
                  );}
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
