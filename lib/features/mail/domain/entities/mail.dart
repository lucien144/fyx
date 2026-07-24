import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/mail/domain/enums/mail_direction.dart';
import 'package:fyx/features/mail/domain/enums/mail_status.dart';
import 'package:fyx/model/Active.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/model/post/ipost.dart';

part 'mail.freezed.dart';

/// Domain entity representing a single mail message.
///
/// Implements [IPost] so it can be handled polymorphically alongside posts
/// (e.g. in the shared post context menu). [content] is kept as a parsed
/// [ContentRegular] so the presentation layer can render it directly.
@freezed
class Mail with _$Mail implements IPost {
  const Mail._();

  const factory Mail({
    required int id,
    required String username,
    required int time,
    required bool incoming,
    required MailStatus status,
    required bool isNew,
    required ContentRegular content,
    Active? active,
  }) = _Mail;

  @override
  String get nick => username.toUpperCase();

  /// The other party of the conversation (same as [nick]).
  String get participant => username.toUpperCase();

  @override
  String get link => 'https://www.nyx.cz/mail/id/$id';

  MailDirection get direction => incoming ? MailDirection.from : MailDirection.to;

  bool get isUnread => status == MailStatus.unread;

  bool get isIncoming => incoming;

  bool get isOutgoing => !incoming;
}
