class LoginResponse {
  String _result;
  int _code;
  String _error;
  // ignore: non_constant_identifier_names
  String _auth_state;
  // ignore: non_constant_identifier_names
  String _auth_token;
  // ignore: non_constant_identifier_names
  String _auth_code;
  // ignore: non_constant_identifier_names
  String _auth_dev_comment;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    _result = json['result'];
    _code = int.parse(json['code']);
    _error = json['error'];
    _auth_state = json['auth_state'];
    _auth_token = json['auth_token'];
    _auth_code = json['auth_code'];
    _auth_dev_comment = json['auth_dev_comment'];
  }

  String get authDevComment => _auth_dev_comment;

  String get authCode => _auth_code;

  String get authToken => _auth_token;

  String get authState => _auth_state;

  String get error => _error;

  int get code => _code;

  String get result => _result;
}
