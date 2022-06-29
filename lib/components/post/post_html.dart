import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/components/post/spoiler.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/post/video_player.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as post;
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';

class PostHtml extends StatelessWidget {
  final Content? content;
  bool _isImageTap = false;

  /// overloadRaw - if true, the content.rawBody is used to parse no matter what settings is on.
  PostHtml(this.content);

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;

    return Html(
      data: MainRepository().settings.useCompactMode && content!.consecutiveImages ? content!.body : content!.rawBody,
      style: {
        'html': Style.fromTextStyle(CupertinoTheme.of(context).textTheme.textStyle),
        '.image-link': Style(textDecoration: TextDecoration.none),
        'span.r': Style(fontWeight: FontWeight.bold),
        'body': Style(margin: EdgeInsets.all(0)),
        'pre': Style(color: Colors.transparent),
      },
      customRender: {
        'em': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;
          if (element!.classes.contains('search-match')) {
            return RichText(
                text: WidgetSpan(
                    child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              decoration: BoxDecoration(
                  color: colors.highlightedText,
                  border: Border.all(width: 1, color: colors.highlightedText),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: colors.grey.withOpacity(0.4), //New
                        blurRadius: 2.0,
                        offset: Offset(0, 0))
                  ]),
              child: Text(
                element.text,
                style: TextStyle(color: colors.dark, fontStyle: FontStyle.italic, fontSize: 15),
              ),
            )));
          }
          return parsedChild;
        },
        'img': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;
          final String? thumb = element!.attributes['src'];

          if (thumb == null) {
            return parsedChild;
          }

          String src = thumb;
          bool openGallery = true;
          if (element.parent!.localName == 'a') {
            final RegExp r = RegExp(r'\.(jpg|jpeg|png|gif|webp)(\?.*)?$');
            if (r.hasMatch(element.parent!.attributes['href'] ?? '')) {
              src = element.parent!.attributes['href'] ?? '';
            } else {
              openGallery = false;
            }
          }

          post.Image img = post.Image(src, thumb: thumb);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: PostHeroAttachment(
              img,
              images: content!.images,
              openGallery: openGallery,
              onTap: () => openGallery ? _isImageTap = true : null,
              crop: false,
            ),
          );
        },
        'video': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;
          if (element != null) {
            return VideoPlayer(element);
          }
          return T.somethingsWrongButton(content!.rawBody);
        },
        'div': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;

          // Spoiler
          if (element!.classes.contains('spoiler')) {
            return Spoiler(parsedChild);
          }

          // Youtube
          if (element.attributes['data-embed-type'] == 'youtube') {
            var img = element.querySelector('img');
            if (img == null) {
              return parsedChild;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PostHeroAttachment(
                Video(
                    id: element.attributes['data-embed-value']!,
                    type: Video.findVideoType(element.attributes['data-embed-type']!),
                    image: img.attributes['src']!,
                    thumb: img.attributes['src']!),
                size: Size(double.infinity, MediaQuery.of(context).size.width * (0.5)),
                showStrip: false,
              ),
            );
          }

          return parsedChild;
        },
        'span': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;

          // Spoiler
          if (element!.classes.contains('spoiler')) {
            return Spoiler(parsedChild);
          }

          return parsedChild;
        },
        'pre': (
          RenderContext renderContext,
          Widget parsedChild,
        ) {
          final element = renderContext.tree.element;

          if (element == null) {
            return parsedChild;
          }

          if (element.attributes['style'] == 'background-color:#272822') {
            final source = HtmlUnescape().convert(element.text);
            return SyntaxHighlighter(source);
          } else {
            return Text(element.text, style: TextStyle(fontFamily: 'JetBrainsMono'));
          }
        }
      },
      onImageTap: (String? src, RenderContext context, Map<String, String> attributes, dom.Element? element) {
        _isImageTap = true;
        Navigator.of(context.buildContext).pushNamed('/gallery', arguments: GalleryArguments(src!, images: content!.images));
      },
      onLinkTap: (String? link, RenderContext context, Map<String, String> attributes, dom.Element? element) async {
        // 👇 https://github.com/Sub6Resources/flutter_html/issues/121#issuecomment-581593467
        if (_isImageTap) {
          _isImageTap = false;
          return;
        }

        if (link == null) {
          return;
        }

        // Click through to another discussion
        var parserResult = Helpers.parseDiscussionUri(link);
        if (parserResult.isNotEmpty) {
          var arguments = DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId]!, search: parserResult[INTERNAL_URI_PARSER.search]);
          Navigator.of(context.buildContext, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
          return;
        }

        // Click through to another discussion with message deeplink
        parserResult = Helpers.parseDiscussionPostUri(link);
        if (parserResult.isNotEmpty) {
          var arguments =
              DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId]!, postId: parserResult[INTERNAL_URI_PARSER.postId]! + 1);
          Navigator.of(context.buildContext, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
          return;
        }

        // TODO: Marketplace, ...

        // TODO: New API
        // Other Nyx internal links that cannot be displayed within Fyx
        RegExp otherDeeplinkTest = new RegExp(r"^/(.*)");
        Iterable<RegExpMatch> otherDeeplinkMatches = otherDeeplinkTest.allMatches(link);
        if (otherDeeplinkMatches.length == 1) {
          link = 'https://nyx.cz$link';
        }

        T.openLink(link);
      },
    );
  }
}