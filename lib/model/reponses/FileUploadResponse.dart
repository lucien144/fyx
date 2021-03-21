class FileUploadResponse {
  int id;
  String fileType;
  int idSpecific;
  int idSpecific2;
  String filename;
  int size;
  int uploadedAt;
  String mimetype;
  int imageWidth;
  int imageHeight;
  String imageAvgColorHex;
  bool imageEmbed;
  String url;
  String thumbUrl;
  bool _isImage;

  bool get isImage => _isImage;

  FileUploadResponse(
      {this.id,
      this.fileType,
      this.idSpecific,
      this.idSpecific2,
      this.filename,
      this.size,
      this.uploadedAt,
      this.mimetype,
      this.imageWidth,
      this.imageHeight,
      this.imageAvgColorHex,
      this.imageEmbed,
      this.url,
      this.thumbUrl});

  FileUploadResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileType = json['file_type'];
    idSpecific = json['id_specific'];
    idSpecific2 = json['id_specific2'];
    filename = json['filename'];
    size = json['size'];
    uploadedAt = DateTime.parse(json['uploaded_at'] ?? '0').millisecondsSinceEpoch;
    mimetype = json['mimetype'];
    imageWidth = json['image_width'];
    imageHeight = json['image_height'];
    imageAvgColorHex = json['image_avg_color_hex'];
    imageEmbed = json['image_embed'];
    url = json['url'];
    thumbUrl = json['thumb_url'];
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
