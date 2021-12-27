import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/components/TextIcon.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:share/share.dart';

class ShareData {
  final String subject;
  final Content body;
  final String link;

  ShareData({required this.subject, required this.body, required this.link});
}

class PostActionSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String user;
  final int postId;
  final Function flagPostCallback;
  final ShareData shareData;

  PostActionSheet({Key? key, required this.user, required this.postId, required this.flagPostCallback, required this.parentContext, required this.shareData}) : super(key: key);

  @override
  _PostActionSheetState createState() => _PostActionSheetState();
}

class _PostActionSheetState extends State<PostActionSheet> {
  bool _reportIndicator = false;

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return CupertinoActionSheet(
        actions: <Widget>[
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: TextIcon(L.POST_SHEET_COPY_LINK, icon: Icons.link),
                onPressed: () {
                  var data = ClipboardData(text: widget.shareData.link);
                  Clipboard.setData(data).then((_) {
                    T.success(L.TOAST_COPIED);
                    Navigator.pop(context);
                  });
                  AnalyticsProvider().logEvent('copyLink');
                }),
          ),
          Visibility(
            visible: widget.shareData is ShareData,
            child: CupertinoActionSheetAction(
                child: TextIcon(
                  L.POST_SHEET_SHARE,
                  icon: Icons.share,
                ),
                onPressed: () {
                  String body = widget.shareData.body.strippedContent;
                  if (body.isEmpty && widget.shareData.body.images.length > 0) {
                    body = widget.shareData.body.images.fold('', (previousValue, element) => '$previousValue ${element.image}').trim();
                  }
                  if (body.isEmpty && widget.shareData.body.videos.length > 0) {
                    body = widget.shareData.body.videos.fold('', (previousValue, element) => '$previousValue ${element.link}').trim();
                  }

                  final RenderBox box = context.findRenderObject() as RenderBox;
                  Share.share(body, subject: widget.shareData.subject, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                  Navigator.pop(context);
                  AnalyticsProvider().logEvent('shareSheet');
                }),
          ),
          CupertinoActionSheetAction(
              child: TextIcon(
                L.POST_SHEET_HIDE,
                icon: Icons.visibility_off,
                iconColor: colors.dangerColor,
              ),
              isDestructiveAction: true,
              onPressed: () {
                widget.flagPostCallback(widget.postId);
                T.success(L.TOAST_POST_HIDDEN);
                Navigator.pop(context);
                AnalyticsProvider().logEvent('hidePost');
              }),
          CupertinoActionSheetAction(
              child: TextIcon(
                _reportIndicator ? L.POST_SHEET_FLAG_SAVING : L.POST_SHEET_FLAG,
                icon: Icons.warning,
                iconColor: colors.dangerColor,
              ),
              isDestructiveAction: true,
              onPressed: () async {
                try {
                  setState(() => _reportIndicator = true);
                  await ApiController().sendMail('FYXBOT', 'Inappropriate post/mail report: ID ${widget.postId} by user @${widget.user}.');
                  T.success(L.TOAST_POST_FLAGGED);
                } catch (error) {
                  T.error(L.TOAST_POST_FLAG_ERROR);
                } finally {
                  setState(() => _reportIndicator = false);
                  Navigator.pop(context);
                  AnalyticsProvider().logEvent('flagContent');
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
