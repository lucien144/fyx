import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:share/share.dart';

class ShareData {
  final String subject;
  final String body;
  final String link;

  ShareData({this.subject, this.body, this.link});
}

class PostActionSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String user;
  final int postId;
  final Function flagPostCallback;
  final ShareData shareData;

  PostActionSheet({Key key, this.user, this.postId, this.flagPostCallback, this.parentContext, this.shareData}) : super(key: key);

  @override
  _PostActionSheetState createState() => _PostActionSheetState();
}

class _PostActionSheetState extends State<PostActionSheet> {
  bool _reportIndicator = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
        actions: <Widget>[
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: Text('Kopírovat link'),
                onPressed: () {
                  var data = ClipboardData(text: widget.shareData.link);
                  Clipboard.setData(data).then((_) {
                    Navigator.pop(context);
                  });
                }),
          ),
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: Text('Sdílet'),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(widget.shareData.body, subject: widget.shareData.subject, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                  Navigator.pop(context);
                }),
          ),
          Visibility(
            visible: widget.user != MainRepository().credentials.nickname,
            child: CupertinoActionSheetAction(
                child: Text('Blokovat uživatele ${widget.user}'),
                isDestructiveAction: true,
                onPressed: () {
                  MainRepository().settings.blockUser(widget.user);
                  Navigator.of(context).pop();
                }),
          ),
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
