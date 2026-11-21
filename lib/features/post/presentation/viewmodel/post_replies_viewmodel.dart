import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/post/domain/repositories/post_repository.dart';
import 'package:fyx/features/post/presentation/viewmodel/post_replies_state.dart';
import 'package:fyx/model/Post.dart';

/// Drives one replies sheet. Registered as a factory: sheets can be stacked
/// (replies of a reply), so each needs its own instance.
class PostRepliesViewModel extends ChangeNotifier {
  final PostRepository _repository;
  final void Function(Object error, StackTrace stack) _logError;

  PostRepliesViewModel(this._repository, {void Function(Object error, StackTrace stack)? logError})
      : _logError = logError ?? _captureError;

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  PostRepliesState _state = const PostRepliesState();

  PostRepliesState get state => _state;

  /// Safe to call from initState: it does not notify before the first await.
  Future<void> load(Post post) async {
    _state = const PostRepliesState();
    try {
      final replies = await _repository.getReplies(discussionId: post.idKlub, postId: post.id);
      _state = _state.copyWith(status: PostRepliesStatus.ready, replies: replies);
    } catch (error, stack) {
      _logError(error, stack);
      _state = _state.copyWith(status: PostRepliesStatus.failed);
    }
    notifyListeners();
  }
}
