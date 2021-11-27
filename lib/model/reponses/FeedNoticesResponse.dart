import 'package:fyx/model/ResponseContext.dart';

class FeedNoticesResponse {
  List<NoticeItem> _data = [];
  int lastVisit = 0;
  late ResponseContext _context;

  List<NoticeItem> get data => _data;

  set data(List<NoticeItem> data) => _data = data;

  ResponseContext get context => _context;

  FeedNoticesResponse.fromJson(Map<String, dynamic> json) {
    json['notifications'].forEach((v) {
      _data.add(new NoticeItem.fromJson(v));
    });
    _context = ResponseContext.fromJson(json['context']);
    lastVisit = DateTime.parse(json['context']['user']['notifications_last_visit'] ?? '0').millisecondsSinceEpoch;
  }
}

class NoticeItem {
  int _domain_id = 0;
  int _id = 0;
  int _discussion_id = 0;
  String _discussion_name = '';
  String _username = '';
  String _post_type = '';
  bool _reminder = false;
  int _inserted_at = 0;
  int _rating = 0;
  String _content = '';
  List<NoticeReplies> _replies = [];
  List<NoticeThumbsUp> _thumbsUp = [];

  int get domainId => _domain_id;

  int get idWu => _id;

  int get idKlub => _discussion_id;

  String get discussionName => _discussion_name;

  String get nick => _username;

  int get time => _inserted_at;

  int get wuRating => _rating;

  bool get reminder => _reminder;

  String get postType => _post_type;

  String get content => _content;

  List<NoticeReplies> get replies => _replies;

  List<NoticeThumbsUp> get thumbsUp => _thumbsUp;

  set thumbsUp(List<NoticeThumbsUp> thumbsUp) => _thumbsUp = thumbsUp;

  NoticeItem.fromJson(Map<String, dynamic> json) {
    _domain_id = json['data']['domain_id'] ?? 0;
    _id = json['data']['id'] ?? 0;
    _discussion_id = json['data']['discussion_id'] ?? 0;
    _discussion_name = json['data']['discussion_name'] ?? '';
    _username = json['data']['username'] ?? '';
    _inserted_at = DateTime.parse(json['data']['inserted_at'] ?? '0').millisecondsSinceEpoch;;
    _rating = json['data']['rating'] ?? 0;
    _content = json['data']['content'] ?? '';
    _post_type = json['data']['post_type'] ?? '';
    _reminder = json['data']['reminder'] ?? false;

    if (json['details']['replies'] != null) {
      json['details']['replies'].forEach((v) {
        _replies.add(new NoticeReplies.fromJson(v));
      });
    }

    if (json['details']['thumbs_up'] != null) {
      json['details']['thumbs_up'].forEach((v) {
        _thumbsUp.add(new NoticeThumbsUp.fromJson(v));
      });
    }
  }
}

class NoticeReplies {
  String _username = '';
  int _inserted_at = 0;
  int _id = 0;
  int _discussion_id = 0;
  String _content = '';

  String get nick => _username;

  int get time => _inserted_at;

  int get idWu => _id;

  int get idKlub => _discussion_id;

  String get text => _content;

  NoticeReplies.fromJson(Map<String, dynamic> json) {
    this._username = json['username'] ?? '';
    this._inserted_at = DateTime.parse(json['inserted_at'] ?? '0').millisecondsSinceEpoch;
    this._id = json['id'] ?? 0;
    this._discussion_id = json['discussion_id'] ?? 0;
    this._content = json['content'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nick'] = this._username;
    data['time'] = this._inserted_at;
    data['id_wu'] = this._id;
    data['id_klub'] = this._discussion_id;
    data['text'] = this._content;
    return data;
  }
}

class NoticeThumbsUp {
  String _username = '';
  int _inserted_at = 0;

  String get nick => _username;

  int get time => _inserted_at;

  NoticeThumbsUp.fromJson(Map<String, dynamic> json) {
    this._username = json['username'];
    this._inserted_at = DateTime.parse(json['inserted_at'] ?? '0').millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nick'] = this._username;
    data['time'] = this._inserted_at;
    return data;
  }
}
