class UserReferences {
  int _positive;
  int _negative;

  UserReferences({int positive, int negative}) {
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
