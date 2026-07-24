import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/domain/entities/mail_page_entity.dart';

part 'mail_page_model.freezed.dart';

@freezed
class MailPageModel with _$MailPageModel {
  const MailPageModel._();

  const factory MailPageModel({
    required List<MailModel> mails,
    required int? nextLastId,
  }) = _MailPageModel;

  MailPageEntity toEntity() {
    return MailPageEntity(
      mails: mails.map((mail) => mail.toEntity()).toList(growable: false),
      nextLastId: nextLastId,
    );
  }
}
