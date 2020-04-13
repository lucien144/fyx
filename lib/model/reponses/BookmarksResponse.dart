import 'package:fyx/model/System.dart';

class BookmarksResponse {
  List<dynamic> _discussions;
  List<dynamic> _categories;
  System _system;

  BookmarksResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is Map) {
      _discussions = json['data']['discussions'];
      _categories = json['data']['categories'];
      _system = System.fromJson(json['system']);
    }
  }

  System get system => _system;

  List<dynamic> get discussions => _discussions;

  List<dynamic> get categories => _categories;
}
