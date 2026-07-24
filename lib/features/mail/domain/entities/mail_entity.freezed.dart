// coverage:ignore-file
// GENERATED CODE - MANUAL FREEZED STUB
part of 'mail_entity.dart';

mixin _$MailEntity {
  int get id;
  String get participant;
  DateTime get insertedAt;
  bool get isIncoming;
  bool get isUnread;
  bool get isNew;
  String get content;
  Map<String, dynamic>? get activity;
}

class _MailEntity implements MailEntity {
  const _MailEntity({
    required this.id,
    required this.participant,
    required this.insertedAt,
    required this.isIncoming,
    required this.isUnread,
    required this.isNew,
    required this.content,
    this.activity,
  });

  @override
  final int id;
  @override
  final String participant;
  @override
  final DateTime insertedAt;
  @override
  final bool isIncoming;
  @override
  final bool isUnread;
  @override
  final bool isNew;
  @override
  final String content;
  @override
  final Map<String, dynamic>? activity;

  @override
  String toString() => 'MailEntity(id: $id, participant: $participant, insertedAt: $insertedAt, isIncoming: $isIncoming, isUnread: $isUnread, isNew: $isNew)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _MailEntity &&
            other.id == id &&
            other.participant == participant &&
            other.insertedAt == insertedAt &&
            other.isIncoming == isIncoming &&
            other.isUnread == isUnread &&
            other.isNew == isNew &&
            other.content == content);
  }

  @override
  int get hashCode => Object.hash(id, participant, insertedAt, isIncoming, isUnread, isNew, content);
}
