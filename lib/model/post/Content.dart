import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';

// TODO move post specific methods to PostContent
abstract class Content {
  final bool isCompact;
  PostTypeEnum _contentType;

  Content(this._contentType, { this.isCompact = false });

  bool get isNotEmpty => body.isNotEmpty;

  PostTypeEnum get contentType => _contentType;

  String get strippedContent => "";

  String get body => "";

  String get rawBody => "";

  List<Image> get images => [];

  bool get consecutiveImages => false;

  List<Link> get emptyLinks => [];

  List<Video> get videos => [];

  List<dynamic> get attachments => [];

  Map<String, dynamic> get attachmentsWithFeatured => {};
}
