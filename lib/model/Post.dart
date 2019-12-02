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

  final RegExp _regexpAttachments = RegExp(r'(<a(.*?)href="(?<image>([^"]*?)\.(jpg|png|gif))"(.*?)src="(?<thumb>([^"]*?)\.(jpg|png|gif))"(.*?)<\/a>)', multiLine: true);

  Post.fromJson(Map<String, dynamic> json) {
    this._id_wu = int.parse(json['id_wu']);
    this._rawContent = json['content'];
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);
  }

  List<Map<String, String>> get images {
    var images = _regexpAttachments.allMatches(_rawContent).map((f) => {'image': f.namedGroup('image'), 'thumb': f.namedGroup('thumb')}).toList();
    return images;
  }

  List<String> get links {
    var document = parse(_rawContent);
    return document.querySelectorAll('a').map((Element el) => el.attributes['href']).toList();
  }

  String get rawContent => _rawContent;

  String get content {
    return _rawContent.replaceAll(_regexpAttachments, '');
  }

  int get type => _wu_type;

  int get rating => _wu_rating;

  int get time => _time;

  String get avatar => 'https://i.nyx.cz/${this.nick.substring(0, 1)}/${this.nick}.gif';

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;
}
