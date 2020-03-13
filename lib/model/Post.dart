import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

class Post {
  int idKlub;
  // ignore: non_constant_identifier_names
  int _id_wu;
  String _rawContent;
  String _nick;
  int _time;
  // ignore: non_constant_identifier_names
  int _wu_rating;
  // ignore: non_constant_identifier_names
  int _wu_type;
  bool _reminder;

  String _content;
  List<Image> _images = [];
  List<Link> _links = [];
  List<Video> _videos = [];

  Post.fromJson(Map<String, dynamic> json, this.idKlub) {
    var unescape = HtmlUnescape();
    var content = unescape.convert(json['content']);

    this._id_wu = int.parse(json['id_wu']);
    this._rawContent = content;
    this._content = content;
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);
    this._reminder = (json['reminder'] ?? 'no') == 'yes';

    // TODO: Handle spoilers
    // TODO: Handle <code/> tags
    this._removeTrailingBr();
    this._parseEmbeds();
    this._parseAttachedImages();
    this._parseLinks();
  }

  void _removeTrailingBr() {
    var startBr = RegExp(r'^(((\s*)<\s*br\s*\/?\s*>(\s*))*)', caseSensitive: false);
    _content = _content.replaceAll(startBr, '');

    var trailingBr = RegExp(r'(((\s*)<\s*br\s*\/?\s*>(\s*))*)$', caseSensitive: false);
    _content = _content.replaceAll(trailingBr, '');
  }

  /// Parse emebeded videos.
  /// TODO: Others than YouTube. Vimeo? Soundcloud?
  void _parseEmbeds() {
    try {
      var document = parse(_content);
      var youtubes = document.querySelectorAll('div[data-embed-type="youtube"]');
      youtubes.forEach((el) {
        // If the video does not have preview, it's invalid Nyx attachment, therefore we skip it and handle it as a normal post.
        if (el.querySelector('img') == null) {
          return;
        }

        var video = Video(
            id: el.attributes['data-embed-value'],
            type: Video.findVideoType(el.attributes['data-embed-type']),
            image: el.querySelector('a').attributes['href'],
            thumb: el.querySelector('img').attributes['src']);

        // Remove the video element from the content.
        this._videos.add(video);

        while (el.nextElementSibling?.localName == 'br') {
          el.nextElementSibling.remove();
        }
        el.remove();
      });
      _content = document.body.innerHtml;
    } catch (error) {
      PlatformTheme.error(error.toString());
    }
  }

  /// Parse attached images
  /// TODO: Parse other attachments and standalone <img/>
  void _parseAttachedImages() {
    var document = parse(_content);
    document.querySelectorAll('a > img[src]').forEach((Element el) {
      var thumb = el.attributes['src'];
      var image = el.parent.attributes['href'];
      _images.add(Image(image, thumb));

      while (el.parent.nextElementSibling?.localName == 'br') {
        el.parent.nextElementSibling.remove();
      }
      el.parent.remove();
    });
    _content = document.body.innerHtml;
  }

  ///
  /// Parse any link that's not internal link.
  ///
  void _parseLinks() {
    var document = parse(_content);

    // Find all links with scraped title.
    _links = document.querySelectorAll('b + br + a:not([data-link-wu])').map((Element el) {
      var link = Link(el.attributes['href'], title: el.previousElementSibling.previousElementSibling.text);
      el.remove();
      return link;
    }).toList();

    // Find all other links.
    document = parse(document.body.innerHtml);
    _links.addAll(document.querySelectorAll('a:not([data-link-wu]):not([href^=\\?])').map((Element el) => Link(el.attributes['href'], title: el.text)));
  }

  String get strippedContent => parse(parse(_content).body.text).documentElement.text.trim();

  String get content => _content;

  String get rawContent => _rawContent;

  int get type => _wu_type;

  int get rating => _wu_rating;

  set rating(val) => _wu_rating = val;

  int get time => _time;

  String get avatar => 'https://i.nyx.cz/${this.nick.substring(0, 1)}/${this.nick}.gif';

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;

  List<Image> get images => _images;

  List<Link> get links => _links;

  List<Video> get videos => _videos;

  // ignore: unnecessary_getters_setters
  bool get hasReminder => _reminder;

  // ignore: unnecessary_getters_setters
  set hasReminder(bool value) => _reminder = value;

  List<dynamic> get attachments {
    var list = [];
    list.addAll(_images);
    list.addAll(_links);
    list.addAll(_videos);
    return list;
  }

  Map<String, dynamic> get attachmentsWithFeatured {
    var cloneImages = List.from(_images);
    var cloneLinks = List.from(_links);
    var cloneVideos = List.from(_videos);

    dynamic getFeatured = () {
      if (cloneImages.length > 0) {
        final featured = cloneImages[0];
        cloneImages.removeAt(0);
        return featured;
      }

      if (cloneVideos.length > 0) {
        final featured = cloneVideos[0];
        cloneVideos.removeAt(0);
        return featured;
      }

      if (cloneLinks.length > 0) {
        final featured = cloneLinks[0];
        cloneLinks.removeAt(0);
        return featured;
      }
    };

    var featured = getFeatured();

    var attachments = [];
    attachments.addAll(cloneImages);
    attachments.addAll(cloneLinks);
    attachments.addAll(cloneVideos);
    return {'featured': featured, 'attachments': attachments};
  }
}
