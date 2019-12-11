import 'package:quiver/core.dart';

class Image {
  final String _image;
  final String _thumb;

  Image(this._image, this._thumb) : assert(_image != '');

  String get thumb => _thumb.isEmpty ? _image : _thumb;

  String get image => _image;

  @override
  int get hashCode => hash2(_image.hashCode, _thumb.hashCode);

  @override
  bool operator ==(other) => other is Image && other.thumb == _thumb && other.image == image;
}
