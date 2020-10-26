// ignore_for_file: non_constant_identifier_names
import 'package:fyx/model/post/Content.dart';

class Post {
  final bool isCompact;
  int idKlub;
  int _id_wu;
  String _nick;
  int _time;
  int _wu_rating;
  int _wu_type;
  bool _reminder;

  Content _content;

  Post.fromJson(Map<String, dynamic> json, this.idKlub, { this.isCompact }) {
    this._id_wu = int.parse(json['id_wu']);
    this._content = Content(json['content'], isCompact: this.isCompact);
    this._nick = json['nick'];
    this._time = int.parse(json['time']);
    this._wu_rating = int.parse(json['wu_rating']);
    this._wu_type = int.parse(json['wu_type']);
    this._reminder = (json['reminder'] ?? 'no') == 'yes';
  }

  Content get content => _content;

  int get type => _wu_type;

  int get rating => _wu_rating;

  set rating(val) => _wu_rating = val;

  int get time => _time;

  String get avatar => 'https://i.nyx.cz/${this.nick.substring(0, 1)}/${this.nick}.gif';

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;

  // ignore: unnecessary_getters_setters
  bool get hasReminder => _reminder;

  String get link => 'https://www.nyx.cz/index.php?l=topic;id=${this.idKlub};wu=${this.id}';

  // ignore: unnecessary_getters_setters
  set hasReminder(bool value) => _reminder = value;
}
