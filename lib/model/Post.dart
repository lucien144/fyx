// ignore_for_file: non_constant_identifier_names
import 'package:fyx/model/ContentRaw.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/model/post/ipost.dart';
import 'package:fyx/theme/Helpers.dart';

class Post extends IPost {
  // TODO: Refactor all params to follow names from the new API like _id_wu -> id ...
  final bool isCompact;
  bool _canReply = true;
  bool _isNew = false;
  int idKlub = 0;
  int _id_wu = 0;
  String _nick = '';
  int _time = 0;
  int? rating;
  List<int> replies = [];
  String _wu_type = '';
  String myRating = '';
  bool _reminder = false;
  bool _canBeRated = false;
  bool _canBeDeleted = false;
  bool _canBeReminded = false;

  String? discussionName;

  Post.fromJson(Map<String, dynamic> json, this.idKlub, {this.isCompact = false}) {
    this._id_wu = json['id'] ?? 0;
    this._nick = json['username'] ?? '';
    this.discussionName = json['discussion_name'];
    this._time = DateTime.parse(json['inserted_at'] ?? '0').millisecondsSinceEpoch;
    this.rating = json['rating'];
    this.replies = List<int>.from(json['replies'] ?? []);
    this._wu_type = json['type'] ?? '';
    this._isNew = json['new'] ?? false;
    this.myRating = json['my_rating'] ?? 'none'; // positive / negative / negative_visible / none TODO: enums
    this._reminder = json['reminder'] ?? false;
    this._canBeRated = json['can_be_rated'] ?? false;
    this._canBeDeleted = json['can_be_deleted'] ?? false;
    this._canBeReminded = json['can_be_reminded'] ?? false;

    if (json['content_raw'] != null && json['content_raw']['data'] != null && !json['content_raw']['data'].containsKey('DiscussionWelcome')) {
      try {
        content = ContentRaw.fromJson(json: json['content_raw'], discussionId: json['discussion_id'], postId: json['id']).content;
        this._canReply = !(content is ContentAdvertisement);
      } catch (error) {
        content = ContentRegular('${json['content']}<br><br><small><em>Chyba: neošetřený druh příspěvku: "${this.type}"</em></small>',
            isCompact: this.isCompact);
      }
    } else {
      content = ContentRegular(json['content'], isCompact: this.isCompact);
    }
  }

  static String formatRating(int _rating) {
    if (_rating == 0) {
      return '±$_rating';
    } else if (_rating < 0) {
      return _rating.toString();
    }
    return '+$_rating';
  }

  String get type => _wu_type;

  int get time => _time;

  String get avatar => Helpers.avatarUrl(nick);

  String get nick => _nick.toUpperCase();

  int get id => _id_wu;

  // ignore: unnecessary_getters_setters
  bool get hasReminder => _reminder;

  bool get isNew => _isNew;

  String get link => 'https://nyx.cz/discussion/${this.idKlub}/id/${this.id}';

  // ignore: unnecessary_getters_setters
  set hasReminder(bool value) => _reminder = value;

  bool get canBeReminded => _canBeReminded;

  bool get canBeDeleted => _canBeDeleted;

  bool get canBeRated => _canBeRated;

  bool get canReply => _canReply;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
