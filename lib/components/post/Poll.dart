import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/theme/T.dart';
import 'package:html/dom.dart' as dom;

class Poll extends StatefulWidget {
  String html;

  Poll(this.html);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<Poll> {
  bool _showColumnStats = false;
  bool _showRowStats = false;
  TapGestureRecognizer votesRecognizer;
  TapGestureRecognizer columnsRecognizer;
  TapGestureRecognizer rowsRecognizer;

  @override
  void initState() {
    votesRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = false;
          _showColumnStats = false;
        });
      };

    columnsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = false;
          _showColumnStats = !_showColumnStats;
        });
      };

    rowsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = !_showRowStats;
          _showColumnStats = false;
        });
      };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Html(
        data: widget.html,
        style: {
          'tbody tr': Style(
              backgroundColor: Color(0xffa9ccd3),
              border: Border(
                  bottom: BorderSide(width: 5, color: Color(0xffcde5e9)))),
          'th': Style(
              padding: EdgeInsets.only(bottom: 5),
              fontWeight: FontWeight.bold,
              fontSize: FontSize.percent(90),
              color: _showColumnStats ? T.COLOR_ACCENT : null),
          'tr > td': Style(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.percent(90),
              color: _showRowStats ? T.COLOR_ACCENT : null),
          'tbody td': Style(padding: EdgeInsets.fromLTRB(5, 5, 5, 10))
        },
        customRender: {
          'div': (
            RenderContext renderContext,
            Widget parsedChild,
            Map<String, String> attributes,
            dom.Element element,
          ) {
            // Main box element styling
            if (element.classes.contains('w-dyn')) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    parsedChild,
                    RichText(
                        text: TextSpan(
                            text: 'Zobrazit %: ',
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 0.9),
                            children: [
                          TextSpan(
                              text: 'hlasy',
                              recognizer: votesRecognizer,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight:
                                      !_showColumnStats && !_showRowStats
                                          ? FontWeight.bold
                                          : null)),
                          TextSpan(text: ', '),
                          TextSpan(
                              text: 'sloupce',
                              recognizer: columnsRecognizer,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: _showColumnStats && !_showRowStats
                                      ? FontWeight.bold
                                      : null)),
                          TextSpan(text: ', '),
                          TextSpan(
                              text: 'řádky',
                              recognizer: rowsRecognizer,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: !_showColumnStats && _showRowStats
                                      ? FontWeight.bold
                                      : null))
                        ]))
                  ],
                ),
                color: Color(0xffcde5e9),
                padding: EdgeInsets.all(15),
              );
            }

            // Poll bars
            if (element.classes.contains('pgbar') &&
                element.attributes.containsKey('style')) {
              RegExp regExp = new RegExp(
                r"width: ([0-9.]*)%",
                caseSensitive: false,
                multiLine: false,
              );
              String percentage =
                  regExp.firstMatch(element.attributes['style']).group(1);
              return Container(
                  width: double.parse(percentage) + 1,
                  // +1 is here to show something if votes = 0
                  height: 10,
                  color: T.COLOR_PRIMARY);
            }
            return parsedChild;
          },
          'span': (
            RenderContext renderContext,
            Widget parsedChild,
            Map<String, String> attributes,
            dom.Element element,
          ) {
            if (element.classes.contains('votes')) {
              return RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: element.innerHtml,
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: .8))
              ]));
            }

            if (element.classes.contains('opt-percent')) {
              if (_showColumnStats || _showRowStats) {
                return null;
              }

              return RichText(
                  text: TextSpan(
                      children: [
                    TextSpan(text: ' / '),
                    TextSpan(text: element.innerHtml)
                  ],
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: .8)));
            }

            if (element.classes.contains('row-percent')) {
              if (!_showRowStats) {
                return null;
              }

              return RichText(
                  text: TextSpan(
                      children: [
                    TextSpan(text: ' / '),
                    TextSpan(text: element.innerHtml)
                  ],
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: .8, color: T.COLOR_ACCENT)));
            }

            if (element.classes.contains('col-percent')) {
              if (!_showColumnStats) {
                return null;
              }

              return RichText(
                  text: TextSpan(
                      children: [
                    TextSpan(text: ' / '),
                    TextSpan(text: element.innerHtml)
                  ],
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: .8, color: T.COLOR_ACCENT)));
            }

            return parsedChild;
          }
        },
        onLinkTap: (String link) {
          PlatformTheme.openLink(link);
        });
  }
}
