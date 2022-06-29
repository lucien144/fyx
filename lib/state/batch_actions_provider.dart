import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostsSelection extends StateNotifier<List<int>> {
  PostsSelection() : super([]);

  static final provider = StateNotifierProvider.autoDispose<PostsSelection, List<int>>((ref) {
    return PostsSelection();
  });

  void add(int id) {
    state = [...state, id];
  }

  void remove(int id) {
    state = [
      for (final postItemId in state)
        if (postItemId != id) postItemId,
    ];
  }

  void toggle(int id) {
    if (state.contains(id))
      this.remove(id);
    else
      this.add(id);
  }

  void reset() {
    state = [];
  }
}

class PostsToDelete extends StateNotifier<List<int>> {
  PostsToDelete() : super([]);

  static final provider = StateNotifierProvider.autoDispose<PostsToDelete, List<int>>((ref) {
    return PostsToDelete();
  });

  void copy(List<int> list) {
    state = list;
  }

  void add(int id) {
    state = [...state, id];
  }

  void remove(int id) {
    state = [
      for (final postItemId in state)
        if (postItemId != id) postItemId,
    ];
  }

  void reset() {
    state = [];
  }
}
