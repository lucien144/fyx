import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/Spoiler.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/provider/SettingsModel.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';

class PostHtml extends StatelessWidget {
  final Content content;

  PostHtml(this.content);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
        builder: (context, settings, child) => Html(
              data: settings.useHeroPosts ? content.body : content.rawBody,
              customRender: (dom.Node node, children) {
                if (node is dom.Element) {
                  if (node.localName == 'span' && node.classes.contains('spoiler')) {
                    return Spoiler(node.innerHtml);
                  }
                }
                return null;
              },
              useRichText: false,
              onImageTap: (String src) {
                Navigator.of(context).pushNamed('/gallery', arguments: GalleryArguments(src, images: content.images));
              },
              onLinkTap: (String link) async {
                print(link);

                // Click through to another discussion
                RegExp topicTest = new RegExp(r"^\?l=topic;id=([0-9]+)$");
                Iterable<RegExpMatch> topicMatches = topicTest.allMatches(link);
                if (topicMatches.length == 1) {
                  var id = int.parse(topicMatches.elementAt(0).group(1));
                  var arguments = DiscussionPageArguments(id);
                  DiscussionPage.deeplinkDepth++;
                  Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
                  return;
                }

                // Click through to another discussion with message deeplink
                RegExp topicDeeplinkTest = new RegExp(r"^\?l=topic;id=([0-9]+);wu=([0-9]+)$");
                Iterable<RegExpMatch> topicDeeplinkMatches = topicDeeplinkTest.allMatches(link);
                if (topicDeeplinkMatches.length == 1) {
                  var id = int.parse(topicDeeplinkMatches.elementAt(0).group(1));
                  var wu = int.parse(topicDeeplinkMatches.elementAt(0).group(2)) + 1;
                  var arguments = DiscussionPageArguments(id, postId: wu);
                  DiscussionPage.deeplinkDepth++;
                  Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
                  return;
                }

                PlatformTheme.openLink(link);
              },
            ));
  }
}
