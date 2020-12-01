import 'package:html/parser.dart';

class Helpers {
  static stripHtmlTags(String html) {
    final document = parse(html);
    return parse(document.body.text).documentElement.text.trim();
  }
}