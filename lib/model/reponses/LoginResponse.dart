class LoginResponse {
  int _code = 0;
  bool _error = false;
  String _message = '';

  // ignore: non_constant_identifier_names
  String _auth_token = '';
  // ignore: non_constant_identifier_names
  String _auth_code = '';

  LoginResponse.fromJson(Map<String, dynamic> json) {
    _code = int.parse(json['code'] ?? '0');
    _error = json['error'] ?? false;
    _message = json['message'] ?? '';
    _auth_token = json['token'] ?? '';
    _auth_code = json['confirmation_code'] ?? '';
  }

  bool get isAuthorized => _auth_code.isNotEmpty && _auth_token.isNotEmpty;

  String get authCode => _auth_code;

  String get authToken => _auth_token;

  bool get error => _error;

  String get message => _message;

  int get code => _code;
}
