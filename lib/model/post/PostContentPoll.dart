import 'package:fyx/model/post/poll/PollAnswer.dart';

class PostContentPoll {
  String _question;
  String _instructions;
  bool _publicResults;
  int _allowedVotes;
  String _allowAnswersUntil;
  String _showAnswersAfter;
  List<PollAnswer> _answers;

  String get question => _question;

  String get instructions => _instructions;

  bool get publicResults => _publicResults;

  int get allowedVotes => _allowedVotes;

  String get allowAnswersUntil => _allowAnswersUntil;

  String get showAnswersAfter => _showAnswersAfter;

  List<PollAnswer> get answers => _answers;

  PostContentPoll.fromJson(Map<String, dynamic> json) {
    _question = json['question'];
    _instructions = json['instructions'];
    _publicResults = json['public_results'];
    _allowedVotes = json['allowed_votes'];
    _allowAnswersUntil = json['allow_answers_until'];
    _showAnswersAfter = json['show_answers_after'];
    if (json['answers'] != null) {
      _answers = new List<PollAnswer>();
      (json['answers'] as Map<String, dynamic>).forEach((String key, dynamic answer) {
        _answers.add(new PollAnswer.fromJson(answer as Map<String, dynamic>));
      });
    }
  }
}