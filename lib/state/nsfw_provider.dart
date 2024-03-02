import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/model/MainRepository.dart';

class NsfwDiscussionList extends StateNotifier<Map<int, String>> {
  NsfwDiscussionList(Map<int, String> list) : super(list);

  static final provider = StateNotifierProvider.autoDispose<NsfwDiscussionList, Map<int, String>>((ref) {
    return NsfwDiscussionList(MainRepository().settings.nsfwDiscussionList.cast<int, String>());
  });

  void add(int id, String name) {
    state = {...state, id: name};
  }

  void remove(int id) {
    state.remove(id);
    state = {...state};
  }

  void toggle(int id, String name) {
    if (state.containsKey(id)) {
      this.remove(id);
      MainRepository().settings.removeNsfwDiscussion(id);
    } else {
      this.add(id, name);
      MainRepository().settings.addNsfwDiscussion(id, name);
    }
  }

  void reset() {
    state = {};
    MainRepository().settings.resetNsfwDiscussion();
  }
}
