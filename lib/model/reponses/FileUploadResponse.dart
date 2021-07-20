class FileUploadResponse {
  int id = 0;
  String fileType = '';
  int idSpecific = 0;
  int idSpecific2 = 0;
  String filename = '';
  int size = 0;
  int uploadedAt = 0;
  String mimetype = '';
  int imageWidth = 0;
  int imageHeight = 0;
  String imageAvgColorHex = '';
  bool imageEmbed = false;
  String url = '';
  String thumbUrl = '';
  bool _isImage = false;

  bool get isImage => _isImage;

  FileUploadResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    fileType = json['file_type'] ?? '';
    idSpecific = json['id_specific'] ?? 0;
    idSpecific2 = json['id_specific2'] ?? 0;
    filename = json['filename'] ?? '';
    size = json['size'] ?? 0;
    uploadedAt = DateTime.parse(json['uploaded_at'] ?? '0').millisecondsSinceEpoch;
    mimetype = json['mimetype'] ?? '';
    imageWidth = json['image_width'] ?? 0;
    imageHeight = json['image_height'] ?? 0;
    imageAvgColorHex = json['image_avg_color_hex'] ?? '';
    imageEmbed = json['image_embed'] ?? false;
    url = json['url'] ?? '';
    thumbUrl = json['thumb_url'] ?? '';
    _isImage = thumbUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['file_type'] = this.fileType;
    data['id_specific'] = this.idSpecific;
    data['id_specific2'] = this.idSpecific2;
    data['filename'] = this.filename;
    data['size'] = this.size;
    data['uploaded_at'] = this.uploadedAt;
    data['mimetype'] = this.mimetype;
    data['image_width'] = this.imageWidth;
    data['image_height'] = this.imageHeight;
    data['image_avg_color_hex'] = this.imageAvgColorHex;
    data['image_embed'] = this.imageEmbed;
    data['url'] = this.url;
    data['thumb_url'] = this.thumbUrl;
    return data;
  }
}
