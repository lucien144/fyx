class DiscussionCommonBookmark {
  late int discussionId;
  late bool bookmark;
  int? categoryId;
  int repliesCount = 0;
  int lastSeenPostId = 0;
  int lastSeenPostsCount = 0;
  int lastSeenImagePostsCount = 0;
  int lastSeenLinkPostsCount = 0;
  int lastVisitedAt = 0;

  DiscussionCommonBookmark.fromJson(Map<String, dynamic> json) {
    discussionId = json['discussion_id'];
    bookmark = json['bookmark'];
    categoryId = json['category_id'];
    repliesCount = json['replies_count'] ?? 0;
    lastSeenPostId = json['last_seen_post_id'] ?? 0;
    lastSeenPostsCount = json['last_seen_posts_count'] ?? 0;
    lastSeenImagePostsCount = json['last_seen_image_posts_count'] ?? 0;
    lastSeenLinkPostsCount = json['last_seen_link_posts_count'] ?? 0;
    try {
      lastVisitedAt = DateTime.parse(json['last_visited_at']).millisecondsSinceEpoch;
    } catch (error) {
      lastVisitedAt = 0;
    }
  }
}
