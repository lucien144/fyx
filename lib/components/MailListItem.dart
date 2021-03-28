import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/actionSheets/PostActionSheet.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';

class MailListItem extends StatefulWidget {
  final Mail mail;
  final bool isPreview;

  const MailListItem(this.mail, {this.isPreview});

  @override
  _MailListItemState createState() => _MailListItemState();
}

class _MailListItemState extends State<MailListItem> {
  @override
  Widget build(BuildContext context) {
    return ContentBoxLayout(
      isHighlighted: widget.mail.isNew,
      isPreview: widget.isPreview == true,
      content: widget.mail.content,
      topLeftWidget: PostAvatar(
        widget.mail.direction == MailDirection.from ? widget.mail.participant : MainRepository().credentials.nickname,
        description: '→ ${widget.mail.direction == MailDirection.to ? widget.mail.participant : MainRepository().credentials.nickname}, ~${Helpers.parseTime(widget.mail.time)}'
      ),
      topRightWidget: Row(
        children: <Widget>[
          Visibility(
            visible: widget.mail.isUnread,
            child: T.ICO_UNREAD,
          ),
          SizedBox(
            width: 4,
          ),
          GestureDetector(
            child: Icon(Icons.more_vert, color: Colors.black38),
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
                  children: <Widget>[T.ICO_REPLY, Text('Odpovědět', style: TextStyle(color: Colors.black38, fontSize: 14))],
                ),
                onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                    arguments: NewMessageSettings(
                        onSubmit: (String inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                          var response = await ApiController().sendMail(inputField, message, attachments: attachments);
                          return response.isOk;
                        },
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
