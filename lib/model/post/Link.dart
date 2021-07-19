class Link {
  final String url;
  final String _title;

  Link(this.url, {String title = ''}) : _title = title;

  String get title => _title.isEmpty ? fancyUrl : _trimUrl(_title);

  String get fancyUrl => _trimUrl(url);

  String _trimUrl(String url) => url.replaceAll(RegExp(r'^https?:\/\/(www\.)?'), '');
}
