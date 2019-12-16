class Link {
  final String url;
  final String _title;

  Link(this.url, {String title}) : _title = title;

  String get title => _title == null ? fancyUrl : _title;

  String get fancyUrl => url.replaceAll(RegExp(r'^https?:\/\/(www\.)?'), '');
}
