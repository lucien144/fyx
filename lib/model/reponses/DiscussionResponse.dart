import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/ResponseContext.dart';

class DiscussionResponse {
  Discussion _discussion;
  List _posts;
  ResponseContext _context;

  DiscussionResponse.fromJson(Map<String, dynamic> json) {
    this._discussion = Discussion.fromJson(json['discussion_common']);
    this._posts = json['posts'];
    this._context = ResponseContext.fromJson(json['context']);
  }

  Discussion get discussion => _discussion;

  List get posts => _posts;

  ResponseContext get context => _context;
}
