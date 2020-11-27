import 'package:fyx/model/System.dart';

class FeedNoticesResponse {
  List<NoticeItem> _data = [];
  System _system;
  int lastVisit;

  List<NoticeItem> get data => _data;

  set data(List<NoticeItem> data) => _data = data;

  System get system => _system;

  set system(System system) => _system = system;

  FeedNoticesResponse.fromJson(Map<String, dynamic> json) {
    _data = List();
    json['data']['items'].forEach((v) {
      _data.add(new NoticeItem.fromJson(v));
    });
    _system = json['system'] != null ? new System.fromJson(json['system']) : null;
    lastVisit = int.parse(json['data']['notice_last_visit']);
  }
}

class NoticeItem {
  String _section;
  int _idWu;
  int _idKlub;
  String _nick;
  int _time;
  int _wuRating;
  String _content;
  List<NoticeReplies> _replies;
  List<NoticeThumbsUp> _thumbsUp;

  NoticeItem({String section, int idWu, int idKlub, String nick, int time, int wuRating, String content, List<NoticeReplies> replies, List<NoticeThumbsUp> thumbsUp}) {
    this._section = section;
    this._idWu = idWu;
    this._idKlub = idKlub;
    this._nick = nick;
    this._time = time;
    this._wuRating = wuRating;
    this._content = content;
    this._replies = replies;
    this._thumbsUp = thumbsUp;
  }

  String get section => _section;

  set section(String section) => _section = section;

  int get idWu => _idWu;

  set idWu(int idWu) => _idWu = idWu;

  int get idKlub => _idKlub;

  set idKlub(int idKlub) => _idKlub = idKlub;

  String get nick => _nick;

  set nick(String nick) => _nick = nick;

  int get time => _time;

  set time(int time) => _time = time;

  int get wuRating => _wuRating;

  set wuRating(int wuRating) => _wuRating = wuRating;

  String get content => _content;

  set content(String content) => _content = content;

  List<NoticeReplies> get replies => _replies;

  set replies(List<NoticeReplies> replies) => _replies = replies;

  List<NoticeThumbsUp> get thumbsUp => _thumbsUp;

  set thumbsUp(List<NoticeThumbsUp> thumbsUp) => _thumbsUp = thumbsUp;

  NoticeItem.fromJson(Map<String, dynamic> json) {
    _section = json['section'];
    _idWu = int.parse(json['id_wu']);
    _idKlub = int.parse(json['id_klub']);
    _nick = json['nick'];
    _time = int.parse(json['time']);
    _wuRating = int.parse(json['wu_rating']);
    _content = json['content'];

    _replies = new List<NoticeReplies>();
    if (json['replies'] != null) {
      json['replies'].forEach((v) {
        _replies.add(new NoticeReplies.fromJson(v));
      });
    }

    _thumbsUp = new List<NoticeThumbsUp>();
    if (json['thumbs_up'] != null) {
      json['thumbs_up'].forEach((v) {
        _thumbsUp.add(new NoticeThumbsUp.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['section'] = this._section;
    data['id_wu'] = this._idWu;
    data['id_klub'] = this._idKlub;
    data['nick'] = this._nick;
    data['time'] = this._time;
    data['wu_rating'] = this._wuRating;
    data['content'] = this._content;
    if (this._replies != null) {
      data['replies'] = this._replies.map((v) => v.toJson()).toList();
    }
    if (this._thumbsUp != null) {
      data['thumbs_up'] = this._thumbsUp.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NoticeReplies {
  String _nick;
  int _time;
  String _idWu;
  String _idKlub;
  String _text;

  NoticeReplies({String nick, int time, String idWu, String idKlub, String text}) {
    this._nick = nick;
    this._time = time;
    this._idWu = idWu;
    this._idKlub = idKlub;
    this._text = text;
  }

  String get nick => _nick;

  set nick(String nick) => _nick = nick;

  int get time => _time;

  set time(int time) => _time = time;

  String get idWu => _idWu;

  set idWu(String idWu) => _idWu = idWu;

  String get idKlub => _idKlub;

  set idKlub(String idKlub) => _idKlub = idKlub;

  String get text => _text;

  set text(String text) => _text = text;

  NoticeReplies.fromJson(Map<String, dynamic> json) {
    _nick = json['nick'];
    _time = int.parse(json['time']);
    _idWu = json['id_wu'];
    _idKlub = json['id_klub'];
    _text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nick'] = this._nick;
    data['time'] = this._time;
    data['id_wu'] = this._idWu;
    data['id_klub'] = this._idKlub;
    data['text'] = this._text;
    return data;
  }
}

class NoticeThumbsUp {
  String _nick;
  int _time;

  NoticeThumbsUp({String nick, int time}) {
    this._nick = nick;
    this._time = time;
  }

  String get nick => _nick;

  set nick(String nick) => _nick = nick;

  int get time => _time;

  set time(int time) => _time = time;

  NoticeThumbsUp.fromJson(Map<String, dynamic> json) {
    _nick = json['nick'];
    _time = int.parse(json['time']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nick'] = this._nick;
    data['time'] = this._time;
    return data;
  }
}
