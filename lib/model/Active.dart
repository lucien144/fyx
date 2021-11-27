// ignore_for_file: non_constant_identifier_names

class Active {
  late int _time;
  late String _location;
  late String _location_url;

  Active.fromJson(Map<String, dynamic> json) {
    _time = DateTime.parse(json['last_activity'] ?? '0').millisecondsSinceEpoch;
    _location = json['location'];
    _location_url = json['location_url'];
  }

  String get url => _location_url;

  String get location => _location;

  int get time => _time;
}
