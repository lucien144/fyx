import 'dart:convert';

import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:sentry/sentry.dart';

class ContentRegular extends Content {
  String _body;
  late String _rawBody;

  /// If the post have consecutive images = ON
  /// Consecutive images means there are now characters other than
  /// whitespaces and <br> in between of images.
  bool _consecutiveImages = false;

  List<Image> _images = [];
  List<Link> _emptyLinks = [];
  List<Video> _videos = [];

  ContentRegular(this._body, {bool isCompact = false}) : super(PostTypeEnum.text, isCompact: isCompact) {
    _rawBody = _body;
    _rawBody = this._tagAllImageLinks(_rawBody); // This updates the raw body.
    _body = this._tagAllImageLinks(_body); // This updates the raw body.

    this._cleanupBody();
    this._parseEmbeds();
    this._parseAttachedImages();
    this._parseEmptyLinks();
    this._cleanupBody();
  }

  @override
  PostTypeEnum get contentType => PostTypeEnum.text;

  // HTML body stripped out of all HTML elements
  // Clean text content without single HTML element.
  // Used to check if there's ANY content at all.
  @override
  String get strippedContent => Helpers.stripHtmlTags(_body);

  @override
  String get body => _body;

  @override
  String get rawBody => _rawBody;

  @override
  List<Image> get images => _images;

  @override
  bool get consecutiveImages => _consecutiveImages;

  @override
  List<Link> get emptyLinks => _emptyLinks;

  @override
  List<Video> get videos => _videos;

  @override
  List<dynamic> get attachments {
    var list = [];
    list.addAll(_images);
    list.addAll(_videos);
    return list;
  }

  @override
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
    try {
      // Remove all HTML comments
      _body = _body.replaceAll(RegExp(r'<!--(.*?)-->'), '');

      // Remove trailing <br>
      // TODO: This consumes a lot of memory. Is it really needed?
      var startBr = RegExp(r'^(((\s*)<\s*br\s*\/?\s*>(\s*))*)', caseSensitive: false);
      _body = _body.replaceAll(startBr, '');

      // TODO: This consumes a lot of memory. Is it really needed?
      var trailingBr = RegExp(r'(((\s*)<\s*br\s*\/?\s*>(\s*))*)$', caseSensitive: false);
      _body = _body.replaceAll(trailingBr, '');

      var xmpTag = RegExp(r'<xmp>(.*?)</xmp>', caseSensitive: false, multiLine: true, dotAll: true);
      _body = _body.replaceAllMapped(xmpTag, (match) => '<pre>${HtmlEscape().convert(match.group(1) ?? '')}</pre>'); // TODO: Improve performance?
      _rawBody = _rawBody.replaceAllMapped(xmpTag, (match) => '<pre>${HtmlEscape().convert(match.group(1) ?? '')}</pre>'); // TODO: Improve performance?
    } catch (error) {
      Sentry.captureException(error, stackTrace: StackTrace.current);
    }
  }

  /// Parse emebeded videos.
  /// TODO: Others than YouTube. Vimeo? Soundcloud?
  void _parseEmbeds() {
    try {
      var document = parse(_body);
      var youtubes = document.querySelectorAll('div[data-embed-type="youtube"]');
      youtubes.forEach((el) {
        // If the video does not have preview, it's invalid Nyx attachment, therefore we skip it and handle it as a normal post.
        Element? img = el.querySelector('img');
        if (img == null) {
          return;
        }

        var video = Video(
            id: el.attributes['data-embed-value'] ?? '',
            type: Video.findVideoType(el.attributes['data-embed-type'] ?? ''),
            image: img.attributes['src'] ?? '',
            thumb: img.attributes['data-thumb']);

        // Remove the video element from the content.
        this._videos.add(video);

        // If the content should be reduced and compact, we need to remove the emebed otherwise the poster would be doubled in images.
        if (this.isCompact == true) {
          el.remove();
        }
      });
      _body = document.body!.innerHtml;
    } catch (error) {
      T.error(error.toString());
    }
  }

  /// Parse attached images
  /// For some reason the a>img[src] selector also selects standalone <img/> files
  /// -> Solved. It's the Nyx API. It wraps all images into the <a> tag with full image and replaces the img with thumbnail.
  void _parseAttachedImages() {
    try {

      // Check if consecutive images
      Document testDocument = parse(_body);
      Document document = parse(_body);
      List<Element> imgTags = testDocument.querySelectorAll('img');
      imgTags.forEach((imgTag) {
        // Check if the <img> tag is inside an <a> tag
        if (imgTag.parent != null && imgTag.parent?.localName == 'a') {
          imgTag.parent?.remove();
        } else {
          imgTag.remove();
        }
      });
      List<Element> whitespaceTags = testDocument.querySelectorAll('br');
      whitespaceTags.forEach((whitespaceTag) {
        whitespaceTag.remove();
      });
      String start = testDocument.body!.innerHtml.replaceAll(new RegExp(r"\s|\n|\r|\t"), "");
      String cleanedBody = document.body!.innerHtml.replaceAll(new RegExp(r"\s|\n|\r|\t"), "");
      _consecutiveImages = cleanedBody.startsWith(start);

      document.querySelectorAll('img[src]').forEach((Element el) {
        var image = el.attributes['src'] ?? '';
        var thumb = el.attributes['data-thumb'] ?? '';
        _images.add(Image(image, thumb: thumb));

        if (_consecutiveImages) {
          el.remove();
        }
      });
      _body = document.body!.innerHtml;
    } catch (error) {
      Sentry.captureException(error, stackTrace: StackTrace.current);
    }
  }

  String _tagAllImageLinks(String source) {
    Document document = parse(source);
    document.querySelectorAll('img').forEach((Element el) {
      el.parent?.classes.add('image-link');
    });
    return document.body!.innerHtml;
  }

  ///
  /// Nyx wraps all images to a link. So if we pick the images to the gallery, there will be empty links if the image has been wrapped by user.
  ///
  /// Example
  /// Post: <a href="google.com"><img src="img.png"></a>
  /// Nyx API returns: <a href="google.com"><a href="img.png"><img src="i.nyx.cz/thumb.jpg"></a></a>
  ///
  void _parseEmptyLinks() {
    try {
      RegExp r = RegExp(r'<a[^>]*?>\s*<\/a>', caseSensitive: false, multiLine: true);
      r.allMatches(_body).forEach((match) {
        String? element = match.group(0);
        Document html = parse(element);
        String? url = html.querySelector('a')?.attributes['href'];
        if (url != null && element != null) {
          _emptyLinks.add(Link(url));
          _body = _body.replaceFirst(element, '');
        }
      });
    } catch (error) {
      Sentry.captureException(error, stackTrace: StackTrace.current);
    }
  }
}
