class Discussion {
  int _id_klub;
  String _jmeno;
  int _unread;
  int _replies;
  int _images;
  int _links;

  Discussion.fromJson(Map<String, dynamic> json) {
    this._id_klub = int.parse(json['id_klub']);
    this._jmeno = json['jmeno'];
    this._unread = int.parse(json['unread']);
    this._replies = int.parse(json['replies']);
    this._images = int.parse(json['images']);
    this._links = int.parse(json['links']);
  }

  int get links => _links;

  int get images => _images;

  int get replies => _replies;

  int get unread => _unread;

  String get jmeno => _jmeno;

  int get idKlub => _id_klub;


}