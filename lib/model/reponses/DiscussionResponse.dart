class DiscussionResponse {
  List _attributes;
  List _data;
  Map<String, dynamic> _discussion;
  Map<String, dynamic> _system;

  DiscussionResponse.fromJson(Map<String, dynamic> json) {
    this._attributes = json['attributes'];
    this._data = json['data'];

    // TODO: Use the Discussion Model and populate it with schema:
//    "discussion": {
//    "id_klub": "1786",
//    "booked": "1",
//    "owner": "0",
//    "name": "private intercom",
//    "name_main": "private intercom",
//    "name_sub": "",
//    "last_visit": "51767200",
//    "has_home": "1",
//    "has_header": "1",
//    "id_domain": "1000",
//    "id_location": "0",
//    "rights": {
//    "write": "1",
//    "delete": "1"
//    }
//    },
    this._discussion = json['discussion'];
    // TODO: Populate the system with schema:
//    "system": {
//    "max_file_size": "10485760",
//    "premium": ""
//    }
    this._system = json['system'];
  }

  Map<String, dynamic> get system => _system;

  Map<String, dynamic> get discussion => _discussion;

  List get data => _data;

  List get attributes => _attributes;
}
