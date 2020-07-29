import 'package:fyx/model/Discussion.dart';

class DiscussionResponse {
  List _attributes;
  List _data;
  Discussion _discussion;
  Map<String, dynamic> _system;

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

    // TODO: Populate the system with schema:
//    "system": {
//    "max_file_size": "10485760",
//    "premium": ""
//    }
    this._system = json['system'];
  }

  Map<String, dynamic> get system => _system;

  Discussion get discussion => _discussion;

  List get data => _data;

  List get attributes => _attributes;
}
