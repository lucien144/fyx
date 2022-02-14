import 'package:fyx/model/enums/TagTypeEnum.dart';
import 'package:fyx/model/post/DiscussionPostTagWithName.dart';

class PostRatingsResponse {
  late List<DiscussionPostTagWithName> data;
  late List<DiscussionPostTagWithName> positive = [];
  late List<DiscussionPostTagWithName> negative = [];

  PostRatingsResponse.fromJson(List<dynamic> json) {
    data = json.map((item) => DiscussionPostTagWithName.fromJson(item)).toList();
    positive = data.where((element) => element.tag == TagTypeEnum.positive).toList();
    negative = data.where((element) => element.tag == TagTypeEnum.negative).toList();
  }
}
