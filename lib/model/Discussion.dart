// ignore_for_file: non_constant_identifier_names

class Discussion {
  int _id_klub;

  String _name;
  String _name_main;
  String _name_sub;
  int _last_visit;
  bool _has_home;
  bool _has_header;
  int _id_domain;

  bool accessDenied = false;

  Discussion.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      this.accessDenied = true;
      return;
    }

    this._id_klub = json['discussion']['id'];
    this._name_main = json['discussion']['name_static'] ?? '';
    this._name_sub = json['discussion']['name_dynamic'] ?? '';
    this._name = '${this._name_main} ${this._name_sub}';
    this._has_home = json['discussion']['has_home'];
    this._has_header = json['discussion']['has_header'];
    this._id_domain = json['domain_id'] ?? 0;

    try {
      this._last_visit = DateTime.parse(json['bookmark']['last_visited_at']).millisecondsSinceEpoch;
    } catch (error) {
      this._last_visit = 0;
    }
  }

  String get jmeno => _name;

  String get name => _name;

  String get nameMain => _name_main;

  String get nameSubtitle => _name_sub;

  int get idKlub => _id_klub;

  int get lastVisit => _last_visit;

  bool get hasHome => _has_home;

  bool get hasHeader => _has_header;

  int get domainId => _id_domain;
}
