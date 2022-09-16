import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/model/Post.dart';

class PostsSelection extends StateNotifier<List<Post>> {
  PostsSelection() : super([]);

  static final provider = StateNotifierProvider.autoDispose<PostsSelection, List<Post>>((ref) {
    return PostsSelection();
  });

  void add(Post post) {
    state = [...state, post];
  }

  void remove(Post post) {
    state = [
      for (final _post in state)
        if (_post.id != post.id) _post,
    ];
  }

  void toggle(Post post) {
    if (state.contains(post))
      this.remove(post);
    else
      this.add(post);
  }

  void reset() {
    state = [];
  }
}

class PostsToDelete extends StateNotifier<List<Post>> {
  PostsToDelete() : super([]);

  static final provider = StateNotifierProvider.autoDispose<PostsToDelete, List<Post>>((ref) {
    return PostsToDelete();
  });

  void copy(List<Post> list) {
    state = list;
  }

  void add(Post post) {
    state = [...state, post];
  }

  void remove(Post post) {
    state = [
      for (final _post in state)
        if (_post.id != post.id) _post,
    ];
  }

  void reset() {
    state = [];
  }
}
