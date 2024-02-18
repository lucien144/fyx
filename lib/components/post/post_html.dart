import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/components/post/spoiler.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/post/video_player.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/Content.dart' as fyx;
import 'package:fyx/model/post/Image.dart' as post;
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/search_page.dart';
import 'package:fyx/pages/tab_bar/MailboxTab.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostHtml extends StatelessWidget {
  final fyx.Content? content;
  final bool blur;
  final bool selectable;
  bool _isImageTap = false;

  /// overloadRaw - if true, the content.rawBody is used to parse no matter what settings is on.
  PostHtml(this.content, {this.blur = false, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;

    final html = Html(
        data: MainRepository().settings.useCompactMode && content!.consecutiveImages ? content!.body : content!.rawBody,
        style: {
          'html': Style.fromTextStyle(CupertinoTheme.of(context).textTheme.textStyle),
          '.image-link': Style(textDecoration: TextDecoration.none),
          'span.r': Style(fontWeight: FontWeight.bold),
          'span.eob': Style(display: Display.none, height: Height(0)),
          'body': Style(margin: Margins.all(0)),
          'pre': Style(color: Colors.transparent),
          'a': Style(color: colors.primary, textDecoration: TextDecoration.underline),
          '.fill': Style(textDecoration: TextDecoration.none, display: Display.block, color: colors.text),
          '.twitter-header a, .twitter-text a': Style(color: colors.twitter),
          '.twitter-header .name': Style(fontWeight: FontWeight.bold),
          '.twitter-text': Style(margin: Margins.symmetric(vertical: 10))
        },
        extensions: [
          // Fixes https://github.com/lucien144/fyx/issues/414
          // For some reason Html() has a bug of stripping whitespaces between 2 (or more) links.
          // Fixed by adding custom padding (extending styles does not work)...
          FyxTagWrapExtension(
              tagsToWrap: {'a'},
              builder: (parsedChild, renderContext) {
                final element = renderContext.element;
                if (element == null) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: parsedChild,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: GestureDetector(
                      child: parsedChild,
                      onTap: () {
                        _onLinkTap(context, element.attributes['href'], LinkedHashMap.from(element.attributes), element);
                      }),
                );
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'em'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;
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
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'img'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;
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
                    blur: blur,
                  ),
                );
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'video'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;
                if (element != null) {
                  return VideoPlayer(element, blur: blur);
                }
                return T.somethingsWrongButton(content!.rawBody);
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'div'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;

                // Spoiler
                if (element!.classes.contains('spoiler')) {
                  return Spoiler(parsedChild);
                }

                // Twitter
                if (element.attributes['data-embed-type'] == 'twitter') {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, top: 20),
                    child: Column(
                      children: [
                        Icon(MdiIcons.twitter, color: colors.twitter),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: parsedChild,
                          decoration: BoxDecoration(border: Border(left: BorderSide(width: 6, color: colors.twitter))),
                        ),
                      ],
                    ),
                  );
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
                      blur: blur,
                    ),
                  );
                }

                return parsedChild;
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'span'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;

                // Spoiler
                if (element!.classes.contains('spoiler')) {
                  return Spoiler(parsedChild);
                }

                return parsedChild;
              }),
          FyxTagWrapExtension(
              tagsToWrap: {'pre'},
              builder: (
                parsedChild,
                renderContext,
              ) {
                final element = renderContext.element;

                if (element == null) {
                  return parsedChild;
                }

                if (element.attributes['style'] == 'background-color:#272822') {
                  final source = HtmlUnescape().convert(element.text);
                  return SyntaxHighlighter(source);
                } else {
                  return Text(element.text, style: TextStyle(fontFamily: 'JetBrainsMono'));
                }
              }),
          OnImageTapExtension(
            onImageTap: (src, imgAttributes, element) {
              _isImageTap = true;
              Navigator.of(context).pushNamed('/gallery', arguments: GalleryArguments(src!, images: content!.images));
            },
          ),
        ],
        onLinkTap: (link, attr, el) => _onLinkTap(context, link, attr, el));

    if (this.selectable) {
      return SelectionArea(child: html);
    }
    return html;
  }

  _onLinkTap(BuildContext buildContext, String? link, Map<String, String> attributes, dom.Element? element) async {
    // 👇 https://github.com/Sub6Resources/flutter_html/issues/121#issuecomment-581593467
    if (_isImageTap) {
      _isImageTap = false;
      return;
    }

    if (link == null) {
      return;
    }

    // Search click through
    var searchTerm = Helpers.parseSearchUri(link);
    if (searchTerm != null) {
      var arguments = SearchPageArguments(searchTerm: searchTerm, focus: false);
      Navigator.of(buildContext, rootNavigator: true).pushNamed('/search', arguments: arguments);
      return;
    }

    // Click through to another discussion
    var parserResult = Helpers.parseDiscussionUri(link);
    if (parserResult.isNotEmpty) {
      var arguments = DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId]!, search: parserResult[INTERNAL_URI_PARSER.search]);
      Navigator.of(buildContext, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
      return;
    }

    // Click through to another mail
    parserResult = Helpers.parseMailUri(link);
    if (parserResult.isNotEmpty) {
      var arguments = MailboxTabArguments(mailId: parserResult[INTERNAL_URI_PARSER.mailId] + 1);
      Navigator.of(buildContext, rootNavigator: true).pushNamed('/mail', arguments: arguments);
      return;
    }

    // Click through to another discussion with message deeplink
    parserResult = Helpers.parseDiscussionPostUri(link);
    if (parserResult.isNotEmpty) {
      var arguments = DiscussionPageArguments(parserResult[INTERNAL_URI_PARSER.discussionId]!, postId: parserResult[INTERNAL_URI_PARSER.postId]! + 1);
      Navigator.of(buildContext, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
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

    T.openLink(link, mode: SettingsProvider().linksMode);
  }
}

// flutter_html widget v3 doesn't allow to pass parsedChild -> this is workaround
class FyxTagWrapExtension extends HtmlExtension {
  final Set<String> tagsToWrap;
  final Widget Function(Widget child, ExtensionContext context) builder;

  FyxTagWrapExtension({
    required this.tagsToWrap,
    required this.builder,
  });

  @override
  Set<String> get supportedTags => tagsToWrap;

  @override
  InlineSpan build(ExtensionContext context) {
    final child = CssBoxWidget.withInlineSpanChildren(
      children: context.inlineSpanChildren!,
      style: context.style!,
    );

    return WidgetSpan(
      child: builder.call(child, context),
    );
  }
}
