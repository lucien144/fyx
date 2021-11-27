import 'package:fyx/model/post/Link.dart';

enum VIDEO_TYPE { youtube }

class Video {
  final VIDEO_TYPE type;
  final String image;
  final String id;
  final String? thumb;
  final Link? _link;

  Video({required this.id, required this.type, required this.image, this.thumb, String? link})
      : _link = link != null && link != '' ? Link(link) : null;

  Link? get link {
    if (_link != null) {
      return _link;
    }

    switch (this.type) {
      case VIDEO_TYPE.youtube:
        return Link('https://www.youtube.com/watch?v=${this.id}');
      default:
        throw Exception('Cannot get video link, unknown video.');
    }
  }

  static VIDEO_TYPE findVideoType(String videoType) {
    switch (videoType) {
      case 'youtube':
        return VIDEO_TYPE.youtube;
      default:
        throw Exception('Unknown video type');
    }
  }
}
