import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/Helpers.dart';

/// The Fyx club, where releases and their changelogs are posted.
const int fyxClubId = 24237;

/// Arguments opening a release post (`/discussion/<club>/id/<post>`), or the
/// Fyx club when [postUrl] is missing or invalid.
DiscussionPageArguments releasePostArguments(String? postUrl) {
  final post = postUrl == null ? const {} : Helpers.parseDiscussionPostUri(postUrl);
  final discussionId = post[INTERNAL_URI_PARSER.discussionId] ?? 0;
  final postId = post[INTERNAL_URI_PARSER.postId] ?? 0;
  return discussionId > 0 && postId > 0
      ? DiscussionPageArguments(discussionId, postId: postId + 1) // +1 so the post itself is included
      : DiscussionPageArguments(fyxClubId);
}
