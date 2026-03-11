import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:fyx/features/message/domain/enums/image_quality.dart';

class Attachment {
  final Uint8List bytes;
  final String filename;
  final String extension;
  final MediaType mediaType;
  final ImageQuality quality;

  int get width => quality.width;

  Attachment({
    required this.filename,
    required this.extension,
    required this.mediaType,
    required this.bytes,
    this.quality = ImageQuality.hd,
  });

  Attachment copyWith({ImageQuality? quality}) {
    return Attachment(
      filename: filename,
      extension: extension,
      mediaType: mediaType,
      bytes: bytes,
      quality: quality ?? this.quality,
    );
  }
}
