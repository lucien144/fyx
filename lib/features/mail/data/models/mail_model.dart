import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/mail/domain/entities/mail_entity.dart';
import 'package:fyx/model/Mail.dart';

part 'mail_model.freezed.dart';

@freezed
class MailModel with _$MailModel {
  const MailModel._();

  const factory MailModel({
    required int id,
    required String participant,
    required DateTime insertedAt,
    required bool isIncoming,
    required bool isUnread,
    required bool isNew,
    required String content,
    Map<String, dynamic>? activity,
  }) = _MailModel;

  factory MailModel.fromApiJson(Map<String, dynamic> json) {
    return MailModel(
      id: json['id'] as int,
      participant: (json['username'] as String? ?? '').toUpperCase(),
      insertedAt: DateTime.tryParse(json['inserted_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isIncoming: json['incoming'] as bool? ?? false,
      isUnread: json['unread'] as bool? ?? false,
      isNew: json['new'] as bool? ?? false,
      content: json['content'] as String? ?? '',
      activity: (json['activity'] as Map?)?.cast<String, dynamic>(),
    );
  }

  MailEntity toEntity() {
    return MailEntity(
      id: id,
      participant: participant,
      insertedAt: insertedAt,
      isIncoming: isIncoming,
      isUnread: isUnread,
      isNew: isNew,
      content: content,
      activity: activity,
    );
  }

  Mail toLegacyMail({required bool isCompact}) {
    return Mail.fromJson(
      {
        'id': id,
        'username': participant,
        'inserted_at': insertedAt.toIso8601String(),
        'incoming': isIncoming,
        'unread': isUnread,
        'new': isNew,
        'content': content,
        'activity': activity,
      },
      isCompact: isCompact,
    );
  }
}
