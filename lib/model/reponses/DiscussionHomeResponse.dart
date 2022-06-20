import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/DiscussionContent.dart';
import 'package:fyx/model/ResponseContext.dart';

class DiscussionHomeResponse {
  late final Discussion discussion;
  late final ResponseContext context;
  late final List<DiscussionContent> items;

  DiscussionHomeResponse.fromJson(Map<String, dynamic> json) {
    this.discussion = Discussion.fromJson(json['discussion_common']);
    this.context = ResponseContext.fromJson(json['context']);
    this.items = (json['items'] as List).map((item) => DiscussionContent.fromJson(item)).toList();
  }
}
