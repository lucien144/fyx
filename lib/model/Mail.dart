// ignore_for_file: non_constant_identifier_names
import 'package:fyx/model/Active.dart';

enum MailDirection { from, to }
enum MailStatus { read, unread, unknown }

class Mail {
  int _id_mail;
  String _other_nick;
  int _time;
  String _direction;
  String _content;
  String _message_status;
  Map<String, dynamic> _active;

  Mail.fromJson(Map<String, dynamic> json) {
    _id_mail = int.parse(json['id_mail']);
    _other_nick = json['other_nick'];
    _time = int.parse(json['time']);
    _direction = json['direction'];
    _content = json['content'];
    _message_status = (json['message_status'] ?? 'unknown');
    _active = json['active'];
  }

  Active get active => _active == null ? null : Active.fromJson(_active);

  MailStatus get status => MailStatus.values.firstWhere((MailStatus s) => s.toString() == 'MailStatus.$status');

  String get content => _content;

  MailDirection get direction => _direction == 'from' ? MailDirection.from : MailDirection.to;

  int get time => _time;

  String get participant => _other_nick;

  int get id => _id_mail;
}
