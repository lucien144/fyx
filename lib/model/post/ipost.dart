import 'package:fyx/model/post/Content.dart';

abstract class IPost {
  late Content content;

  String get nick;

  String get link;

  int get id;
}
