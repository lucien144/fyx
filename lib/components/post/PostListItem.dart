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
  final Map<LAYOUT_TYPES, TLayout> _layoutMap = {};
  final Function onUpdate;

  PostListItem(this.post, {this.onUpdate, isPreview = false}) : _isPreview = isPreview {
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
  bool hasReminder;

  @override
  void initState() {
    super.initState();
    hasReminder = widget.post.hasReminder;
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
                PostAvatar(widget.post.avatar, widget.post.nick),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.thumb_up,
                      color: widget.post.rating > 0 ? Colors.green : Colors.black38,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.post.rating.toString(),
                      style: TextStyle(color: widget.post.rating > 0 ? Colors.green : (widget.post.rating < 0 ? Colors.redAccent : Colors.black38)),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Icons.thumb_down,
                      color: widget.post.rating < 0 ? Colors.redAccent : Colors.black38,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      child: Icon(
                        hasReminder ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.black38,
                      ),
                      onTap: () {
                        ApiController().setPostReminder(this.widget.post.idKlub, this.widget.post.id, !hasReminder).catchError((error) {
                          PlatformTheme.error(L.REMINDER_ERROR);
                          setState(() => hasReminder = !hasReminder);
                        });
                        setState(() => hasReminder = !hasReminder);
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
                          onTap: () => Navigator.of(context)
                              .pushNamed('/discussion/new-message', arguments: NewMessageSettings(widget.post.idKlub, post: widget.post, onClose: this.widget.onUpdate)),
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
              child: Text('A: ${widget.post.attachments.length} / '
                  'I: ${widget.post.images.length} / '
                  'L: ${widget.post.links.length} / '
                  'V: ${widget.post.videos.length} / '
                  'Html: ${widget.post.content.length} (${widget.post.strippedContent.length})'),
            ),
          ),
          Visibility(
            visible: FyxApp.isDev,
            child: Container(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(widget.post.content),
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
}
