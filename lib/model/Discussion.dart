// ignore_for_file: non_constant_identifier_names

class Discussion {
  int _id_klub;
  int _id_cat;
  int _unread;
  int _replies;
  int _images;
  int _links;

  bool _booked;
  bool _owner;
  String _name;
  String _name_main;
  String _name_sub;
  int _last_visit;
  bool _has_home;
  bool _has_header;
  int _id_domain;
  int _id_location;

  Discussion.fromJson(Map<String, dynamic> json) {
    this._id_klub = int.parse(json['id_klub']);
    this._id_cat = int.parse(json['id_cat'] ?? '0');
    this._unread = int.parse(json['unread'] ?? '0');
    this._replies = int.parse(json['replies'] ?? '0'); // Premium
    this._images = int.parse(json['images'] ?? '0'); // Premium
    this._links = int.parse(json['links'] ?? '0'); // Premium

    // Discussion detail has different options
    this._booked = int.parse(json['booked'] ?? '0') == 1;
    this._owner = int.parse(json['owner'] ?? '0') == 1;
    this._name = json['jmeno'] ?? (json['name'] ?? '');
    this._name_main = json['name_main'] ?? '';
    this._name_sub = json['name_sub'] ?? '';
    this._has_home = int.parse(json['has_home'] ?? '0') == 1;
    this._has_header = int.parse(json['has_header'] ?? '0') == 1;
    this._id_domain = int.parse(json['id_domain'] ?? '0');
    this._id_location = int.parse(json['id_location'] ?? '0');

    String lastVisit = json['last_visit'] ?? '0';
    lastVisit = lastVisit == '' ? '0' : lastVisit;
    this._last_visit = int.parse(lastVisit);
  }

  int get links => _links;

  int get images => _images;

  int get replies => _replies;

  int get unread => _unread;

  String get jmeno => _name;
  String get name => _name;
  String get nameMain => _name_main;
  String get nameSubtitle => _name_sub;

  int get idKlub => _id_klub;

  int get idCat => _id_cat;

  bool get isBooked => _booked;

  bool get isOwner => _owner;

  int get lastVisit => _last_visit;

  bool get hasHome => _has_home;

  bool get hasHeader => _has_header;

  int get domainId => _id_domain;

  int get locationId => _id_location;
}
