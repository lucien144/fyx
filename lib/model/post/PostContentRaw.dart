import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/PostContentPoll.dart';

class PostContentRaw {
  PostTypeEnum type;
  dynamic data;

  PostContentRaw.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'poll':
        this.type = PostTypeEnum.poll;
        this.data = PostContentPoll.fromJson(json['data']);
        break;
      case 'dice':
        this.type = PostTypeEnum.dice;
        break;
      default:
        this.type = PostTypeEnum.text;
        break;
    }
  }
}
