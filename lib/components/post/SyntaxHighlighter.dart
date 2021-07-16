import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:html_unescape/html_unescape.dart';

class SyntaxHighlighter extends StatelessWidget {
  final String source;

  // TODO: Get rid of static.
  static String languageContext = '';

  const SyntaxHighlighter(this.source, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final source = HtmlUnescape().convert(this.source);
    final lang = this._getLanguage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HighlightView(source,
            language: lang,
            theme: draculaTheme,
            padding: EdgeInsets.all(12),
            tabSize: 2,
            textStyle: TextStyle(fontFamily: 'JetBrainsMono')),
        Container(
          alignment: Alignment.centerRight,
          child: Text(
            'Syntax: $lang',
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: .8),
          ),
        )
      ],
    );
  }

  // The HighlightView does not support language auto-detection.
  // Easiest and fastest is to try to quess the language from discussion's name.
  _getLanguage() {
    if (SyntaxHighlighter.languageContext == '') {
      return 'plaintext';
    }

    Map<String, String> langs = {
      'php': r"php|wordpress",
      'javascript':
          r"javascript|typescript|angular|\.js|ajax|angular|react|vue",
      'java': r"java|android",
      'sql': r"sql",
      'css': r"css|scss|sass|less",
      'erlang': r"erlang",
      'cpp': r"c\+\+",
      'python': r"django|python",
      'dart': r"dart|flutter",
      'haskell': r"haskell",
      'objectivec': r"game|objc|cocoa|objektive|applescript",
      'htmlbars': r"html",
      'xml': r"html|xml",
      'kotlin': r"kotlin",
      'perl': r"perl",
      'delphi': r"delphi|pascal",
      'cs': r"csharp|c#|\.net|asp",
      'lisp': r"lisp",
      'ruby': r"ruby",
      'scala': r"scala|clojure",
      'bash': r"bash|shell|unix|linux",
      'swift': r"swift",
      'go': r"go",
      'actionscript': r"flash|actionscript|as3",
    };

    String foundLang = 'plaintext';
    for (String key in langs.keys) {
      final RegExp regexp = new RegExp(langs[key]!, caseSensitive: false);
      if (regexp.hasMatch(SyntaxHighlighter.languageContext)) {
        foundLang = key;
        break;
      }
    }
    return foundLang;
  }
}
