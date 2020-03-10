import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/L.dart';
import 'package:url_launcher/url_launcher.dart';

class PostHtml extends StatelessWidget {
  final Post post;

  PostHtml(this.post);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: post.content,
      onLinkTap: (String link) async {
        print(link);

        RegExp postTest = new RegExp(r"^\?l=topic;id=([0-9]+);wu=([0-9]+)$");
        Iterable<RegExpMatch> matches = postTest.allMatches(link);
        if (matches.length == 1) {
          Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: int.parse(matches.elementAt(0).group(1)));
          return;
        }

        try {
          if (await canLaunch(link)) {
            await launch(link);
          } else {
            PlatformTheme.error(L.INAPPBROWSER_ERROR);
          }
        } catch (e) {
          PlatformTheme.error(L.INAPPBROWSER_ERROR);
        }
      },
    );
  }
}
