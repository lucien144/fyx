import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/model/Mail.dart';

class MailsToDelete extends StateNotifier<List<Mail>> {
  MailsToDelete() : super([]);

  static final provider = StateNotifierProvider.autoDispose<MailsToDelete, List<Mail>>((ref) {
    return MailsToDelete();
  });

  void copy(List<Mail> list) {
    state = list;
  }

  void add(Mail post) {
    state = [...state, post];
  }

  void remove(Mail post) {
    state = [
      for (final _post in state)
        if (_post.id != post.id) _post,
    ];
  }

  void reset() {
    state = [];
  }
}