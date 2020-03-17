import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/components/post/PostFooterLink.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/LoggedUser.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/Image.dart' as model;
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

enum LAYOUT_TYPES { textOnly, oneImageOnly, attachmentsOnly, attachmentsAndText }

typedef Widget TLayout();

class PostListItem extends StatefulWidget {
  final Post post;
  final bool _isPreview;
  final bool _isHighlighted;
  final Map<LAYOUT_TYPES, TLayout> _layoutMap = {};
  final Function onUpdate;

  PostListItem(this.post, {this.onUpdate, isPreview = false, isHighlighted = false})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted {
    // The order here is important!
    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.textOnly,
        () => () {
              if (this.post.strippedContent.isNotEmpty && this.post.attachments.isEmpty) {
                return PostHtml(this.post);
              }
              return null;
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.oneImageOnly,
        () => () {
              if (!(this.post.strippedContent.isEmpty && this.post.attachments.length == 1 && this.post.images.length == 1)) {
                return null;
              }

              return PostHeroAttachment(
                this.post.images[0],
                this.post,
                crop: false,
              );
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsOnly,
        () => () {
              if (!(this.post.strippedContent.length == 0 && this.post.attachments.length > 1)) {
                return null;
              }

              var children = <Widget>[];
              this.post.attachments.forEach((attachment) {
                children.add(PostHeroAttachment(attachment, this.post));
              });

              return Wrap(children: children, spacing: 8, alignment: WrapAlignment.start);
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsAndText,
        () => () {
              if (!(this.post.attachments.length >= 1 && this.post.strippedContent.isNotEmpty)) {
                return null;
              }

              var children = <Widget>[];
              children.add(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Expanded(child: PostHtml(post)), PostHeroAttachment(post.attachmentsWithFeatured['featured'], this.post)],
              ));

              if ((post.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().length > 0) {
                children.add(() {
                  var children = (post.attachmentsWithFeatured['attachments'] as List).whereType<model.Image>().map((attachment) {
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: PostHeroAttachment(
                          attachment,
                          post,
                          size: 50.0,
                        ));
                  }).toList();
                  return Row(children: children, mainAxisAlignment: MainAxisAlignment.start);
                }());
              }

              children.addAll((post.attachmentsWithFeatured['attachments'] as List).whereType<Link>().map((attachment) {
                return PostFooterLink(attachment);
              }));

              return Column(
                children: children,
              );
            });
  }

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget._isPreview ? T.CARD_SHADOW_DECORATION : null,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: widget._isPreview != true,
            child: Divider(
              thickness: 8,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PostAvatar(
                  _post.nick,
                  isHighlighted: widget._isHighlighted,
                  description: getPostTime(),
                ),
                Row(
                  children: <Widget>[
                    Visibility(
                      visible: LoggedUser().nickname != _post.nick,
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
                      visible: _post.rating != 0 || LoggedUser().nickname != _post.nick,
                      child: Text(
                        _post.rating >= 0 ? '+${_post.rating}' : _post.rating.toString(),
                        style: TextStyle(color: _post.rating > 0 ? Colors.green : (_post.rating < 0 ? Colors.redAccent : Colors.black38)),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Visibility(
                      visible: LoggedUser().nickname != _post.nick,
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
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      child: Icon(
                        _post.hasReminder ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.black38,
                      ),
                      onTap: () {
                        setState(() => _post.hasReminder = !_post.hasReminder);
                        ApiController().setPostReminder(this._post.idKlub, this._post.id, _post.hasReminder).catchError((error) {
                          PlatformTheme.error(L.REMINDER_ERROR);
                          setState(() => _post.hasReminder = !_post.hasReminder);
                        });
                      },
                    ),
                    Visibility(
                      visible: widget._isPreview != true,
                      child: SizedBox(
                        width: 16,
                      ),
                    ),
                    Visibility(
                      visible: widget._isPreview != true,
                      child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/discussion/new-message', arguments: NewMessageSettings(_post.idKlub, post: _post, onClose: this.widget.onUpdate)),
                          child: Icon(
                            Icons.reply,
                            color: Colors.black38,
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: getContentWidget(context),
          ),
          Visibility(
            visible: FyxApp.isDev,
            child: Container(
              decoration: BoxDecoration(color: Colors.red),
              child: Text('A: ${_post.attachments.length} / '
                  'I: ${_post.images.length} / '
                  'L: ${_post.links.length} / '
                  'V: ${_post.videos.length} / '
                  'Html: ${_post.content.length} (${_post.strippedContent.length})'),
            ),
          ),
          Visibility(
            visible: FyxApp.isDev,
            child: Container(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(_post.content),
            ),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget getContentWidget(BuildContext context) {
    for (final layout in LAYOUT_TYPES.values) {
      var result = widget._layoutMap[layout]();
      if (result != null) {
        return result;
      }
    }

    // TODO: Doplnit text a odkaz.
    return Column(children: <Widget>[
      Icon(Icons.warning),
      Text(
        'Nastal problém se zobrazením příspěvku.\n Vyplňte prosím github issues.',
        textAlign: TextAlign.center,
      )
    ]);
  }

  String getPostTime() {
    var duration = Duration(seconds: ((DateTime.now().millisecondsSinceEpoch / 1000).floor() - _post.time));
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours}H';
    }
    if (duration.inDays < 30) {
      return '${duration.inDays}D';
    }

    var months = (duration.inDays / 30).round(); // Approx
    if (months < 12) {
      return '${months}M';
    }

    var years = (months / 12).round();
    return '${years}Y';
  }

  @override
  void didUpdateWidget(PostListItem oldWidget) {
    if (oldWidget.post != widget.post) {
      setState(() => _post = widget.post);
    }
    super.didUpdateWidget(oldWidget);
  }
}
