class BookmarksResponse {
  List<dynamic> _discussions;
  List<dynamic> _categories;
  Map<String, dynamic> _system;

  BookmarksResponse.fromJson(Map<String, dynamic> json) {
    _discussions = json['data']['discussions'];
    _categories = json['data']['categories'];
    _system = json['system'];
//    TODO
//    "system": {
//      "max_file_size": "10485760",
//      "notice_count": "5",
//      "premium": "1"
//    }
  }

  Map<String, dynamic> get system => _system;

  List<dynamic> get discussions => _discussions;

  List<dynamic> get categories => _categories;
}
