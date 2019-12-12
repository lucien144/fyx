import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

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
  List<Image> _images = [];
  List<String> _links = [];
  List<Video> _videos = [];

  final RegExp _regexpImages =
      RegExp(r'<a([^>]*?)href="(?<image>([^"]*?)\.(jpg|png|gif))"([^>]*)>(.*?)<img(.*?)src="(?<thumb>([^"]*?)\.(jpg|png|gif))"(.*?)<\/a>', multiLine: true, dotAll: true);

  Post.fromJson(Map<String, dynamic> json) {
    var unescape = HtmlUnescape();
    var content = unescape.convert(json['content']);

    this._id_wu = int.parse(json['id_wu']);
    this._rawContent = content;
    this._content = content;
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);

    this._parseEmbeds();
    this._parseImages();
    this._parseLinks();
  }

  void _parseEmbeds() {
    try {
      var document = parse(_content);
      var youtubes = document.querySelectorAll('div[data-embed-type="youtube"]');
      youtubes.forEach((element) {
        var video = Video(
            id: element.attributes['data-embed-value'],
            type: Video.findVideoType(element.attributes['data-embed-type']),
            image: element.querySelector('a').attributes['href'],
            thumb: element.querySelector('img').attributes['src']);

        // Remove the video element from the content.
        this._videos.add(video);
        element.remove();
      });
      _content = document.body.innerHtml;
    } catch (error) {
      PlatformTheme.error(error);
    }
  }

  void _parseImages() {
    _images = _regexpImages.allMatches(_rawContent).map((f) => Image(f.namedGroup('image'), f.namedGroup('thumb'))).toList();
    _content = _content.replaceAll(_regexpImages, '');
  }

  void _parseLinks() {
    var document = parse(_content);
    _links = document.querySelectorAll('a:not([data-link-wu])').map((Element el) => el.attributes['href']).toList();
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

  List<Video> get videos => _videos;
}
