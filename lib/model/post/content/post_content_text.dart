import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';

enum ContentFormat { text, html, markdown }

class PostContentText extends Content {
  late final String data;
  late final ContentFormat format;

  PostContentText.fromJson(Map<String, dynamic> json) : super(PostTypeEnum.text, isCompact: false) {
    this.data = json['data'] ?? '';
    this.format = ContentFormat.values.firstWhere((value) => value.toString().contains(json['format']));
  }
}
