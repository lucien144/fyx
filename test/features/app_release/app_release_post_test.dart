import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/app_release/presentation/app_release_post.dart';

void main() {
  test('a post url opens the post itself', () {
    final arguments = releasePostArguments('/discussion/24237/id/123456');

    expect(arguments.discussionId, 24237);
    expect(arguments.postId, 123457);
  });

  test('a missing or invalid url opens the Fyx club', () {
    for (final url in [null, '', '/discussion/24237', 'nonsense']) {
      final arguments = releasePostArguments(url);

      expect(arguments.discussionId, fyxClubId, reason: '$url');
      expect(arguments.postId, isNull, reason: '$url');
    }
  });
}
