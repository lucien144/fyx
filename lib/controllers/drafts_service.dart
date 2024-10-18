import 'package:hive_flutter/hive_flutter.dart';

class DraftsService {
  static final DraftsService _singleton = DraftsService._internal();
  late Box<dynamic> _box;

  factory DraftsService() {
    return _singleton;
  }

  DraftsService._internal();

  Future<DraftsService> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('drafts');
    return _singleton;
  }

  String loadDiscussionMessage(int id) {
    return _box.get('post-${id.toString()}') ?? '';
  }

  saveDiscussionMessage({required int id, required String message}) {
    if (message.isNotEmpty) {
      _box.put('post-${id.toString()}', message);
    }
  }

  removeDiscussionMessage(int id) {
    _box.delete('post-${id.toString()}');
  }

}
