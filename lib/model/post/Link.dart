class Link {
  final String _url;
  final String _title;

  Link(String url, {String title})
      : _url = url,
        _title = title;

  String get title => _title;

  String get url => _url;
}
