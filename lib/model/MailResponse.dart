class MailResponse {
  List _attributes;
  List _data;
  Map<String, dynamic> _system;

  MailResponse.fromJson(Map<String, dynamic> json) {
    this._attributes = json['attributes'];
    this._data = json['data'];
    this._system = json['system'];
  }

  Map<String, dynamic> get system => _system;

  List get data => _data;

  List get attributes => _attributes;
}
