class PollResult {
  int _respondentsCount;
  bool _isMyVote;
  List<String> _respondents;

  int get respondentsCount => _respondentsCount;

  bool get isMyVote => _isMyVote;

  List<String> get respondents => _respondents;

  PollResult.fromJson(Map<String, dynamic> json) {
    _respondentsCount = json['respondents_count'] ?? 0;
    _isMyVote = json['is_my_vote'] ?? false;
    if (json['respondents'] != null) {
      _respondents = (json['respondents'] as List<dynamic>).map((respondent) => respondent.toString()).toList();
    }
  }
}
