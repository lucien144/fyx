import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/FeedbackIndicator.dart';
import 'package:fyx/components/actionSheets/PostActionSheet.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/components/post/PostRating.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
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
  bool _isSaving = false;

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
          onTap: () => showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => PostActionSheet(
                  parentContext: context,
                  user: _post.nick,
                  postId: _post.id,
                  shareData: ShareData(subject: '@${_post.nick}', body: _post.content, link: _post.link),
                  flagPostCallback: (postId) => MainRepository().settings.blockPost(postId)))),
      bottomWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          PostRating(_post),
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
                child: FeedbackIndicator(
                  isLoading: _isSaving,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _post.hasReminder ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.black38,
                      ),
                      Text('Uložit', style: TextStyle(color: Colors.black38, fontSize: 14))
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _post.hasReminder = !_post.hasReminder;
                    _isSaving = true;
                  });
                  ApiController().setPostReminder(this._post.idKlub, this._post.id, _post.hasReminder).catchError((error) {
                    PlatformTheme.error(L.REMINDER_ERROR);
                    setState(() => _post.hasReminder = !_post.hasReminder);
                  }).whenComplete(() => setState(() => _isSaving = false));
                  AnalyticsProvider().logEvent('reminder');
                },
              )
            ],
          )
        ],
      ),
      content: _post.content,
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
