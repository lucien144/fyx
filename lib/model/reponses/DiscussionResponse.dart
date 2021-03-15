import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/System.dart';

class DiscussionResponse {
  Discussion _discussion;
  List _posts;

  DiscussionResponse.fromJson(Map<String, dynamic> json) {
    this._discussion = Discussion.fromJson(json['discussion_common']);
    this._posts = json['posts'];

    // TODO: New API
    // this._system = System.fromJson(json['system']);
  }

  Discussion get discussion => _discussion;
  List get posts => _posts;
}
