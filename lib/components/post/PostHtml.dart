import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/Poll.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/Spoiler.dart';
import 'package:fyx/components/post/VideoPlayer.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as post;
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:html/dom.dart' as dom;

class PostHtml extends StatelessWidget {
  final Content content;
  bool _isImageTap = false;

  /// overloadRaw - if true, the content.rawBody is used to parse no matter what settings is on.
  PostHtml(this.content);
  
  @override
  Widget build(BuildContext context) {
    return Html(
      data:
          MainRepository().settings.useCompactMode && content.consecutiveImages
              ? content.body
              : content.rawBody,
      style: {
        "html": Style.fromTextStyle(
            PlatformTheme.of(context).textTheme.textStyle ??
                PlatformTheme.of(context).textTheme.body1),
        ".image-link": Style(textDecoration: TextDecoration.none),
        "span.r": Style(fontWeight: FontWeight.bold),
      },
      customRender: {
        'img': (
          RenderContext renderContext,
          Widget parsedChild,
          Map<String, String> attributes,
          dom.Element element,
        ) {
          final String thumb = element.attributes['src'];
          String src = thumb;
          bool openGallery = true;
          if (element.parent.localName == 'a') {
            final RegExp r = RegExp(r'\.(jpg|jpeg|png|gif|webp)(\?.*)?$');
            if (r.hasMatch(element.parent.attributes['href'] ?? '')) {
              src = element.parent.attributes['href'];
            } else {
              openGallery = false;
            }
          }
          post.Image img = post.Image(src, thumb);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: PostHeroAttachment(
              img,
              content,
              openGallery: openGallery,
              onTap: () => openGallery ? _isImageTap = true : null,
              crop: false,
            ),
          );
        },
        'video': (
          RenderContext renderContext,
          Widget parsedChild,
          Map<String, String> attributes,
          dom.Element element,
        ) {
          var url = element.attributes['src'];
          var urls = element
              .querySelectorAll('source')
              .map((element) => element.attributes['src'])
              .toList();
          if ([null, ''].contains(url) && urls.length > 0) {
            url = urls.firstWhere((url) => url.endsWith('.mp4'));
            if (url.isEmpty) {
              url = urls.first;
            }
          }
          if (url?.isNotEmpty ?? false) {
            return VideoPlayer(element);
          }

          return PlatformTheme.somethingsWrongButton(content.rawBody);
        },
        'div': (
          RenderContext renderContext,
          Widget parsedChild,
          Map<String, String> attributes,
          dom.Element element,
        ) {
          // Polls
          if (element.classes.contains('w-dyn')) {
            return Poll(element.outerHtml);
          }

          return parsedChild;
        },
        'span': (
          RenderContext renderContext,
          Widget parsedChild,
          Map<String, String> attributes,
          dom.Element element,
        ) {
          // Spoiler
          if (element.classes.contains('spoiler')) {
            return Spoiler(element.text);
          }

          return parsedChild;
        }
      },
      onImageTap: (String src) {
        _isImageTap = true;
        Navigator.of(context).pushNamed('/gallery',
            arguments: GalleryArguments(src, images: content.images));
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
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/discussion', arguments: arguments);
          return;
        }

        // Click through to another discussion with message deeplink
        RegExp topicDeeplinkTest =
            new RegExp(r"^\?l=topic;id=([0-9]+);wu=([0-9]+)$");
        Iterable<RegExpMatch> topicDeeplinkMatches =
            topicDeeplinkTest.allMatches(link);
        if (topicDeeplinkMatches.length == 1) {
          var id = int.parse(topicDeeplinkMatches.elementAt(0).group(1));
          var wu = int.parse(topicDeeplinkMatches.elementAt(0).group(2)) + 1;
          var arguments = DiscussionPageArguments(id, postId: wu);
          DiscussionPage.deeplinkDepth++;
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/discussion', arguments: arguments);
          return;
        }

        // TODO: Marketplace, ...

        // Other Nyx internal links that cannot be displayed within Fyx
        RegExp otherDeeplinkTest = new RegExp(r"^\?l=(.*)");
        Iterable<RegExpMatch> otherDeeplinkMatches =
            otherDeeplinkTest.allMatches(link);
        if (otherDeeplinkMatches.length == 1) {
          link = 'https://www.nyx.cz/index.php$link';
        }

        PlatformTheme.openLink(link);
      },
    );
  }
}
