
class PollComputedValues {

  bool _canModify = false;
  bool _userDidVote = false;
  int _totalVotes = 0;
  int _totalRespondents = 0;
  int _maximumAnswerVotes = 0;

  PollComputedValues.fromJson(Map<String, dynamic> json) {
    _canModify = json['can_modify'] ?? false;
    _userDidVote = json['user_did_vote'] ?? false;
    _totalVotes = json['total_votes'] ?? 0;
    _totalRespondents = json['total_respondents'] ?? 0;
    _maximumAnswerVotes = json['maximum_answer_votes'] ?? 0;
  }

  bool get canModify => _canModify;

  bool get userDidVote => _userDidVote;

  int get maximumAnswerVotes => _maximumAnswerVotes;

  int get totalRespondents => _totalRespondents;

  int get totalVotes => _totalVotes;
}