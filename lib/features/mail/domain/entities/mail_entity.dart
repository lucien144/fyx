import 'package:freezed_annotation/freezed_annotation.dart';

part 'mail_entity.freezed.dart';

@freezed
class MailEntity with _$MailEntity {
  const factory MailEntity({
    required int id,
    required String participant,
    required DateTime insertedAt,
    required bool isIncoming,
    required bool isUnread,
    required bool isNew,
    required String content,
    Map<String, dynamic>? activity,
  }) = _MailEntity;
}
