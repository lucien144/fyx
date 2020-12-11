import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/TextIcon.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';

class PostAvatarActionSheet extends StatelessWidget {
  final String user;
  final int idKlub;

  const PostAvatarActionSheet({Key key, @required this.user, this.idKlub}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: TextIcon('Poslat zprávu', icon: Icons.mail),
          onPressed: () {
            Navigator.pop(context); // Close the sheet first.
            Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                arguments: NewMessageSettings(
                    hasInputField: true,
                    inputFieldPlaceholder: this.user,
                    onSubmit: (String inputField, String message, Map<ATTACHMENT, dynamic> attachment) async {
                      var response = await ApiController().sendMail(inputField, message, attachment: attachment);
                      return response.isOk;
                    }));
          },
        ),
        CupertinoActionSheetAction(
          child: TextIcon('Pouze příspěvky tohoto ID', icon: Icons.search),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(idKlub, filterByUser: this.user));
          },
        ),
        Visibility(
          visible: user != MainRepository().credentials.nickname,
          child: CupertinoActionSheetAction(
              child: TextIcon(
                '${L.POST_SHEET_BLOCK} @${user}',
                icon: Icons.block,
                iconColor: Colors.redAccent,
              ),
              isDestructiveAction: true,
              onPressed: () {
                MainRepository().settings.blockUser(user);
                PlatformTheme.success(L.TOAST_USER_BLOCKED);
                Navigator.of(context).pop();
                AnalyticsProvider().logEvent('blockUser');
              }),
        ),
      ],
    );
  }
}
