import 'package:fyx/features/mail/domain/entities/mail.dart';

/// A page of mails together with the id to continue pagination from.
class MailPage {
  final List<Mail> mails;

  /// Id to pass as `lastId` when loading the next page. Falls back to the
  /// previous cursor when the page came back empty.
  final int? lastId;

  const MailPage({required this.mails, this.lastId});
}

/// Repository for loading the user's mailbox.
abstract class MailRepository {
  /// Load a page of mails, optionally continuing after [lastId] or filtered
  /// by [search]. [isCompact] controls how the message content is parsed.
  Future<MailPage> getMails({int? lastId, String? search, bool isCompact = false});
}
