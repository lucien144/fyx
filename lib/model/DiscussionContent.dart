import 'package:fyx/model/ContentRaw.dart';
import 'package:fyx/model/enums/PostTypeEnum.dart';

enum DiscussionContentLocationEnum { home, header, archive }

class DiscussionContent {
  late final int id;
  late final int discussionId;
  late final DiscussionContentLocationEnum location;
  late final int sortOrder;
  late final String? content;
  late final ContentRaw contentRaw;
  late final PostTypeEnum postType;

  DiscussionContent.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.discussionId = json['discussion_id'];
    this.location = DiscussionContentLocationEnum.values.firstWhere((value) => value.toString().contains(json['location']));
    this.sortOrder = json['sort_order'];
    this.content = json['content'] ?? '';
    this.contentRaw = ContentRaw.fromJson(json: json['content_raw']);
    this.postType = PostTypeEnum.values.firstWhere((value) => value.toString().contains(json['post_type']));
  }
}
