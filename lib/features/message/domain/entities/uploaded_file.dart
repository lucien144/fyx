class UploadedFile {
  final int id;
  final String fileType;
  final int idSpecific;
  final int idSpecific2;
  final String filename;
  final int size;
  final DateTime uploadedAt;
  final String mimetype;
  final int imageWidth;
  final int imageHeight;
  final String imageAvgColorHex;
  final bool imageEmbed;
  final String url;
  final String thumbUrl;

  bool get isImage => thumbUrl.isNotEmpty;

  const UploadedFile({
    required this.id,
    required this.fileType,
    required this.idSpecific,
    required this.idSpecific2,
    required this.filename,
    required this.size,
    required this.uploadedAt,
    required this.mimetype,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageAvgColorHex,
    required this.imageEmbed,
    required this.url,
    required this.thumbUrl,
  });
}
