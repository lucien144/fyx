class Credentials {
  String _nickname;
  String _token;
  String _fcmToken;

  Credentials(this._nickname, this._token, {fcmToken}) : this._fcmToken = fcmToken;

  copyWith({nickname, token, fcmToken}) {
    return Credentials(nickname ?? this._nickname, token ?? this._token, fcmToken: fcmToken ?? this._fcmToken);
  }

  Credentials.fromJson(Map<String, dynamic> json) {
    this._nickname = json['nickname'];
    this._token = json['token'];
    this._fcmToken = json['fcmToken'];
  }

  Map<String, dynamic> toJson() {
    return {'nickname': this._nickname, 'token': this._token, 'fcmToken': this._fcmToken};
  }

  String get token => _token;

  String get fcmToken => _fcmToken;

  String get nickname => _nickname.toUpperCase();

  String get avatar => 'https://i.nyx.cz/${nickname.substring(0, 1)}/$nickname.gif';

  bool get isValid => _token != null && _nickname != null;
}
