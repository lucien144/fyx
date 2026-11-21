import 'package:flutter/foundation.dart';
import 'package:fyx/model/Post.dart';

enum PostRepliesStatus { loading, ready, failed }

@immutable
class PostRepliesState {
  final PostRepliesStatus status;
  final List<Post> replies;

  const PostRepliesState({this.status = PostRepliesStatus.loading, this.replies = const []});

  PostRepliesState copyWith({PostRepliesStatus? status, List<Post>? replies}) {
    return PostRepliesState(status: status ?? this.status, replies: replies ?? this.replies);
  }
}
