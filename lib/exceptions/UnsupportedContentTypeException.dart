class UnsupportedContentTypeException implements Exception {
  final String type;
  const UnsupportedContentTypeException([this.type = ""]);

  String toString() {
    return 'UnsupportedContentTypeException: Unsupported "${this.type}" type.';
  }
}
