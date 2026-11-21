import 'package:fyx/model/Post.dart';

/// Discussion posts. Grows as post logic moves out of `ApiController` and `lib/model/`.
///
/// Returns the legacy [Post] model until posts get their own feature entity.
abstract class PostRepository {
  /// Replies to the post [postId] in [discussionId].
  Future<List<Post>> getReplies({required int discussionId, required int postId});
}
