import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/poll/PollAnswer.dart';
import 'package:fyx/model/post/poll/PollComputedValues.dart';

class ContentPoll extends Content {
  String _question;
  String _instructions;
  bool _publicResults;
  int _allowedVotes;
  String _allowAnswersUntil;
  String _showAnswersAfter;
  List<PollAnswer> _answers;
  PollComputedValues _pollComputedValues;

  String get question => _question;

  String get instructions => _instructions;

  bool get publicResults => _publicResults;

  int get allowedVotes => _allowedVotes;

  String get allowAnswersUntil => _allowAnswersUntil;

  String get showAnswersAfter => _showAnswersAfter;

  List<PollAnswer> get answers => _answers;

  PollComputedValues get pollComputedValues => _pollComputedValues;

  ContentPoll.fromJson(Map<String, dynamic> json) : super(PostTypeEnum.poll, isCompact: false) {
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
    if (json['computed_values'] != null) {
      _pollComputedValues = PollComputedValues.fromJson(json['computed_values']);
    }
  }
}