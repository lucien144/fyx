import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/mail/domain/entities/mail.dart';
import 'package:fyx/features/mail/domain/enums/mail_status.dart';
import 'package:fyx/model/Active.dart';
import 'package:fyx/model/post/content/Regular.dart';

part 'mail_model.freezed.dart';

/// Data model mapping a raw mail JSON payload to the [Mail] domain entity.
@freezed
class MailModel with _$MailModel {
  const MailModel._();

  const factory MailModel({
    required int id,
    required String username,
    required int time,
    required bool incoming,
    required MailStatus status,
    required bool isNew,
    required ContentRegular content,
    Active? active,
  }) = _MailModel;

  factory MailModel.fromJson(Map<String, dynamic> json, {bool isCompact = false}) {
    final content = ContentRegular(json['content'], isCompact: isCompact);
    // Turn raw e-mail addresses and phone numbers into tappable links up-front
    // so the resulting entity is ready to render.
    content.parseEmailAddresses();
    content.parsePhoneNumbers();

    return MailModel(
      id: json['id'],
      username: json['username'],
      time: DateTime.parse(json['inserted_at'] ?? '0').millisecondsSinceEpoch,
      incoming: json['incoming'] ?? false,
      status: json['unread'] == null ? MailStatus.unknown : (json['unread'] ? MailStatus.unread : MailStatus.read),
      isNew: json['new'] ?? false,
      content: content,
      active: json['activity'] == null ? null : Active.fromJson(json['activity']),
    );
  }

  Mail toEntity() => Mail(
        id: id,
        username: username,
        time: time,
        incoming: incoming,
        status: status,
        isNew: isNew,
        content: content,
        active: active,
      );
}
