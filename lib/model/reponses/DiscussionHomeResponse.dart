import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/System.dart';

class DiscussionHomeResponse {
  Discussion _discussion;
  System _system;
  List<String> _home;
  List<String> _header;

  DiscussionHomeResponse.fromJson(Map<String, dynamic> json) {
    this._home = List<String>.from(json['home'] ?? []);
    this._header = List<String>.from(json['header'] ?? []);
    this._discussion = Discussion.fromJson(json['discussion']);
    this._system = System.fromJson(json['system']);
  }

  System get system => _system;

  Discussion get discussion => _discussion;

  List<String> get header => _header;

  List<String> get home => _home;
}
