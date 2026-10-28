import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the table-related entries of the `style` map in
/// lib/components/post/post_html.dart. Kept separate (rather than pumping
/// the real PostHtml widget) to avoid standing up Skin/MainRepository/
/// fyx.Content just for this -- see lib/components/post/post_html.dart for
/// the production style map and why width: Width.auto() is required here.
final _tableStyle = {
  'table': Style(margin: Margins.symmetric(vertical: 8)),
  'th': Style(width: Width.auto(), padding: HtmlPaddings.all(6), fontWeight: FontWeight.bold),
  'td': Style(width: Width.auto(), padding: HtmlPaddings.all(6)),
};

Future<void> _pumpTable(WidgetTester tester, String data) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Html(data: data, style: _tableStyle, extensions: [TableHtmlExtension()]),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders table cell text (flutter_html core has no built-in <table> support)', (tester) async {
    await _pumpTable(tester, '<table><tr><td>KAOZZ</td><td>107</td></tr></table>');

    expect(find.text('KAOZZ'), findsOneWidget);
    expect(find.text('107'), findsOneWidget);
  });

  testWidgets('renders th text despite a server-authored "width: 1px" shrink-to-content hack', (tester) async {
    // Real markup from Nyx's API: narrow <th> columns get an inline "width: 1px",
    // which browsers special-case for table auto-layout but flutter_html's
    // CssBoxWidget takes literally, collapsing the cell to zero width.
    await _pumpTable(
      tester,
      '<table>'
      '<thead><tr>'
      '<th style="width: 1px">Pořadí</th>'
      '<th>ID</th>'
      '<th style="width: 1px">Body</th>'
      '</tr></thead>'
      '<tbody><tr><td>1.</td><td>KAOZZ</td><td>107</td></tr></tbody>'
      '</table>',
    );

    expect(find.text('Pořadí'), findsOneWidget);
    expect(find.text('ID'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(tester.getSize(find.text('Pořadí')).width, greaterThan(0));
    expect(tester.getSize(find.text('Body')).width, greaterThan(0));
  });

  testWidgets('renders table content even when a cell wraps text in <p>', (tester) async {
    // Upstream issue #1351 reports a <p> inside a <td> can make the whole Html
    // widget disappear on some flutter_html_table versions. Not reproduced on
    // the version this project pins, but guarded here so a future bump of
    // flutter_html_table can't silently regress it.
    await _pumpTable(tester, '<table><tr><td><p>cell one</p></td><td>cell two</td></tr></table>');

    expect(find.textContaining('cell one'), findsOneWidget);
    expect(find.textContaining('cell two'), findsOneWidget);
  });
}
