import 'package:fyx/model/reponses/FeedNoticesResponse.dart';

class PostThumbItem {
  late String username;
  late bool isHighlighted;

  PostThumbItem(this.username, {this.isHighlighted = false});

  PostThumbItem.fromNoticeThumbsUp(NoticeThumbsUp thumb, int lastVisit) {
    this.username = thumb.nick;
    this.isHighlighted = thumb.time > lastVisit;
  }
}
