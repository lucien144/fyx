// ignore_for_file: non_constant_identifier_names
import 'package:fyx/model/Active.dart';
import 'package:fyx/model/post/Content.dart';

enum MailDirection { from, to }
enum MailStatus { read, unread, unknown }

class Mail {
  final bool isCompact;
  int _id_mail;
  String _other_nick;
  int _time;
  bool _direction;
  Content _content;
  MailStatus _message_status;
  bool _new;
  Map<String, dynamic> _active;

  Mail.fromJson(Map<String, dynamic> json, {this.isCompact}) {
    _id_mail = json['id'];
    _other_nick = json['username'];
    _time = DateTime.parse(json['inserted_at'] ?? '0').millisecondsSinceEpoch;
    _direction = json['incoming'] ?? false;
    _content = Content(json['content'], isCompact: this.isCompact);
    _message_status = (json['unread'] ?? false) ? MailStatus.unread : MailStatus.read;
    _new = json['new'] ?? false;
    _active = json['activity'];
  }

  bool get isUnread => status == MailStatus.unread;

  bool get isNew => _new;

  Active get active => _active == null ? null : Active.fromJson(_active);

  MailStatus get status => _message_status;

  Content get content => _content;

  MailDirection get direction => _direction ? MailDirection.from : MailDirection.from;

  int get time => _time;

  String get participant => _other_nick;

  int get id => _id_mail;

  String get link => 'https://www.nyx.cz/index.php?l=mail;wu=${this.id}';
}
