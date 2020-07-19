import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class PostListItem extends StatefulWidget {
  final Post post;
  final bool _isPreview;
  final bool _isHighlighted;
  final Function onUpdate;

  PostListItem(this.post, {this.onUpdate, isPreview = false, isHighlighted = false})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted;

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  Post _post;
  bool _reportIndicator = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return ContentBoxLayout(
      isPreview: widget._isPreview,
      isHighlighted: widget._isHighlighted,
      topLeftWidget: PostAvatar(
        _post.nick,
        isHighlighted: widget._isHighlighted,
        description: T.parseTime(_post.time),
      ),
      topRightWidget: GestureDetector(
          child: Icon(Icons.more_vert, color: Colors.black38),
          onTap: () => showCupertinoModalPopup(context: context, builder: (BuildContext context) => actionSheet(context, _post.nick, _post.id))),
      bottomWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Visibility(
                visible: MainRepository().credentials.nickname != _post.nick,
                child: GestureDetector(
                  child: Icon(
                    Icons.thumb_up,
                    color: _post.rating > 0 ? Colors.green : Colors.black38,
                  ),
                  onTap: () {
                    ApiController().giveRating(_post.idKlub, _post.id).then((response) {
                      setState(() => _post.rating = response.currentRating);
                    }).catchError((error) {
                      print(error);
                      PlatformTheme.error(L.RATING_ERROR);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Visibility(
                visible: _post.rating != 0 || MainRepository().credentials.nickname != _post.nick,
                child: Text(
                  _post.rating > 0 ? '+${_post.rating}' : _post.rating.toString(),
                  style: TextStyle(fontSize: 14, color: _post.rating > 0 ? Colors.green : (_post.rating < 0 ? Colors.redAccent : Colors.black38)),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Visibility(
                visible: MainRepository().credentials.nickname != _post.nick,
                child: GestureDetector(
                  child: Icon(
                    Icons.thumb_down,
                    color: _post.rating < 0 ? Colors.redAccent : Colors.black38,
                  ),
                  onTap: () {
                    ApiController().giveRating(_post.idKlub, _post.id, positive: false).then((response) {
                      if (response.needsConfirmation) {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) => new CupertinoAlertDialog(
                            title: new Text(L.GENERAL_WARNING),
                            content: new Text(L.RATING_CONFIRMATION),
                            actions: [
                              CupertinoDialogAction(
                                child: new Text(L.GENERAL_CANCEL),
                                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                              ),
                              CupertinoDialogAction(
                                  isDefaultAction: true,
                                  isDestructiveAction: true,
                                  child: new Text("Hodnotit"),
                                  onPressed: () {
                                    ApiController().giveRating(_post.idKlub, _post.id, positive: false, confirm: true).then((response) {
                                      setState(() => _post.rating = response.currentRating);
                                    }).catchError((error) {
                                      print(error);
                                      PlatformTheme.error(L.RATING_ERROR);
                                    }).whenComplete(() => Navigator.of(context, rootNavigator: true).pop());
                                  })
                            ],
                          ),
                        );
                      } else {
                        setState(() => _post.rating = response.currentRating);
                      }
                    }).catchError((error) {
                      print(error);
                      PlatformTheme.error(L.RATING_ERROR);
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Visibility(
                visible: widget._isPreview != true,
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/new-message',
                        arguments: NewMessageSettings(
                            replyWidget: PostListItem(
                              _post,
                              isPreview: true,
                            ),
                            onClose: this.widget.onUpdate,
                            onSubmit: (String inputField, String message, Map<String, dynamic> attachment) async {
                              var result = await ApiController().postDiscussionMessage(_post.idKlub, message, attachment: attachment, replyPost: _post);
                              return result.isOk;
                            })),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[T.ICO_REPLY, Text('Odpovědět', style: TextStyle(color: Colors.black38, fontSize: 14))],
                    )),
              ),
              Visibility(
                visible: widget._isPreview != true,
                child: SizedBox(
                  width: 16,
                ),
              ),
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Icon(
                      _post.hasReminder ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.black38,
                    ),
                    Text('Uložit', style: TextStyle(color: Colors.black38, fontSize: 14))
                  ],
                ),
                onTap: () {
                  setState(() => _post.hasReminder = !_post.hasReminder);
                  ApiController().setPostReminder(this._post.idKlub, this._post.id, _post.hasReminder).catchError((error) {
                    PlatformTheme.error(L.REMINDER_ERROR);
                    setState(() => _post.hasReminder = !_post.hasReminder);
                  });
                },
              )
            ],
          )
        ],
      ),
      content: _post.content,
    );
  }

  Widget actionSheet(BuildContext context, String user, int postId) {
    return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
              child: Text('Blokovat uživatele'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              }),
          CupertinoActionSheetAction(
              child: Text('Skrýt příspěvek'),
              isDestructiveAction: true,
              onPressed: () {
                MainRepository().settings.blockPost(postId);
                Navigator.pop(context);
              }),
          CupertinoActionSheetAction(
              child: _reportIndicator ? Text('⚠️ Nahlašuji...') : Text('⚠️ Nahlásit'),
              isDestructiveAction: true,
              onPressed: () async {
                try {
                  setState(() => _reportIndicator = true);
                  await ApiController().sendMail('FYXBOT', 'Inappropriate post reportr: ID $postId by user @$user.');
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

  @override
  void didUpdateWidget(PostListItem oldWidget) {
    if (oldWidget.post != widget.post) {
      setState(() => _post = widget.post);
    }
    super.didUpdateWidget(oldWidget);
  }
}
