
class PollComputedValues {

  bool _canModify;
  bool _userDidVote;
  int _totalVotes;
  int _totalRespondents;
  int _maximumAnswerVotes;

  PollComputedValues.fromJson(Map<String, dynamic> json) {
    _canModify = json['can_modify'];
    _userDidVote = json['user_did_vote'];
    _totalVotes = json['total_votes'];
    _totalRespondents = json['total_respondents'];
    _maximumAnswerVotes = json['maximum_answer_votes'];
  }

  bool get canModify => _canModify;

  bool get userDidVote => _userDidVote;

  int get maximumAnswerVotes => _maximumAnswerVotes;

  int get totalRespondents => _totalRespondents;

  int get totalVotes => _totalVotes;
}