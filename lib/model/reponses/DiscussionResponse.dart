import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/System.dart';

class DiscussionResponse {
  List _attributes;
  List _data;
  Discussion _discussion;
  System _system;

  DiscussionResponse.fromJson(Map<String, dynamic> json) {
    this._attributes = json['attributes'];
    this._data = json['data'];

    // TODO: Use the Discussion Model and populate it with schema:
//    "discussion": {
//    "rights": {
//    "write": "1",
//    "delete": "1"
//    }
//    },
    this._discussion = Discussion.fromJson(json['discussion']);
    this._system = System.fromJson(json['system']);
  }

  System get system => _system;

  Discussion get discussion => _discussion;

  List get data => _data;

  List get attributes => _attributes;
}
