import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/poll/PollAnswer.dart';
import 'package:fyx/model/post/poll/PollComputedValues.dart';

class ContentPoll extends Content {
  int postId = 0;
  int discussionId = 0;

  String _question = '';
  String _instructions = '';
  bool _publicResults = false;
  int _allowedVotes = 0;
  bool _allowEmptyVote = false;
  int _allowAnswersUntil = 0;
  int _showAnswersAfter = 0;
  List<PollAnswer> _answers = <PollAnswer>[];
  PollComputedValues? _pollComputedValues;

  String get question => _question;

  String get instructions => _instructions;

  bool get publicResults => _publicResults;

  int get allowedVotes => _allowedVotes;

  bool get allowEmptyVote => _allowEmptyVote;

  int get allowAnswersUntil => _allowAnswersUntil;

  int get showAnswersAfter => _showAnswersAfter;

  List<PollAnswer> get answers => _answers;

  PollComputedValues? get pollComputedValues => _pollComputedValues;

  bool get canVote {
    bool _canVote = pollComputedValues != null && !pollComputedValues!.userDidVote;
    if (allowAnswersUntil > 0) {
      _canVote = _canVote && allowAnswersUntil > DateTime.now().millisecondsSinceEpoch;
    }
    return _canVote;
  }

  ContentPoll.fromJson(Map<String, dynamic> json, {this.postId = 0, this.discussionId = 0}) : super(PostTypeEnum.poll, isCompact: false) {
    _question = json['question'] ?? '';
    _instructions = json['instructions'] ?? '';
    _publicResults = json['public_results'] ?? false;
    _allowedVotes = json['allowed_votes'] ?? 0;
    _allowEmptyVote = json['allow_empty_vote'] ?? false;
    _allowAnswersUntil = json['allow_answers_until'] != null ? DateTime.parse(json['allow_answers_until']).millisecondsSinceEpoch : 0;
    _showAnswersAfter = json['show_answers_after'] != null ? DateTime.parse(json['show_answers_after']).millisecondsSinceEpoch : 0;
    if (json['answers'] != null) {
      _answers = <PollAnswer>[];
      (json['answers'] as Map<String, dynamic>).forEach((String key, dynamic answer) {
        _answers.add(new PollAnswer.fromJson(int.parse(key), answer as Map<String, dynamic>));
      });
      _answers.sort((a, b) => a.id.compareTo(b.id));
    }
    if (json['computed_values'] != null) {
      _pollComputedValues = PollComputedValues.fromJson(json['computed_values']);
    }
  }
}
