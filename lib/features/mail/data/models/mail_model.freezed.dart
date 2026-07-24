// coverage:ignore-file
// GENERATED CODE - MANUAL FREEZED STUB
part of 'mail_model.dart';

mixin _$MailModel {
  int get id;
  String get participant;
  DateTime get insertedAt;
  bool get isIncoming;
  bool get isUnread;
  bool get isNew;
  String get content;
  Map<String, dynamic>? get activity;
}

class _MailModel extends MailModel {
  const _MailModel({
    required this.id,
    required this.participant,
    required this.insertedAt,
    required this.isIncoming,
    required this.isUnread,
    required this.isNew,
    required this.content,
    this.activity,
  }) : super._();

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
}
