class Post {
  // ignore: non_constant_identifier_names
  int _id_wu;
  String _content;
  String _nick;
  int _time;
  // ignore: non_constant_identifier_names
  int _wu_rating;
  // ignore: non_constant_identifier_names
  int _wu_type;

  Post.fromJson(Map<String, dynamic> json) {
    this._id_wu = int.parse(json['id_wu']);
    this._content = json['content'];
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);
  }

  String get content => _content;

  int get type => _wu_type;

  int get rating => _wu_rating;

  int get time => _time;

  String get avatar => 'https://i.nyx.cz/${this.nick.substring(0, 1)}/${this.nick}.gif';

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;
}
