import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/components/bottom_sheets/post_context_menu.dart';
import 'package:fyx/components/content_box_layout.dart';
import 'package:fyx/components/gesture_feedback.dart';
import 'package:fyx/components/post/post_avatar.dart';
import 'package:fyx/components/post/post_rating.dart';
import 'package:fyx/components/text_icon.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/state/batch_actions_provider.dart';
import 'package:fyx/state/nsfw_provider.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostListItem extends ConsumerStatefulWidget {
  final Post post;
  final bool _isPreview;
  final bool _isHighlighted;
  final bool disabled;
  final Function? onUpdate;
  final Discussion? discussion;

  PostListItem(this.post, {this.discussion, this.onUpdate, this.disabled = false, isPreview = false, isHighlighted = false})
      : _isPreview = isPreview,
        _isHighlighted = isHighlighted;

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends ConsumerState<PostListItem> {
  Post? _post;
  bool get makeDense => MediaQuery.of(context).textScaleFactor > 1 || MediaQuery.of(context).size.width <= 375;

  bool get adminTools => !(widget.discussion?.accessRights.canRights == false || // Do not have rights
      widget.post.nick == MainRepository().credentials?.nickname || // ... or is post owner
      widget.post.nick == widget.discussion?.owner?.username); // ... or the post owner is discussion owner

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  void showPostContext() {
    showCupertinoModalBottomSheet(
        context: context,
        builder: (BuildContext context) => PostContextMenu<Post>(
            parentContext: context, item: _post!, adminTools: adminTools, flagPostCallback: (postId) => MainRepository().settings.blockPost(postId)));
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    final isSelected = ref.watch(PostsSelection.provider).contains(this._post!);
    final isDeleted = ref.watch(PostsToDelete.provider).contains(this._post!);

    return Visibility(
      visible: !isDeleted,
      child: Dismissible(
        key: UniqueKey(),
        direction: _post!.canBeDeleted ? DismissDirection.endToStart : DismissDirection.none,
        confirmDismiss: (_) {
          ref.read(PostsSelection.provider.notifier).toggle(this._post!);
          return Future.value(false);
        },
        background: Container(
          alignment: Alignment.centerRight,
          color: colors.highlightedText,
          padding: const EdgeInsets.all(32),
          child: Icon(
            isSelected ? MdiIcons.checkboxMarkedOutline : MdiIcons.checkboxBlankOutline,
            size: 32,
            color: colors.background,
          ),
        ),
        child: GestureDetector(
          onLongPress: showPostContext,
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            if (!_post!.canBeRated || !MainRepository().settings.quickRating) {
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
          child: ContentBoxLayout(
            isPreview: widget._isPreview,
            isHighlighted: widget._isHighlighted,
            isSelected: isSelected,
            blur: ref.watch(NsfwDiscussionList.provider).containsKey(_post!.idKlub),
            topLeftWidget: PostAvatar(
              _post!.nick,
              descriptionWidget: Row(
                children: [
                  if (_post!.rating != null)
                    Text('${Post.formatRating(_post!.rating!)} | ',
                        style: TextStyle(
                            fontSize: 10, color: _post!.rating! > 0 ? colors.success : (_post!.rating! < 0 ? colors.danger : colors.text))),
                  Text(
                    '${Helpers.absoluteTime(_post!.time)}',
                    style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10),
                  ),
                  Text(
                    ' ~${Helpers.relativeTime(_post!.time)}',
                    style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10),
                  ),
                  if (_post!.replies.length > 0)
                    Text(
                      ' | ${_post!.replies.length} ${Intl.plural(_post!.replies.length, one: 'odpověď', few: 'odpovědi', other: 'odpovědí', locale: 'cs_CZ')}',
                      style: TextStyle(color: colors.primary, fontSize: 10),
                    ),
                ],
              ),
            ),
            topRightWidget: widget.disabled ? Container() : GestureFeedback(child: Icon(Icons.more_vert, color: colors.text.withOpacity(0.38)), onTap: showPostContext),
            bottomWidget: widget.disabled ? null : Column(
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
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).pushNamed('/new-message',
                                  arguments: NewMessageSettings(
                                      replyWidget: PostListItem(
                                        _post!,
                                        isPreview: true,
                                        discussion: widget.discussion,
                                      ),
                                      onClose: this.widget.onUpdate,
                                      onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                                        var result = await ApiController()
                                            .postDiscussionMessage(_post!.idKlub, message, attachments: attachments, replyPost: _post);
                                        return result.isOk;
                                      })),
                              child: TextIcon(
                                makeDense ? '' : 'Odpovědět',
                                icon: MdiIcons.reply,
                                iconColor: colors.text.withOpacity(0.38),
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            content: _post!.content,
          ),
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
