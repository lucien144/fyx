import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse absolute header deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('https://nyx.cz/discussion/$id/content/header');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], 'header');
  });

  test('Should parse absolute home deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('https://nyx.cz/discussion/$id/content/home');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], 'home');
  });

  test('Should parse relative header deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('/discussion/$id/content/header');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], 'header');
  });

  test('Should parse relative home deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('/discussion/$id/content/home');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], 'home');
  });

  test('Should NOT parse plain discussion deeplinks', () {
    var result = Helpers.parseDiscussionContentUri('/discussion/307');
    expect(result.isEmpty, true);
  });

  test('Should NOT parse discussion post deeplinks', () {
    var result = Helpers.parseDiscussionContentUri('/discussion/307/id/12345');
    expect(result.isEmpty, true);
  });
}
