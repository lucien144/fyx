import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/model/enums/DiscussionContentTypeEnum.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse absolute header deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('https://nyx.cz/discussion/$id/content/header');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], DiscussionContentTypeEnum.header);
  });

  test('Should parse absolute home deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('https://nyx.cz/discussion/$id/content/home');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], DiscussionContentTypeEnum.home);
  });

  test('Should parse relative header deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('/discussion/$id/content/header');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], DiscussionContentTypeEnum.header);
  });

  test('Should parse relative home deeplinks', () {
    int id = 307;
    var result = Helpers.parseDiscussionContentUri('/discussion/$id/content/home');
    expect(result[INTERNAL_URI_PARSER.discussionId], id);
    expect(result[INTERNAL_URI_PARSER.homeOrHeader], DiscussionContentTypeEnum.home);
  });

  test('Should NOT parse plain discussion deeplinks', () {
    var result = Helpers.parseDiscussionContentUri('/discussion/307');
    expect(result.isEmpty, true);
  });

  test('Should NOT parse discussion post deeplinks', () {
    var result = Helpers.parseDiscussionContentUri('/discussion/307/id/12345');
    expect(result.isEmpty, true);
  });

  // _onLinkTap() runs the parsers in order and parseDiscussionContentUri() comes last,
  // so the earlier ones must not claim a content URI first — that would silently open
  // the discussion instead of its header/home.
  test('Should NOT be claimed by the other discussion parsers', () {
    for (final uri in ['/discussion/307/content/header', '/discussion/307/content/home', 'https://nyx.cz/discussion/307/content/header']) {
      expect(Helpers.parseDiscussionUri(uri).isEmpty, true, reason: '$uri must not parse as a plain discussion');
      expect(Helpers.parseDiscussionPostUri(uri).isEmpty, true, reason: '$uri must not parse as a discussion post');
      expect(Helpers.parseMailUri(uri).isEmpty, true, reason: '$uri must not parse as a mail');
      expect(Helpers.parseSearchUri(uri), null, reason: '$uri must not parse as a search');
    }
  });
}
