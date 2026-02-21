/// Enum representing types of global statistics
enum GlobalStatType {
  totalScrollPx('total_scroll_px'),
  likes('likes'),
  dislikes('dislikes'),
  postsCreated('posts_created'),
  postReplies('post_replies'),
  postsLength('posts_length'),
  postAttachments('post_attachments'),
  mailsCreated('mails_created'),
  mailsLength('mails_length'),
  mailAttachments('mail_attachments');

  final String value;

  const GlobalStatType(this.value);

  /// Create StatType from string value
  static GlobalStatType? fromValue(String value) {
    return GlobalStatType.values.where((e) => e.value == value).firstOrNull;
  }
}
