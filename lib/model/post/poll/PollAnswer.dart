import 'package:fyx/model/post/poll/PollResult.dart';

class PollAnswer {
  late int _id;
  late String _answer;
  late PollResult _result;

  int get id => _id;

  String get answer => _answer;

  PollResult get result => _result;

  PollAnswer.fromJson(int id, Map<String, dynamic> json) {
    _id = id;
    _answer = json['answer'] ?? '';
    _result = json['result'] != null ? PollResult.fromJson(json['result']) : PollResult();
  }

}
