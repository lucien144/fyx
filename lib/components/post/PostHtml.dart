import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/model/Post.dart';

class PostHtml extends StatelessWidget {
  final Post post;

  PostHtml(this.post);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: post.content,
    );
  }
}
