import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/PostFooterLink.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/provider/SettingsModel.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart';

enum LAYOUT_TYPES { textOnly, oneImageOnly, attachmentsOnly, attachmentsAndText }

typedef Widget TLayout();

class ContentBoxLayout extends StatelessWidget {
  final Widget topLeftWidget;
  final Widget topRightWidget;
  final Content content;
  final bool _isPreview;
  final Map<LAYOUT_TYPES, TLayout> _layoutMap = {};

  ContentBoxLayout({this.topLeftWidget, this.topRightWidget, this.content, isPreview = false}) : _isPreview = isPreview {
    // The order here is important!
    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.textOnly,
        () => () {
              if (content.strippedContent.isNotEmpty && content.attachments.isEmpty) {
                return PostHtml(content);
              }
              return null;
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.oneImageOnly,
        () => () {
              if (!(content.strippedContent.isEmpty && content.attachments.length == 1 && content.images.length == 1)) {
                return null;
              }

              return PostHeroAttachment(
                content.images[0],
                content,
                crop: false,
              );
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsOnly,
        () => () {
              if (!(content.strippedContent.length == 0 && content.attachments.length > 1)) {
                return null;
              }

              var children = <Widget>[];
              content.attachments.forEach((attachment) {
                children.add(PostHeroAttachment(attachment, content));
              });

              return Wrap(children: children, spacing: 8, alignment: WrapAlignment.start);
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsAndText,
        () => () {
              if (!(content.attachments.length >= 1 && content.strippedContent.isNotEmpty)) {
                return null;
              }

              var children = <Widget>[];
              children.add(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Expanded(child: PostHtml(content)), PostHeroAttachment(content.attachmentsWithFeatured['featured'], content)],
              ));

              if ((content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().length > 0) {
                children.add(() {
                  var children = (content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().map((attachment) {
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: PostHeroAttachment(
                          attachment,
                          content,
                          size: 50.0,
                        ));
                  }).toList();
                  return Row(children: children, mainAxisAlignment: MainAxisAlignment.start);
                }());
              }

              children.addAll((content.attachmentsWithFeatured['attachments'] as List).whereType<Link>().map((attachment) {
                return PostFooterLink(attachment);
              }));

              return Column(
                children: children,
              );
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _isPreview ? T.CARD_SHADOW_DECORATION : null,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: _isPreview != true,
            child: Divider(
              thickness: 8,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[topLeftWidget ?? Container(), SizedBox(), topRightWidget ?? Container()],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: getContentWidget(),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget getContentWidget() {
    return Consumer<SettingsModel>(
        builder: (context, settings, child) => settings.useHeroPosts
            ? (() {
                for (final layout in LAYOUT_TYPES.values) {
                  var result = _layoutMap[layout]();
                  if (result != null) {
                    return result;
                  }
                }

                // TODO: Doplnit text a odkaz.
                return GestureDetector(
                  onTap: () => PlatformTheme.prefillGithubIssue('**Zdroj:**\n```${content.rawBody}```', title: 'Chyba zobrazení příspěvku'),
                  child: Column(children: <Widget>[
                    Icon(Icons.warning),
                    Text(
                      'Nastal problém se zobrazením příspěvku.\n Vyplňte prosím github issue kliknutím sem...',
                      textAlign: TextAlign.center,
                    )
                  ]),
                );
              })()
            : PostHtml(content));
  }
}
