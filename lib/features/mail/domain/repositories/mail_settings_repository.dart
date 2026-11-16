/// User's preferences for the mailbox.
abstract class MailSettingsRepository {
  /// The whole mailbox is marked as NSFW; attachments in mails are blurred.
  bool get isNsfw;

  set isNsfw(bool value);
}
