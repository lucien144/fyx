import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/features/post/domain/repositories/post_repository.dart';
import 'package:fyx/model/Post.dart';

/// [PostRepository] backed by the Nyx API through [ApiController].
class PostRepositoryImpl implements PostRepository {
  @override
  Future<List<Post>> getReplies({required int discussionId, required int postId}) async {
    final response = await ApiController().loadDiscussion(discussionId, lastId: postId, filterReplies: true);
    if (response.error) throw Exception('Failed to load replies of post $postId.');
    return response.posts.map((raw) => Post.fromJson(raw, discussionId)).toList();
  }
}
