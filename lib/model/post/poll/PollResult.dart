class PollResult {
  int _respondentsCount = 0;
  bool _isMyVote = false;
  List<String> _respondents = [];

  int get respondentsCount => _respondentsCount;

  bool get isMyVote => _isMyVote;

  List<String> get respondents => _respondents;

  PollResult();

  PollResult.fromJson(Map<String, dynamic> json) {
    _respondentsCount = json['respondents_count'] ?? 0;
    _isMyVote = json['is_my_vote'] ?? false;
    if (json['respondents'] != null) {
      _respondents = (json['respondents'] as List<dynamic>).map((respondent) => respondent.toString()).toList();
    }
  }
}
