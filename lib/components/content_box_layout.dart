import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/post/advertisement.dart';
import 'package:fyx/components/post/dice.dart';
import 'package:fyx/components/post/discussion_request.dart';
import 'package:fyx/components/post/poll.dart';
import 'package:fyx/components/post/post_footer_link.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/components/post/post_html.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/model/post/content/Dice.dart';
import 'package:fyx/model/post/content/Poll.dart';
import 'package:fyx/model/post/content/discussion_request.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/UnreadBadgeDecoration.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

enum LAYOUT_TYPES { textOnly, oneImageOnly, attachmentsOnly, attachmentsAndText }

typedef Widget? TLayout();

class ContentBoxLayout extends StatelessWidget {
  final Widget topLeftWidget;
  final Widget topRightWidget;
  final Widget? bottomWidget;
  final Content content;
  final bool _isPreview;
  final bool _isHighlighted;
  final bool isSelected;
  final Map<LAYOUT_TYPES, TLayout> _layoutMap = {};
  final VoidCallback? onTap;
  final bool blur;

  ContentBoxLayout(
      {required this.topLeftWidget,
      required this.topRightWidget,
      this.bottomWidget,
      this.isSelected = false,
      required this.content,
      isPreview = false,
      isHighlighted = false,
      this.blur = false,
      this.onTap})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted {
    // The order here is important!
    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.textOnly,
        () => () {
              if (content.strippedContent.isNotEmpty && content.attachments.isEmpty) {
                return PostHtml(content, blur: blur);
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
                blur: blur,
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
                children.add(PostHeroAttachment(
                  attachment,
                  images: content.images,
                  blur: blur,
                ));
              });

              return Wrap(
                children: children,
                spacing: 8,
                alignment: WrapAlignment.start,
                runSpacing: 8,
              );
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsAndText,
        () => () {
              if (!(content.attachments.length >= 1 && content.strippedContent.isNotEmpty)) {
                return null;
              }

              // If there are NOT consecutive images, do not display the post with hero attachment and render it from raw HTML body instead.
              if (!content.consecutiveImages) {
                return PostHtml(content, blur: blur);
              }

              var children = <Widget>[];
              children.add(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: PostHtml(content, blur: blur)),
                  PostHeroAttachment(
                    content.attachmentsWithFeatured['featured'],
                    images: content.images,
                    blur: blur,
                  )
                ],
              ));

              if ((content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().length > 0) {
                children.add(() {
                  var children = (content.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().map((attachment) {
                    return PostHeroAttachment(
                      attachment,
                      images: content.images,
                      size: Size(50, 50),
                      blur: blur,
                    );
                  }).toList();
                  return Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Wrap(
                        children: children,
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                      ));
                }());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            });
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Container(
      decoration: _isPreview ? colors.shadow : null,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: _isPreview != true,
            child: Divider(
              height: 8,
              thickness: 8,
              color: colors.divider,
            ),
          ),
          Container(
            color: (() {
              if (this.isSelected) {
                return colors.highlightedText.withOpacity(.3);
              }
              return _isHighlighted ? colors.primary.withOpacity(0.1) : null;
            })(),
            foregroundDecoration: _isHighlighted ? UnreadBadgeDecoration(badgeColor: colors.primary, badgeSize: 16) : null,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[topLeftWidget, SizedBox(), _isPreview ? Container() : (topRightWidget)],
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
                this.bottomWidget != null ? Divider(color: colors.grey) : Container(),
                this.bottomWidget != null
                    ? Container(child: this.bottomWidget, padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16))
                    : Container(),
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
              var result = _layoutMap[layout]!();
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
        return Poll(content as ContentPoll);
      case PostTypeEnum.dice:
        return Dice(content as ContentDice);
      case PostTypeEnum.text:
        return PostHtml(content, blur: blur);
      case PostTypeEnum.advertisement:
        return Advertisement(content as ContentAdvertisement);
      case PostTypeEnum.discussion_request:
        return PostDiscussionRequest(content: content as ContentDiscussionRequest);
      default:
        return T.somethingsWrongButton(content.rawBody);
    }
  }
}
