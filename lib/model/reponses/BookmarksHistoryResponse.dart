import 'package:fyx/model/ResponseContext.dart';

class BookmarksHistoryResponse {
  List<dynamic> _discussions = [];
  List<dynamic> _categories = [];
  ResponseContext? _context;

  BookmarksHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('discussions') && json['discussions'] is List) {
      _discussions = json['discussions'];
      _categories = json['categories'];
      _context = ResponseContext.fromJson(json['context']);
    }
  }

  ResponseContext? get context => _context;

  List<dynamic> get discussions => _discussions;

  List<dynamic> get categories => _categories;
}
