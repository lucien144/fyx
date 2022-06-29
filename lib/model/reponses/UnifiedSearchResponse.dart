enum UnifiedSearchType { discussions, events, advertisements }

class UnifiedSearchResponse {
  late Map<UnifiedSearchType, List<UnifiedDiscussionModel>> discussion;

  UnifiedSearchResponse(this.discussion);

  UnifiedSearchResponse.fromJson(Map<String, dynamic> json) {
    this.discussion = {
      UnifiedSearchType.discussions: (json['discussion']['discussions'] as List).map((item) => UnifiedDiscussionModel.fromJson(item)).toList(),
      UnifiedSearchType.events: (json['discussion']['events'] as List).map((item) => UnifiedDiscussionModel.fromJson(item)).toList(),
      UnifiedSearchType.advertisements: (json['discussion']['advertisements'] as List).map((item) => UnifiedDiscussionModel.fromJson(item)).toList(),
    };
  }
}

class UnifiedDiscussionModel {
  late int id;
  late String discussionType;
  late String discussionName;
  late String discussionNameHighlighted;
  late String summary;
  late String summaryHighlighted;

  UnifiedDiscussionModel(
      {required this.id,
      required this.discussionType,
      required this.discussionName,
      this.discussionNameHighlighted = '',
      this.summary = '',
      this.summaryHighlighted = ''});

  UnifiedDiscussionModel.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.discussionType = json['discussion_type'];
    this.discussionName = json['discussion_name'];
    this.discussionNameHighlighted = json['discussion_name_highlighted'] ?? '';
    this.summary = json['summary'] ?? '';
    this.summaryHighlighted = json['summary_highlighted'] ?? '';
  }
}
