import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/System.dart';

class DiscussionInfoResponse {
  Discussion _discussion;
  System _system;

  DiscussionInfoResponse.fromJson(Map<String, dynamic> json) {
    this._discussion = Discussion.fromJson(json['discussion']);
    this._system = System.fromJson(json['system']);
  }

  System get system => _system;

  Discussion get discussion => _discussion;
}
