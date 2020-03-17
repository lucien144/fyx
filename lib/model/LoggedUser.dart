class LoggedUser {
  static final LoggedUser _singleton = LoggedUser._internal();
  String _nickname;

  String get avatar => 'https://i.nyx.cz/${_nickname.substring(0, 1)}/$_nickname.gif';

  factory LoggedUser() {
    return _singleton;
  }

  LoggedUser._internal();

  String get nickname {
    if (_nickname == null || _nickname == '') {
      throw Exception('You must initiate logged user first!');
    }
    return _nickname;
  }

  set nickname(String value) {
    if (_nickname != null) {
      throw Exception('Cannot initiate multiple logged users!');
    }
    _nickname = value.toUpperCase();
  }
}
