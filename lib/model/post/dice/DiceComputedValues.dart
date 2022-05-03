class DiceComputedValues {
  bool _canModify = false;
  bool _userDidRoll = true;

  bool get canModify => _canModify;

  bool get userDidRoll => _userDidRoll;

  DiceComputedValues.fromJson(Map<String, dynamic> json) {
    _canModify = json['can_modify'] ?? false;
    _userDidRoll = json['user_did_roll'] ?? false;
  }
}
