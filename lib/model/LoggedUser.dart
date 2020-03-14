class LoggedUser {
  static final LoggedUser _singleton = LoggedUser._internal();
  String _nickname;

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
