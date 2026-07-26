import 'package:fyx/model/post/Content.dart';

abstract class IPost {
  Content get content;

  String get nick;

  String get link;

  int get id;
}
