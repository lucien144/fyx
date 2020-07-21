import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/T.dart';

class MailListItem extends StatelessWidget {
  final Mail mail;
  final bool isPreview;

  const MailListItem(this.mail, {this.isPreview});

  @override
  Widget build(BuildContext context) {
    return ContentBoxLayout(
      isPreview: isPreview == true,
      content: mail.content,
      topLeftWidget: PostAvatar(
        mail.direction == MailDirection.from ? mail.participant : MainRepository().credentials.nickname,
        description: '→ ${mail.direction == MailDirection.to ? mail.participant : MainRepository().credentials.nickname}, ~${T.parseTime(mail.time)}',
        isHighlighted: mail.isNew,
      ),
      topRightWidget: Row(
        children: <Widget>[
          Visibility(
            visible: mail.isUnread,
            child: T.ICO_UNREAD,
          ),
          SizedBox(
            width: 4,
          ),
          GestureDetector(
            child: Icon(Icons.more_vert, color: Colors.black38),
            onTap: () => null,
          ),
        ],
      ),
      bottomWidget: isPreview == true
          ? null
          : Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[T.ICO_REPLY, Text('Odpovědět', style: TextStyle(color: Colors.black38, fontSize: 14))],
                ),
                onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                    arguments: NewMessageSettings(
                        onSubmit: (String inputField, String message, Map<String, dynamic> attachment) async {
                          var response = await ApiController().sendMail(inputField, message, attachment: attachment);
                          return response.isOk;
                        },
                        inputFieldPlaceholder: mail.participant,
                        hasInputField: true,
                        replyWidget: MailListItem(
                          mail,
                          isPreview: true,
                        ))),
              )
            ]),
    );
  }
}
