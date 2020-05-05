import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/Spoiler.dart';
import 'package:fyx/components/post/VideoPlayer.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/provider/SettingsModel.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';

class PostHtml extends StatelessWidget {
  final Content content;
  bool _isImageTap = false;

  PostHtml(this.content);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
        builder: (context, settings, child) => Html(
              data: settings.useHeroPosts ? content.body : content.rawBody,
              style: {"html": Style.fromTextStyle(PlatformTheme.of(context).textTheme.textStyle ?? PlatformTheme.of(context).textTheme.body1)},
              customRender: {
                'video': (
                  RenderContext context,
                  Widget parsedChild,
                  Map<String, String> attributes,
                  dom.Element element,
                ) {
                  var url = element.attributes['src'];
                  var urls = element.querySelectorAll('source').map((element) => element.attributes['src']).toList();
                  if ([null, ''].contains(url) && urls.length > 0) {
                    url = urls.firstWhere((url) => url.endsWith('.mp4'));
                    if (url.isEmpty) {
                      url = urls.first;
                    }
                  }
                  if (url?.isNotEmpty ?? false) {
                    return VideoPlayer(url);
                  }
                  // TODO: fallback
                  return null;
                },
                'span': (
                  RenderContext context,
                  Widget parsedChild,
                  Map<String, String> attributes,
                  dom.Element element,
                ) {
                  if (element.classes.contains('spoiler')) {
                    return Spoiler(element.text);
                  }
                  return null;
                }
              },
              onImageTap: (String src) {
                _isImageTap = true;
                Navigator.of(context).pushNamed('/gallery', arguments: GalleryArguments(src, images: content.images));
              },
              onLinkTap: (String link) async {
                // 👇 https://github.com/Sub6Resources/flutter_html/issues/121#issuecomment-581593467
                if (_isImageTap) {
                  _isImageTap = false;
                  return;
                }

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
