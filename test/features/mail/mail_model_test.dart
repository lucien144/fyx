import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/domain/enums/mail_direction.dart';
import 'package:fyx/features/mail/domain/enums/mail_status.dart';

void main() {
  Map<String, dynamic> baseJson() => {
        'id': 42,
        'username': 'hypnogen',
        'inserted_at': '2015-03-08T22:36:07',
        'incoming': true,
        'unread': true,
        'new': true,
        'content': 'Ahoj, napiš na <a href="#">x</a>',
      };

  test('Maps an incoming unread mail to the entity', () {
    final mail = MailModel.fromJson(baseJson()).toEntity();

    expect(mail.id, 42);
    expect(mail.username, 'hypnogen');
    expect(mail.nick, 'HYPNOGEN', reason: 'nick is uppercased');
    expect(mail.participant, 'HYPNOGEN');
    expect(mail.time, DateTime.parse('2015-03-08T22:36:07').millisecondsSinceEpoch);
    expect(mail.direction, MailDirection.from);
    expect(mail.isIncoming, true);
    expect(mail.isOutgoing, false);
    expect(mail.status, MailStatus.unread);
    expect(mail.isUnread, true);
    expect(mail.isNew, true);
    expect(mail.link, 'https://www.nyx.cz/mail/id/42');
    expect(mail.active, isNull);
  });

  test('Maps an outgoing read mail', () {
    final json = baseJson()
      ..['incoming'] = false
      ..['unread'] = false;

    final mail = MailModel.fromJson(json).toEntity();

    expect(mail.direction, MailDirection.to);
    expect(mail.isOutgoing, true);
    expect(mail.status, MailStatus.read);
    expect(mail.isUnread, false);
  });

  test('Missing unread flag maps to unknown status', () {
    final json = baseJson()..remove('unread');

    final mail = MailModel.fromJson(json).toEntity();

    expect(mail.status, MailStatus.unknown);
    expect(mail.isUnread, false);
  });

  test('Parses the activity payload into Active', () {
    final json = baseJson()
      ..['activity'] = {
        'last_activity': '2015-03-08T23:00:00',
        'location': 'Praha',
        'location_url': 'https://nyx.cz/praha',
      };

    final mail = MailModel.fromJson(json).toEntity();

    expect(mail.active, isNotNull);
    expect(mail.active!.location, 'Praha');
    expect(mail.active!.url, 'https://nyx.cz/praha');
  });

  test('Content is parsed and renders as stripped text', () {
    final mail = MailModel.fromJson(baseJson()).toEntity();

    expect(mail.content.strippedContent.contains('Ahoj'), true);
  });
}
