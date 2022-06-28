import 'dart:io';

import 'package:html/parser.dart';

void main(List<String> arguments) async {
  var dir = Directory('../../lib/');
  var index = File('template.html');
  var document = parse(index.readAsStringSync());
  var icons = document.querySelector('#icons');
  icons?.innerHtml = '';

  await dir.list(recursive: true).forEach((file) {
    if (file.statSync().type == FileSystemEntityType.file) {
      var content = File(file.path).readAsStringSync();
      var rx = RegExp(
        r'Icons\.([a-z0-9_]+)',
        caseSensitive: true,
        multiLine: true,
      );
      var matches = rx.allMatches(content);
      if (matches.isNotEmpty) {
        icons?.append(parseFragment('<h3 class="mt-5">${file.path}</h3>'));
        icons?.append(parseFragment(matches.map((match) {
          var iconId = match.group(1);
          iconId = iconId?.replaceAll(RegExp(r'(_outlined|_rounded|_thick)'), '');
          return '<span class="d-flex mb-2">'
              '<span class="material-symbols-outlined me-3">$iconId</span>$iconId</span>';
        }).join('')));
      }
    }
  });

  File('dist/index.html').writeAsStringSync(document.outerHtml);
}
