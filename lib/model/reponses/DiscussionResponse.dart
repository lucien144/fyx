import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/ResponseContext.dart';

class DiscussionResponse {
  late final Discussion discussion; // TODO: Rename this to DiscussionCommon
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

}
