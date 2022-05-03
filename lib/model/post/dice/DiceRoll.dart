

class DiceRoll {
  String _user = '';
  List<int> _rolls = <int>[];

  String get user => _user;

  List<int> get rolls => _rolls;

  DiceRoll.fromJson(Map<String, dynamic> json) {
    _user = json['user']['username'] ?? '';
    _rolls = json['rolls'].cast<int>();
  }
}
