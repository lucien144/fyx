import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/discussion_request_buttons.dart';
import 'package:fyx/components/post/post_html.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/model/post/content/discussion_request.dart';

class PostDiscussionRequest extends StatelessWidget {
  final ContentDiscussionRequest content;

  const PostDiscussionRequest({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Název', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          if (this.content.discussionId != null)
            PostHtml(ContentRegular(
                this.content.nameStatic != null ? '<a href="/discussion/${this.content.discussionId}">${this.content.nameStatic}</a>' : '-')),
          if (this.content.discussionId == null) Text(this.content.nameStatic ?? '-'),
          const SizedBox(height: 10),
          Text('Kategorie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(this.content.categoryPath ?? '-'),
          const SizedBox(height: 10),
          Text('Popis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          PostHtml(ContentRegular(this.content.summary ?? '-')),
          if (this.content.discussionId == null) ...[
            const SizedBox(height: 10),
            Text('Možná podobné', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            PostHtml(ContentRegular(this.content.similarDiscussions ?? '-')),
          ],
          const SizedBox(height: 10),
          Text('Hlasovat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          DiscussionRequestButtons(content: this.content),
        ],
      ),
    );
  }
}
