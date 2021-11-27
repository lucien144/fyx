import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/ResponseContext.dart';

class DiscussionHomeResponse {
  late Discussion _discussion;
  late ResponseContext _context;
  List<String> _home = [];
  List<String> _header = [];

  DiscussionHomeResponse.fromJson(Map<String, dynamic> json) {
    this._home = List<String>.from(json['home'] ?? []);
    this._header = List<String>.from(json['header'] ?? []);
    this._discussion = Discussion.fromJson(json['discussion']);
    this._context = ResponseContext.fromJson(json['context']);
  }

  ResponseContext get context => _context;

  Discussion get discussion => _discussion;

  List<String> get header => _header;

  List<String> get home => _home;
}
