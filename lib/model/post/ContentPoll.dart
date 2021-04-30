import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/poll/PollAnswer.dart';
import 'package:fyx/model/post/poll/PollComputedValues.dart';

class ContentPoll extends Content {
  String _question;
  String _instructions;
  bool _publicResults;
  int _allowedVotes;
  int _allowAnswersUntil;
  int _showAnswersAfter;
  List<PollAnswer> _answers;
  PollComputedValues _pollComputedValues;

  String get question => _question;

  String get instructions => _instructions;

  bool get publicResults => _publicResults;

  int get allowedVotes => _allowedVotes;

  int get allowAnswersUntil => _allowAnswersUntil;

  int get showAnswersAfter => _showAnswersAfter;

  List<PollAnswer> get answers => _answers;

  PollComputedValues get pollComputedValues => _pollComputedValues;

  bool get canVote {
    bool _canVote = pollComputedValues != null && !pollComputedValues.userDidVote;
    if (allowAnswersUntil != null) {
      _canVote = _canVote && allowAnswersUntil > DateTime.now().millisecondsSinceEpoch;
    }
    return _canVote;
  }

  ContentPoll.fromJson(Map<String, dynamic> json) : super(PostTypeEnum.poll, isCompact: false) {
    _question = json['question'];
    _instructions = json['instructions'];
    _publicResults = json['public_results'];
    _allowedVotes = json['allowed_votes'];
    _allowAnswersUntil = json['allow_answers_until'] != null ? DateTime.parse(json['allow_answers_until']).millisecondsSinceEpoch : null;
    _showAnswersAfter = json['show_answers_after'] != null ? DateTime.parse(json['show_answers_after']).millisecondsSinceEpoch : null;
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