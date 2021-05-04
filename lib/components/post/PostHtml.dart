import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/Spoiler.dart';
import 'package:fyx/components/post/SyntaxHighlighter.dart';
import 'package:fyx/components/post/VideoPlayer.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as post;
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';

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
        'html': Style.fromTextStyle(
            CupertinoTheme.of(context).textTheme.textStyle),
        '.image-link': Style(textDecoration: TextDecoration.none),
        'span.r': Style(fontWeight: FontWeight.bold),
        'body': Style(margin: EdgeInsets.all(0))
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
              images: content.images,
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

          return T.somethingsWrongButton(content.rawBody);
        },
        'div': (
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
        },
        'pre': (
          RenderContext renderContext,
          Widget parsedChild,
          Map<String, String> attributes,
          dom.Element element,
        ) {
          if (attributes['style'] == 'background-color:#272822') {
            final source = HtmlUnescape().convert(element.text);
            return SyntaxHighlighter(source);
          } else {
            return parsedChild;
          }
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
        var parserResult = Helpers.parseDiscussionUri(link);
        if (parserResult.isNotEmpty) {
          var arguments = DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId]);
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/discussion', arguments: arguments);
          return;
        }

        // Click through to another discussion with message deeplink
        parserResult = Helpers.parseDiscussionPostUri(link);
        if (parserResult.isNotEmpty) {
          var arguments = DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId], postId: parserResult[INTERNAL_URI_PARSER.postId]);
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/discussion', arguments: arguments);
          return;
        }

        // TODO: Marketplace, ...

        // TODO: New API
        // Other Nyx internal links that cannot be displayed within Fyx
        RegExp otherDeeplinkTest = new RegExp(r"^/(.*)");
        Iterable<RegExpMatch> otherDeeplinkMatches =
            otherDeeplinkTest.allMatches(link);
        if (otherDeeplinkMatches.length == 1) {
          link = 'https://www.nyx.cz$link';
        }

        T.openLink(link);
      },
    );
  }
}
