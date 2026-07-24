// coverage:ignore-file
// GENERATED CODE - MANUAL FREEZED STUB
part of 'mail_page_entity.dart';

mixin _$MailPageEntity {
  List<MailEntity> get mails;
  int? get nextLastId;
}

class _MailPageEntity implements MailPageEntity {
  const _MailPageEntity({required this.mails, required this.nextLastId});

  @override
  final List<MailEntity> mails;
  @override
  final int? nextLastId;

  @override
  String toString() => 'MailPageEntity(mails: ${mails.length}, nextLastId: $nextLastId)';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is _MailPageEntity && other.nextLastId == nextLastId && other.mails == mails);

  @override
  int get hashCode => Object.hash(mails, nextLastId);
}
