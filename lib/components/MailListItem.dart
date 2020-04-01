import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/post/PostAvatar.dart';
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
            Visibility(
              visible: isPreview != true,
              child: GestureDetector(
                child: T.ICO_REPLY,
                onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                    arguments: NewMessageSettings(
                        inputFieldPlaceholder: mail.participant,
                        hasInputField: true,
                        replyWidget: MailListItem(
                          mail,
                          isPreview: true,
                        ))),
              ),
            ),
          ],
        ));
  }
}
