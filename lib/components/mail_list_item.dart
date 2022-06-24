import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/actionSheets/PostActionSheet.dart';
import 'package:fyx/components/content_box_layout.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/IconReply.dart';
import 'package:fyx/theme/IconUnread.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class MailListItem extends StatefulWidget {
  final Mail mail;
  final bool isPreview;
  final Function? onUpdate;

  const MailListItem(this.mail, {this.isPreview = false, this.onUpdate});

  @override
  _MailListItemState createState() => _MailListItemState();
}

class _MailListItemState extends State<MailListItem> {
  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return ContentBoxLayout(
      isHighlighted: widget.mail.isNew,
      isPreview: widget.isPreview == true,
      content: widget.mail.content,
      topLeftWidget: PostAvatar(widget.mail.direction == MailDirection.from ? widget.mail.participant : MainRepository().credentials!.nickname,
          description:
              '→ ${widget.mail.direction == MailDirection.to ? widget.mail.participant : MainRepository().credentials!.nickname}, ~${Helpers.relativeTime(widget.mail.time)}'),
      topRightWidget: Row(
        children: <Widget>[
          Visibility(
            visible: widget.mail.isUnread,
            child: IconUnread(),
          ),
          SizedBox(
            width: 4,
          ),
          GestureDetector(
            child: Icon(Icons.more_vert, color: colors.text.withOpacity(0.38)),
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => PostActionSheet(
                      parentContext: context,
                      user: widget.mail.participant,
                      postId: widget.mail.id,
                      shareData: ShareData(subject: '@${widget.mail.participant}', body: widget.mail.content, link: widget.mail.link),
                      flagPostCallback: (mailId) => MainRepository().settings.blockMail(mailId),
                    )),
          ),
        ],
      ),
      bottomWidget: widget.isPreview == true
          ? null
          : Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              GestureDetector(
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
    );
  }
}
