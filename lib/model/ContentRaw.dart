import 'package:fyx/exceptions/UnsupportedContentTypeException.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/post/content/Dice.dart';
import 'package:fyx/model/post/content/Poll.dart';
import 'package:fyx/model/post/content/post_content_text.dart';

class ContentRaw {
  late Map<String, dynamic> data;
  late String type; // TODO: Change to enum
  late Content content;

  ContentRaw.fromJson({required Map<String, dynamic> json, int? discussionId, int? postId}) {
    this.data = json['data'] as Map<String, dynamic>;
    this.type = json['type'] ?? '';

    switch (this.type) {
      case 'text':
        this.content = PostContentText.fromJson(this.data);
        break;
      case 'poll':
        this.content = ContentPoll.fromJson(this.data, discussionId: discussionId ?? 0, postId: postId ?? 0);
        break;
      case 'dice':
        this.content = ContentDice.fromJson(this.data, discussionId: discussionId ?? 0, postId: postId ?? 0);
        break;
      case 'advertisement':
        this.content = ContentAdvertisement.fromPostJson(this.data);
        break;
      default:
        throw UnsupportedContentTypeException(this.type);
    }
    //TODO handle other cases
  }
}
