import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse OLD internal deeplinks', () {
    int id = 1234;
    int wu = 5678;
    var result = Helpers.parseDiscussionPostUri('?l=topic;id=$id;wu=$wu');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.postId], wu);
  });

  test('Should parse NEW internal deeplinks', () {
    int id = 1234;
    int wu = 5678;
    var result = Helpers.parseDiscussionPostUri('/discussion/$id/id/$wu');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.postId], wu);
  });

  test('Should NOT parse internal deeplinks', () {
    var result = Helpers.parseDiscussionPostUri('/discussion/');
    expect(result.isEmpty, true);
    expect(result, {});
    expect(result[INTERNAL_URI_PARSER.discussionId], null);
    expect(result[INTERNAL_URI_PARSER.postId], null);
  });
}
