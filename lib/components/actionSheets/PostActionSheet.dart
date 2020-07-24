import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';

class PostActionSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String user;
  final int postId;
  final Function flagPostCallback;

  PostActionSheet({Key key, this.user, this.postId, this.flagPostCallback, this.parentContext}) : super(key: key);

  @override
  _PostActionSheetState createState() => _PostActionSheetState();
}

class _PostActionSheetState extends State<PostActionSheet> {
  bool _reportIndicator = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
              child: Text('Blokovat uživatele ${widget.user}'),
              isDestructiveAction: true,
              onPressed: () {
                MainRepository().settings.blockUser(widget.user);
                Navigator.of(context).pop();
              }),
          CupertinoActionSheetAction(
              child: Text('Skrýt příspěvek'),
              isDestructiveAction: true,
              onPressed: () {
                widget.flagPostCallback(widget.postId);
                Navigator.pop(context);
              }),
          CupertinoActionSheetAction(
              child: _reportIndicator ? Text('⚠️ Nahlašuji...') : Text('⚠️ Nahlásit nevhodný obsah'),
              isDestructiveAction: true,
              onPressed: () async {
                try {
                  setState(() => _reportIndicator = true);
                  await ApiController().sendMail('FYXBOT', 'Inappropriate post/mail report: ID $widget.postId by user @$widget.user.');
                  PlatformTheme.success('Příspěvek byl nahlášen. Děkujeme, budeme se tomu věnovat.');
                } catch (error) {
                  PlatformTheme.error('Příspěvek se nepodařilo nahlásit, zkuste to znovu.');
                } finally {
                  setState(() => _reportIndicator = false);
                  Navigator.pop(context);
                }
              }),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text(L.GENERAL_CANCEL),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
  }
}
