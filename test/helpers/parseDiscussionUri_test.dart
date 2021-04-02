import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse OLD absolute internal deeplinks', () {
    int id = 1234;
    var result = Helpers.parseDiscussionUri('https://www.nyx.cz/index.php?l=topic;id=$id');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.postId], null);
  });

  test('Should parse OLD internal deeplinks', () {
    int id = 1234;
    var result = Helpers.parseDiscussionUri('?l=topic;id=$id');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.postId], null);
  });

  test('Should parse NEW internal deeplinks', () {
    int id = 1234;
    var result = Helpers.parseDiscussionUri('/discussion/$id');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.postId], null);
  });

  test('Should NOT parse internal deeplinks', () {
    var result = Helpers.parseDiscussionUri('/discussion/');
    expect(result.isEmpty, true);
    expect(result, {});
    expect(result[INTERNAL_URI_PARSER.discussionId], null);
    expect(result[INTERNAL_URI_PARSER.postId], null);
  });
}
