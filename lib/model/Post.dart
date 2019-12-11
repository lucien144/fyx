import 'package:fyx/model/post/Image.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class Post {
  // ignore: non_constant_identifier_names
  int _id_wu;
  String _rawContent;
  String _nick;
  int _time;
  // ignore: non_constant_identifier_names
  int _wu_rating;
  // ignore: non_constant_identifier_names
  int _wu_type;

  String _content;
  List<Image> _images;
  List<String> _links;

  final RegExp _regexpImages = RegExp(r'(<a(.*?)href="(?<image>([^"]*?)\.(jpg|png|gif))"(.*?)src="(?<thumb>([^"]*?)\.(jpg|png|gif))"(.*?)<\/a>)', multiLine: true);

  Post.fromJson(Map<String, dynamic> json) {
    this._id_wu = int.parse(json['id_wu']);
    this._rawContent = json['content'];
    this._content = json['content'];
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);

    // Parse images first
    this._parseImages();

    // Then links
    this._parseLinks();
  }

  void _parseImages() {
    _images = _regexpImages.allMatches(_rawContent).map((f) => Image(f.namedGroup('image'), f.namedGroup('thumb'))).toList();
    _content = _content.replaceAll(_regexpImages, '');
  }

  void _parseLinks() {
    var document = parse(_content);
    _links = document.querySelectorAll('a').map((Element el) => el.attributes['href']).toList();
  }

  String get content => _content;

  String get rawContent => _rawContent;

  int get type => _wu_type;

  int get rating => _wu_rating;

  int get time => _time;

  String get avatar => 'https://i.nyx.cz/${this.nick.substring(0, 1)}/${this.nick}.gif';

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;

  List<Image> get images => _images;

  List<String> get links => _links;
}
