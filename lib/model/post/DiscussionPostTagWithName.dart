import 'package:fyx/model/enums/TagTypeEnum.dart';

class DiscussionPostTagWithName {
  late String username;
  late TagTypeEnum tag;

  DiscussionPostTagWithName({required this.username, required this.tag});

  DiscussionPostTagWithName.fromJson(Map<String, dynamic> json) {
    this.username = json['username'];
    this.tag = TagTypeEnum.values.firstWhere((e) => e.toString() == 'TagTypeEnum.${json['tag']}');
  }
}
