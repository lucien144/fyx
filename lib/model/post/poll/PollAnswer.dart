import 'package:fyx/model/post/poll/PollResult.dart';

class PollAnswer {
  late String _answer;
  late PollResult _result;

  String get answer => _answer;

  PollResult get result => _result;

  PollAnswer.fromJson(Map<String, dynamic> json) {
    _answer = json['answer'] ?? '';
    _result = json['result'] != null ? PollResult.fromJson(json['result']) : PollResult();
  }

}
