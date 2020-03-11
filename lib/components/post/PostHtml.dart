import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/DiscussionPage.dart';

class PostHtml extends StatelessWidget {
  final Post post;

  PostHtml(this.post);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: post.content,
      onLinkTap: (String link) async {
        print(link);

        // Click through to another discussion
        RegExp topicTest = new RegExp(r"^\?l=topic;id=([0-9]+)$");
        Iterable<RegExpMatch> topicMatches = topicTest.allMatches(link);
        if (topicMatches.length == 1) {
          var arguments = DiscussionPageArguments(int.parse(topicMatches.elementAt(0).group(1)));
          Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
          return;
        }

        // Click through to another discussion with message deeplink
        RegExp topicDeeplinkTest = new RegExp(r"^\?l=topic;id=([0-9]+);wu=([0-9]+)$");
        Iterable<RegExpMatch> topicDeeplinkMatches = topicDeeplinkTest.allMatches(link);
        if (topicDeeplinkMatches.length == 1) {
          var arguments = DiscussionPageArguments(int.parse(topicDeeplinkMatches.elementAt(0).group(1)), postId: int.parse(topicDeeplinkMatches.elementAt(0).group(2)) + 1);
          Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
          return;
        }

        PlatformTheme.openLink(link);
      },
    );
  }
}
