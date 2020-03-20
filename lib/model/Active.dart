// ignore_for_file: non_constant_identifier_names

class Active {
  int _time;
  String _location;
  String _location_url;

  Active.fromJson(Map<String, dynamic> json) {
    _time = int.parse(json['time']);
    _location = json['location'];
    _location_url = json['location_url'];
  }

  String get url => _location_url;

  String get location => _location;

  int get time => _time;
}
