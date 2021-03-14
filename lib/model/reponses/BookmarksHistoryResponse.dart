import 'package:fyx/model/System.dart';

class BookmarksHistoryResponse {
  List<dynamic> _discussions = [];
  List<dynamic> _categories = [];
  System _system;

  BookmarksHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('discussions') && json['discussions'] is List) {
      _discussions = json['discussions'];
      _categories = json['categories'];
      // TODO: New API
      //_system = System.fromJson(json['system']);
    }
  }

  System get system => _system;

  List<dynamic> get discussions => _discussions;

  List<dynamic> get categories => _categories;
}
