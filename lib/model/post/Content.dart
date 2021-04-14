import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';

// TODO move post specific methods to PostContent
abstract class Content {
  final bool isCompact;

  String _body;

  Content(this._body, { this.isCompact });

  PostTypeEnum get contentType;

  // HTML body stripped out of all HTML elements
  // Clean text content without single HTML element.
  // Used to check if there's ANY content at all.
  String get strippedContent;

  String get body;

  String get rawBody;

  List<Image> get images;

  bool get consecutiveImages;

  List<Link> get emptyLinks;

  List<Video> get videos;

  List<dynamic> get attachments;

  Map<String, dynamic> get attachmentsWithFeatured;
}
