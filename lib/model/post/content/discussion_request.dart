import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';

class ContentDiscussionRequest extends Content {
  int parentPostId;
  int parentDiscussionId;
  int? id;
  int? domainId;
  int? domainCategoryId;
  String? categoryPath;
  String? ownerUsername;
  String? nameStatic;
  String? summary;
  String? similarDiscussions;
  int? discussionId;
  bool? cancelled;
  bool? canVote;
  bool? canConfirm;
  ComputedValues? computedValues;


  ContentDiscussionRequest.fromJson(Map<String, dynamic> json, {bool isCompact = false, required this.parentPostId, required this.parentDiscussionId}) : super(PostTypeEnum.discussion_request, isCompact: isCompact) {
    id = json['id'];
    domainId = json['domain_id'];
    domainCategoryId = json['domain_category_id'];
    categoryPath = json['category_path'];
    ownerUsername = json['owner_username'];
    nameStatic = json['name_static'];
    summary = json['summary'];
    similarDiscussions = json['similar_discussions'];
    discussionId = json['discussion_id'];
    cancelled = json['cancelled'];
    canVote = json['can_vote'];
    canConfirm = json['can_confirm'];
    computedValues = json['computed_values'] != null ? new ComputedValues.fromJson(json['computed_values']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['domain_id'] = this.domainId;
    data['domain_category_id'] = this.domainCategoryId;
    data['category_path'] = this.categoryPath;
    data['owner_username'] = this.ownerUsername;
    data['name_static'] = this.nameStatic;
    data['summary'] = this.summary;
    data['similar_discussions'] = this.similarDiscussions;
    data['discussion_id'] = this.discussionId;
    data['cancelled'] = this.cancelled;
    data['can_vote'] = this.canVote;
    data['can_confirm'] = this.canConfirm;
    if (this.computedValues != null) {
      data['computed_values'] = this.computedValues!.toJson();
    }
    return data;
  }
}

class ComputedValues {
  int? votersPositiveTotal;
  int? votersNegativeTotal;

  ComputedValues({this.votersPositiveTotal, this.votersNegativeTotal});

  ComputedValues.fromJson(Map<String, dynamic> json) {
    votersPositiveTotal = json['voters_positive_total'];
    votersNegativeTotal = json['voters_negative_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voters_positive_total'] = this.votersPositiveTotal;
    data['voters_negative_total'] = this.votersNegativeTotal;
    return data;
  }
}
