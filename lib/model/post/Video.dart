enum VIDEO_TYPE { youtube }

class Video {
  final VIDEO_TYPE type;
  final String id;
  final String image;
  final String thumb;
  final String _link;

  Video({this.type, this.id, this.image, this.thumb, String link})
      : _link = link,
        assert(type != null),
        assert(image != null);

  String get link {
    if (_link != null && _link != '') {
      return _link;
    }

    switch (this.type) {
      case VIDEO_TYPE.youtube:
        return 'https://www.youtube.com/watch?v=${this.id}';
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
