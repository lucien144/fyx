class AuthException implements Exception {
  final message;
  const AuthException([this.message = ""]);

  String toString() {
    if (message == null) return "Exception";
    return message;
  }
}
