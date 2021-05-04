import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/Advertisement.dart';
import 'package:fyx/components/post/Poll.dart';
import 'package:fyx/components/post/PostFooterLink.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/UnreadBadgeDecoration.dart';

enum LAYOUT_TYPES { textOnly, oneImageOnly, attachmentsOnly, attachmentsAndText }

typedef Widget TLayout();

class ContentBoxLayout extends StatelessWidget {
  final Widget topLeftWidget;
  final Widget topRightWidget;
  final Widget bottomWidget;
  final Content content;
  final bool _isPreview;
  final bool _isHighlighted;
  final Map<LAYOUT_TYPES, TLayout> _layoutMap = {};
  final Function onTap;

  ContentBoxLayout({this.topLeftWidget, this.topRightWidget, this.bottomWidget, this.content, isPreview = false, isHighlighted = false, this.onTap})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted {
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
                images: content.images,
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
                children.add(PostHeroAttachment(attachment, images: content.images));
              });

              return Wrap(children: children, spacing: 8, alignment: WrapAlignment.start);
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsAndText,
        () => () {
              if (!(content.attachments.length >= 1 && content.strippedContent.isNotEmpty)) {
                return null;
              }

              // If there are NOT consecutive images, do not display the post with hero attachment and render it from raw HTML body instead.
              if (!content.consecutiveImages) {
                return PostHtml(content);
              }

              var children = <Widget>[];
              children.add(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Expanded(child: PostHtml(content)), PostHeroAttachment(content.attachmentsWithFeatured['featured'], images: content.images,)],
              ));

              if ((content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().length > 0) {
                children.add(() {
                  var children = (content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().map((attachment) {
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: PostHeroAttachment(
                          attachment,
                          images: content.images,
                          size: 50.0,
                        ));
                  }).toList();
                  return Row(children: children, mainAxisAlignment: MainAxisAlignment.start);
                }());
              }

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
              height: 8,
              thickness: 8,
            ),
          ),
          Container(
            color: _isHighlighted ? T.COLOR_SECONDARY.withOpacity(0.1) : null,
            foregroundDecoration: _isHighlighted ? UnreadBadgeDecoration(badgeColor: T.COLOR_PRIMARY, badgeSize: 16) : null,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[topLeftWidget ?? Container(), SizedBox(), _isPreview ? Container() : (topRightWidget ?? Container())],
                  ),
                ),
                if (this.onTap == null)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    child: getContentWidget(),
                  )
                else
                  GestureDetector(
                    onTap: this.onTap,
                    child: AbsorbPointer(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        child: getContentWidget(),
                      ),
                    ),
                  ),
                Visibility(
                  visible: content.emptyLinks.length > 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: content.emptyLinks.map((link) => PostFooterLink(link)).toList(),
                      )),
                ),
                SizedBox(
                  height: 8,
                ),
                this.bottomWidget != null ? Divider(color: Colors.black38) : Container(),
                this.bottomWidget != null ? Container(child: this.bottomWidget, padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16)) : Container(),
                SizedBox(
                  height: 8,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getContentWidget() {
    return MainRepository().settings.useCompactMode
        ? (() {
            for (final layout in LAYOUT_TYPES.values) {
              var result = _layoutMap[layout]();
              if (result != null) {
                return result;
              }
            }
            return getWidgetByContentType(content);
          })()
        : getWidgetByContentType(content);
  }

  Widget getWidgetByContentType(Content content) {
    switch (this.content.contentType) {
      case PostTypeEnum.poll:
        return Poll(content);
      case PostTypeEnum.text:
        return PostHtml(content);
      case PostTypeEnum.advertisement:
        return Advertisement(content);
      default:
        return T.somethingsWrongButton(content.rawBody);
    }
  }
}
