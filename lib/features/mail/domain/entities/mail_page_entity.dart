import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/mail/domain/entities/mail_entity.dart';

part 'mail_page_entity.freezed.dart';

@freezed
class MailPageEntity with _$MailPageEntity {
  const factory MailPageEntity({
    required List<MailEntity> mails,
    required int? nextLastId,
  }) = _MailPageEntity;
}
