import 'package:quiver/core.dart';

class Image {
  final String image;
  final String _thumb;

  Image(this.image, {thumb = ''}): _thumb = thumb;

  String get thumb => _thumb.isEmpty ? image : _thumb;

  @override
  int get hashCode => hash2(image.hashCode, _thumb.hashCode);

  @override
  bool operator ==(other) => other is Image && other._thumb == _thumb && other.image == image;
}
