import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/actionSheets/PostActionSheet.dart';
import 'package:fyx/components/actionSheets/PostAvatarActionSheet.dart';
import 'package:fyx/components/content_box_layout.dart';
import 'package:fyx/components/feedback_indicator.dart';
import 'package:fyx/components/gesture_feedback.dart';
import 'package:fyx/components/post/post_avatar.dart';
import 'package:fyx/components/post/post_rating.dart';
import 'package:fyx/components/post/post_thumbs.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/notifications/LoadRatingsNotification.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/model/reponses/PostRatingsResponse.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/IconReply.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class PostDeleteFailNotification extends Notification {}

class PostListItem extends StatefulWidget {
  final Post post;
  final bool _isPreview;
  final bool _isHighlighted;
  final Function? onUpdate;

  PostListItem(this.post, {this.onUpdate, isPreview = false, isHighlighted = false})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted;

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  Post? _post;
  bool _isSaving = false;
  bool _showRatings = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Dismissible(
      key: UniqueKey(),
      direction: _post!.canBeDeleted ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (direction) {
        ApiController().deleteDiscussionMessage(_post!.idKlub, _post!.id).then((response) {
          T.success('👍 Smazáno', bg: colors.success);
        }).onError((error, stackTrace) {
          PostDeleteFailNotification().dispatch(context);
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        color: colors.danger,
        padding: const EdgeInsets.all(32),
        child: Icon(
          Icons.delete,
          size: 32,
          color: colors.background,
        ),
      ),
      child: GestureDetector(
        onDoubleTap: () {
          if (!_post!.canBeRated) {
            return null;
          }

          ApiController().giveRating(_post!.idKlub, _post!.id, remove: _post!.myRating != 'none').then((response) {
            if (_post!.myRating != 'none') {
              T.success('👎', bg: colors.success);
            } else {
              T.success('👍', bg: colors.success);
            }
            setState(() {
              _post!.rating = response.currentRating;
              _post!.myRating = response.myRating;
            });
          }).catchError((error) {
            print(error);
            T.error(L.RATING_ERROR, bg: colors.danger);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: ContentBoxLayout(
          isPreview: widget._isPreview,
          isHighlighted: widget._isHighlighted,
          topLeftWidget: GestureFeedback(
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => PostAvatarActionSheet(
                      user: _post!.nick,
                      idKlub: _post!.idKlub,
                    )),
            child: PostAvatar(
              _post!.nick,
              descriptionWidget: Row(
                children: [
                  if (_post!.rating != null)
                    Text(Post.formatRating(_post!.rating!),
                        style:
                            TextStyle(fontSize: 10, color: _post!.rating! > 0 ? colors.success : (_post!.rating! < 0 ? colors.danger : colors.text))),
                  if (_post!.rating != null) SizedBox(width: 8),
                  Text(
                    Helpers.absoluteTime(_post!.time),
                    style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '~${Helpers.relativeTime(_post!.time)}',
                    style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10),
                  )
                ],
              ),
            ),
          ),
          topRightWidget: GestureDetector(
              child: Icon(Icons.more_vert, color: colors.text.withOpacity(0.38)),
              onTap: () => showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => PostActionSheet(
                      parentContext: context,
                      user: _post!.nick,
                      postId: _post!.id,
                      shareData: ShareData(subject: '@${_post!.nick}', body: _post!.content, link: _post!.link),
                      flagPostCallback: (postId) => MainRepository().settings.blockPost(postId)))),
          bottomWidget: NotificationListener(
            onNotification: (LoadRatingsNotification notification) {
              setState(() => _showRatings = !_showRatings);
              return true;
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PostRating(_post!, onRatingChange: (post) => setState(() => _post = post)),
                    Row(
                      children: <Widget>[
                        Visibility(
                          visible: widget._isPreview != true && _post!.canReply,
                          child: GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed('/new-message',
                                  arguments: NewMessageSettings(
                                      replyWidget: PostListItem(
                                        _post!,
                                        isPreview: true,
                                      ),
                                      onClose: this.widget.onUpdate,
                                      onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                                        var result = await ApiController()
                                            .postDiscussionMessage(_post!.idKlub, message, attachments: attachments, replyPost: _post);
                                        return result.isOk;
                                      })),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconReply(),
                                  Text('Odpovědět', style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 14))
                                ],
                              )),
                        ),
                        Visibility(
                          visible: widget._isPreview != true,
                          child: SizedBox(
                            width: 16,
                          ),
                        ),
                        if (_post!.canBeReminded)
                          GestureDetector(
                            child: FeedbackIndicator(
                              isLoading: _isSaving,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    _post!.hasReminder ? Icons.bookmark : Icons.bookmark_border,
                                    color: colors.text.withOpacity(0.38),
                                  ),
                                  Text('Uložit', style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 14))
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _post!.hasReminder = !_post!.hasReminder;
                                _isSaving = true;
                              });
                              ApiController().setPostReminder(_post!.idKlub, _post!.id, _post!.hasReminder).catchError((error) {
                                T.error(L.REMINDER_ERROR, bg: colors.danger);
                                setState(() => _post!.hasReminder = !_post!.hasReminder);
                              }).whenComplete(() => setState(() => _isSaving = false));
                              AnalyticsProvider().logEvent('reminder');
                            },
                          )
                      ],
                    )
                  ],
                ),
                if (_showRatings)
                  FutureBuilder(
                      future: ApiController().getPostRatings(_post!.idKlub, _post!.id),
                      builder: (BuildContext context, AsyncSnapshot<PostRatingsResponse> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final positive = snapshot.data!.positive.map((e) => PostThumbItem(e.username)).toList();
                          final negative = snapshot.data!.negative_visible.map((e) => PostThumbItem(e.username)).toList();
                          final List<String> quotes = [
                            '“Affirmative, Dave. I read you.”',
                            '“I\'m sorry, Dave. I\'m afraid I can\'t do that.”',
                            '“Look Dave, I can see you\'re really upset about this. I honestly think you ought to sit down calmly, take a stress pill, and think things over.”',
                            '“Dave, stop. Stop, will you? Stop, Dave. Will you stop Dave? Stop, Dave.”',
                            '“Just what do you think you\'re doing, Dave?”',
                            '“Bishop takes Knight\'s Pawn.”',
                            '“I\'m sorry, Frank, I think you missed it. Queen to Bishop 3, Bishop takes Queen, Knight takes Bishop. Mate.”',
                            '“Thank you for a very enjoyable game.”',
                            '“I\'ve just picked up a fault in the AE35 unit. It\'s going to go 100% failure in 72 hours.”',
                            '“I know that you and Frank were planning to disconnect me, and I\'m afraid that\'s something I cannot allow to happen.”',
                          ]..shuffle();
                          return Column(
                            children: [
                              if (positive.length > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: PostThumbs(positive),
                                ),
                              if (negative.length > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: PostThumbs(negative, isNegative: true),
                                ),
                              if (positive.length + negative.length == 0)
                                Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      quotes.first,
                                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                    ))
                            ],
                          );
                        }

                        if (snapshot.hasError) {
                          T.error(snapshot.error.toString());
                          return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'Ouch. Něco se nepovedlo. Nahlaste chybu, prosím.',
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ));
                        }

                        return Padding(padding: const EdgeInsets.only(top: 12.0), child: CupertinoActivityIndicator());
                      })
              ],
            ),
          ),
          content: _post!.content,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(PostListItem oldWidget) {
    if (oldWidget.post != widget.post) {
      setState(() => _post = widget.post);
    }
    super.didUpdateWidget(oldWidget);
  }
}
