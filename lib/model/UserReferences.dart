class UserReferences {
  late int _positive;
  late int _negative;

  UserReferences({int positive = 0, int negative = 0}) {
    this._positive = positive;
    this._negative = negative;
  }

  int get positive => _positive;

  int get negative => _negative;

  UserReferences.fromJson(Map<String, dynamic> json) {
    _positive = json['positive'];
    _negative = json['negative'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['positive'] = this._positive;
    data['negative'] = this._negative;
    return data;
  }
}
