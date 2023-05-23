import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/components/bottom_sheets/context_menu/grid.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/components/post/post_avatar.dart';
import 'package:fyx/components/post/post_hero_attachment.dart';
import 'package:fyx/components/post/post_html.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/UserReferences.dart';
import 'package:fyx/model/enums/AdEnums.dart';
import 'package:fyx/model/post/Image.dart' as i;
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/pages/search_page.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class Advertisement extends StatelessWidget {
  final ContentAdvertisement content;
  final String? title; // Ad title can be overwritten. Helpful in discussion page where content.fullName is null.
  final String username;

  // If this widget needs to be displayed within PostListItem (in discussion) or as a standalone widget (pinned to pull-to-refresh)
  bool get isStandaloneWidget => this.username is String && this.username.isNotEmpty;

  String get heading => this.title ?? (content.fullName);

  const Advertisement(this.content, {this.title, this.username = ''});

  Widget buildPriceWidget(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Container(
        padding: const EdgeInsets.all(6),
        child: Text('${content.price.toString()} ${content.currency}',
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: colors.background)),
        decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(6)));
  }

  Widget buildTitleWidget(BuildContext context) {
    return Text(heading, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget buildRefrencesWidget(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    if (content.references is UserReferences) {
      return RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Reference: ', style: TextStyle(color: colors.grey, fontSize: 10)),
          if (content.references != null && content.references!.positive > 0)
            TextSpan(text: '+${content.references!.positive}', style: TextStyle(color: colors.primary, fontSize: 10)),
          if (content.references != null && content.references!.positive > 0 && content.references!.negative < 0)
            TextSpan(text: ' / ', style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10)),
          if (content.references != null && content.references!.negative < 0)
            TextSpan(text: '-${content.references!.negative}', style: TextStyle(color: colors.danger, fontSize: 10))
        ]),
      );
    }

    return Text('');
  }

  Widget buildIconLabelWidget(IconData icon, String label, BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
          ),
        ],
      ),
      //decoration: BoxDecoration(color: T.COLOR_LIGHT, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!this.isStandaloneWidget) {
          var arguments = DiscussionPageArguments(content.discussionId);
          Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
        }
      },
      onLongPress: () => showCupertinoModalBottomSheet(
          context: context,
          builder: (BuildContext context) => ContextMenuGrid(children: [
                ContextMenuItem(
                    label: 'Odpovědět soukromě',
                    icon: MdiIcons.replyOutline,
                    onTap: () {
                      Navigator.pop(context); // Close the sheet first.
                      Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                          arguments: NewMessageSettings(
                              hasInputField: true,
                              inputFieldPlaceholder: this.username,
                              messageFieldPlaceholder: '${content.link}\n',
                              onClose: () => T.success('👍 Zpráva poslána.', bg: colors.success),
                              onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                                if (inputField == null) return false;

                                var response = await ApiController().sendMail(inputField, message, attachments: attachments);
                                return response.isOk;
                              }));
                    }),
                ContextMenuItem(
                    label: 'Filtrovat\n@${this.username}',
                    icon: MdiIcons.accountFilterOutline,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamed('/discussion', arguments: DiscussionPageArguments(content.discussionId, filterByUser: this.username));
                      AnalyticsProvider().logEvent('filter_user_posts / ad');
                    }),
                ContextMenuItem(
                    label: 'Vyhledat příspěvky\n@${this.username}',
                    icon: MdiIcons.accountSearchOutline,
                    onTap: () {
                      Navigator.of(context).pop();
                      var arguments = SearchPageArguments(searchTerm: '@${this.username}');
                      Navigator.of(context, rootNavigator: true).pushNamed('/search', arguments: arguments);
                      AnalyticsProvider().logEvent('filter_user_discussions / ad');
                    }),
                ContextMenuItem(
                    label: L.POST_SHEET_COPY_LINK,
                    icon: MdiIcons.link,
                    onTap: () {
                      var data = ClipboardData(text: content.link);
                      Clipboard.setData(data).then((_) {
                        T.success(L.TOAST_COPIED, bg: colors.success);
                        Navigator.pop(context);
                      });
                      AnalyticsProvider().logEvent('copyLink / ad');
                    }),
                ContextMenuItem(
                    label: L.POST_SHEET_SHARE,
                    icon: MdiIcons.shareVariant,
                    onTap: () {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      Share.share(content.link, subject: heading, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                      Navigator.pop(context);
                      AnalyticsProvider().logEvent('shareSheet / ad');
                    })
              ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (this.isStandaloneWidget)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [PostAvatar(this.username, descriptionWidget: buildRefrencesWidget(context)), buildPriceWidget(context)],
              ),
            ),
          if (this.isStandaloneWidget)
            buildTitleWidget(context)
          else
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (heading.isNotEmpty) Flexible(child: buildTitleWidget(context)),
                if (content.price > 0) buildPriceWidget(context),
              ],
            ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                child: Text(
                  content.type == AdTypeEnum.offer ? 'Nabízím' : 'Hledám',
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontSize: 12, color: content.type == AdTypeEnum.offer ? colors.background : colors.text),
                ),
                decoration: BoxDecoration(
                    color: content.type == AdTypeEnum.offer ? colors.primary : colors.highlight, borderRadius: BorderRadius.circular(6)),
              ),
              if (content.location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: buildIconLabelWidget(Icons.location_on_outlined, content.location, context),
                ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          if (content.insertedAt > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildIconLabelWidget(Icons.calendar_today, Helpers.absoluteTime(content.insertedAt), context),
            ),
          if (content.shipping.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildIconLabelWidget(Icons.local_shipping_outlined, content.shipping, context),
            ),
          if (content.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(content.summary),
            ),
          if (content.description.isNotEmpty) PostHtml(content.description),
          if (content.photoIds.length > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: galleryWidget(context),
            )
        ],
      ),
    );
  }

  Widget galleryWidget(context) {
    List<i.Image> images = content.photoIds.map((String thumb) {
      String small = 'https://nyx.cz/$thumb';
      String large = small.replaceAllMapped(RegExp(r'(square)(\.[a-z]{3,4})$'), (match) => 'original${match[2]}');

      return i.Image(large, thumb: small);
    }).toList();
    return Wrap(
      children: images.map((image) => PostHeroAttachment(image, images: images)).toList(),
      spacing: 8,
      runSpacing: 8,
    );
  }
}
