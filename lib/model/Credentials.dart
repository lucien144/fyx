class Credentials {
  final String _nickname;
  final String _token;

  const Credentials(this._nickname, this._token);

  String get token => _token;

  String get nickname => _nickname;

  bool get isValid => _token != null && _nickname != null;
}
