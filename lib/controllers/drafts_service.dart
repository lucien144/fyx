import 'package:hive_flutter/hive_flutter.dart';

class DraftsService {
  static final DraftsService _singleton = DraftsService._internal();
  late Box<dynamic> _box;
  final _postKey = 'post';
  final _discussionKey = 'discussion';

  factory DraftsService() {
    return _singleton;
  }

  DraftsService._internal();

  Future<DraftsService> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('drafts');
    return _singleton;
  }

  Box get box => _box;

  String loadDiscussionMessage(int id) {
    return _box.get('$_discussionKey-${id.toString()}') ?? '';
  }

  saveDiscussionMessage({required int id, required String message}) {
    if (message.isNotEmpty) {
      _box.put('$_discussionKey-${id.toString()}', message);
    }
  }

  removeDiscussionMessage(int id) {
    _box.delete('$_discussionKey-${id.toString()}');
  }

  String loadPostMessage(int id) {
    return _box.get('$_postKey-${id.toString()}') ?? '';
  }

  savePostMessage({required int id, required String message}) {
    if (message.isNotEmpty) {
      _box.put('$_postKey-${id.toString()}', message);
    }
  }

  removePostMessage(int id) {
    _box.delete('$_postKey-${id.toString()}');
  }

  countPosts() {
    return _box.keys.where((key) => (key as String).startsWith(_postKey)).length;
  }

  countDiscussions() {
    return _box.keys.where((key) => (key as String).startsWith(_discussionKey)).length;
  }

  flush() {
    _box.clear();
  }
}
