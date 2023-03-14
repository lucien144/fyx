import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/bottom_sheets/post_context_menu.dart';
import 'package:fyx/components/content_box_layout.dart';
import 'package:fyx/components/gesture_feedback.dart';
import 'package:fyx/components/post/post_avatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/IconReply.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MailListItem extends StatefulWidget {
  final Mail mail;
  final bool isPreview;
  final Function? onUpdate;

  const MailListItem(this.mail, {this.isPreview = false, this.onUpdate});

  @override
  _MailListItemState createState() => _MailListItemState();
}

class _MailListItemState extends State<MailListItem> {

  void showMailContext() {
    showCupertinoModalBottomSheet(
        context: context,
        builder: (BuildContext context) => PostContextMenu<Mail>(
          parentContext: context,
          item: widget.mail,
          flagPostCallback: (mailId) => MainRepository().settings.blockMail(mailId),
        ));
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onLongPress: showMailContext,
      child: ContentBoxLayout(
        isHighlighted: widget.mail.isNew,
        isPreview: widget.isPreview == true,
        content: widget.mail.content,
        topLeftWidget: PostAvatar(widget.mail.direction == MailDirection.from ? widget.mail.participant : MainRepository().credentials!.nickname,
            description:
                '→ ${widget.mail.direction == MailDirection.to ? widget.mail.participant : MainRepository().credentials!.nickname}, ~${Helpers.relativeTime(widget.mail.time)}'),
        topRightWidget: Row(
          children: <Widget>[
            Visibility(
              visible: widget.mail.isOutgoing && widget.mail.isUnread,
              child: Icon(
                MdiIcons.emailMarkAsUnread,
                color: colors.text.withOpacity(0.38),
              ),
            ),
            SizedBox(
              width: 4,
            ),
            GestureFeedback(
                child: Icon(Icons.more_vert, color: colors.text.withOpacity(0.38)),
                onTap: showMailContext,
            ),
          ],
        ),
        bottomWidget: widget.isPreview == true
            ? null
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[IconReply(), Text('Odpovědět', style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 14))],
                  ),
                  onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                      arguments: NewMessageSettings(
                          onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                            if (inputField == null) {
                              return false;
                            }
                            var response = await ApiController().sendMail(inputField, message, attachments: attachments);
                            return response.isOk;
                          },
                          onClose: this.widget.onUpdate!,
                          inputFieldPlaceholder: widget.mail.participant,
                          hasInputField: true,
                          replyWidget: MailListItem(
                            widget.mail,
                            isPreview: true,
                          ))),
                )
              ]),
      ),
    );
  }
}
