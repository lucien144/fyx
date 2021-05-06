class FileAttachment {
  int _id;
  String _fileType;
  int _idSpecific;
  int _idSpecific2;
  String _filename;
  int _size;
  String _uploadedAt;
  String _mimetype;
  int _imageWidth;
  int _imageHeight;
  String _imageAvgColorHex;
  bool _imageEmbed;
  String _imageEmbedOption;
  String _url;
  String _thumbUrl;

  FileAttachment(
      {int id,
      String fileType,
      int idSpecific,
      int idSpecific2,
      String filename,
      int size,
      String uploadedAt,
      String mimetype,
      int imageWidth,
      int imageHeight,
      String imageAvgColorHex,
      bool imageEmbed,
      String imageEmbedOption,
      String url,
      String thumbUrl}) {
    this._id = id;
    this._fileType = fileType;
    this._idSpecific = idSpecific;
    this._idSpecific2 = idSpecific2;
    this._filename = filename;
    this._size = size;
    this._uploadedAt = uploadedAt;
    this._mimetype = mimetype;
    this._imageWidth = imageWidth;
    this._imageHeight = imageHeight;
    this._imageAvgColorHex = imageAvgColorHex;
    this._imageEmbed = imageEmbed;
    this._imageEmbedOption = imageEmbedOption;
    this._url = url;
    this._thumbUrl = thumbUrl;
  }

  int get id => _id;

  String get fileType => _fileType;

  int get idSpecific => _idSpecific;

  Null get idSpecific2 => _idSpecific2;

  String get filename => _filename;

  int get size => _size;

  String get uploadedAt => _uploadedAt;

  String get mimetype => _mimetype;

  int get imageWidth => _imageWidth;

  int get imageHeight => _imageHeight;

  String get imageAvgColorHex => _imageAvgColorHex;

  bool get imageEmbed => _imageEmbed;

  String get imageEmbedOption => _imageEmbedOption;

  String get url => _url;

  String get thumbUrl => _thumbUrl;

  FileAttachment.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _fileType = json['file_type'];
    _idSpecific = json['id_specific'] ?? 0;
    _idSpecific2 = json['id_specific2'] ?? 0;
    _filename = json['filename'];
    _size = json['size'];
    _uploadedAt = json['uploaded_at'];
    _mimetype = json['mimetype'];
    _imageWidth = json['image_width'];
    _imageHeight = json['image_height'];
    _imageAvgColorHex = json['image_avg_color_hex'] ?? '';
    _imageEmbed = json['image_embed'];
    _imageEmbedOption = json['image_embed_option'];
    _url = json['url'];
    _thumbUrl = json['thumb_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['file_type'] = this._fileType;
    data['id_specific'] = this._idSpecific;
    data['id_specific2'] = this._idSpecific2;
    data['filename'] = this._filename;
    data['size'] = this._size;
    data['uploaded_at'] = this._uploadedAt;
    data['mimetype'] = this._mimetype;
    data['image_width'] = this._imageWidth;
    data['image_height'] = this._imageHeight;
    data['image_avg_color_hex'] = this._imageAvgColorHex;
    data['image_embed'] = this._imageEmbed;
    data['image_embed_option'] = this._imageEmbedOption;
    data['url'] = this._url;
    data['thumb_url'] = this._thumbUrl;
    return data;
  }
}
