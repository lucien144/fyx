import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/DiscussionContent.dart';
import 'package:fyx/model/ResponseContext.dart';
import 'package:fyx/model/enums/DiscussionTypeEnum.dart';

enum DiscussionSpecificDataEnum { header }

class DiscussionResponse {
  late final Discussion discussion; // TODO: Rename this to DiscussionCommon
  Map<DiscussionSpecificDataEnum, List<DiscussionContent>>? discussionSpecificData;
  late final List posts;
  ResponseContext? context;

  DiscussionResponse.accessDenied() {
    this.discussion = Discussion.fromJson(null);
    this.posts = [];
  }

  // TODO: Return something more relevant.
  DiscussionResponse.error() {
    DiscussionResponse.accessDenied();
  }

  DiscussionResponse.fromJson(Map<String, dynamic> json) {
    this.discussion = Discussion.fromJson(json['discussion_common']);
    this.posts = json['posts'] ?? [];
    this.context = ResponseContext.fromJson(json['context']);

    switch (this.discussion.type) {
      case DiscussionTypeEnum.discussion:
        this.discussionSpecificData = {
          DiscussionSpecificDataEnum.header:
              List.from(json['discussion_common']['discussion_specific_data']['header']).map((item) => DiscussionContent.fromJson(item)).toList()
        };
        break;
      case DiscussionTypeEnum.event:
        // TODO: Handle this case.
        break;
      case DiscussionTypeEnum.advertisement:
        // TODO: Handle this case.
        break;
    }
  }
}
