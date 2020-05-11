import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

class Content {
  String _body;
  String _rawBody;

  /// If the post have consecutive images = ON
  /// Consecutive images means there are now characters other than
  /// whitespaces and <br> in between of images.
  bool _consecutiveImages = false;

  List<Image> _images = [];
  List<Link> _links = [];
  List<Video> _videos = [];

  Content(this._body) {
    _rawBody = _body;
    _body = HtmlUnescape().convert(_body);
    // TODO: Handle <code/> tags
    this._cleanupBody();
    this._parseEmbeds();
    this._parseAttachedImages();
    this._parseLinks();
  }

  String get strippedContent => parse(parse(_body).body.text).documentElement.text.trim();

  String get body => _body;

  String get rawBody => _rawBody;

  List<Image> get images => _images;

  bool get consecutiveImages => _consecutiveImages;

  List<Link> get links => _links;

  List<Video> get videos => _videos;

  List<dynamic> get attachments {
    var list = [];
    list.addAll(_images);
    list.addAll(_videos);
    return list;
  }

  Map<String, dynamic> get attachmentsWithFeatured {
    var cloneImages = List.from(_images);
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
    };

    var featured = getFeatured();

    var attachments = [];
    attachments.addAll(cloneImages);
    attachments.addAll(cloneVideos);
    return {'featured': featured, 'attachments': attachments};
  }

  void _cleanupBody() {
    // Remove all HTML comments
    _body = _body.replaceAll(RegExp(r'<!--(.*?)-->'), '');

    // Remove trailing <br>
    var startBr = RegExp(r'^(((\s*)<\s*br\s*\/?\s*>(\s*))*)', caseSensitive: false);
    _body = _body.replaceAll(startBr, '');

    var trailingBr = RegExp(r'(((\s*)<\s*br\s*\/?\s*>(\s*))*)$', caseSensitive: false);
    _body = _body.replaceAll(trailingBr, '');
  }

  /// Parse emebeded videos.
  /// TODO: Others than YouTube. Vimeo? Soundcloud?
  void _parseEmbeds() {
    try {
      var document = parse(_body);
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
      _body = document.body.innerHtml;
    } catch (error) {
      PlatformTheme.error(error.toString());
    }
  }

  /// Parse attached images
  /// For some reason the a>img[src] selector also selects standalone <img/> files
  void _parseAttachedImages() {
    Document document = parse(_body);

    RegExp reg = RegExp(r'^((?!<img).)*(((<a([^>]*?)>)?(\s*)<img([^>]*?)>(\s*)(<\/\s*a\s*>)?(\s*(\s*<\s*br\s*\/?\s*>\s*)*\s*))*)$', caseSensitive: false, dotAll: true);
    _consecutiveImages = reg.hasMatch(_body);

    document.querySelectorAll('a > img[src]').forEach((Element el) {
      var thumb = el.attributes['src'];
      var image = el.parent.attributes['href'];
      _images.add(Image(image, thumb));

      while (el.parent.nextElementSibling?.localName == 'br') {
        el.parent.nextElementSibling.remove();
      }
      el.parent.remove();
    });
    _body = document.body.innerHtml;
  }

  ///
  /// Parse any link that's not internal link.
  ///
  void _parseLinks() {
    var document = parse(_body);

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
}
