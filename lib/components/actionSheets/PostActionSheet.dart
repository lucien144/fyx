import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/components/feedback_indicator.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/components/post/post_thumbs.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/model/post/ipost.dart';
import 'package:fyx/model/reponses/OkResponse.dart';
import 'package:fyx/model/reponses/PostRatingsResponse.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/state/batch_actions_provider.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class ShareData {
  final String subject;
  final Content body;
  final String link;

  ShareData({required this.subject, required this.body, required this.link});
}

class PostContextMenu<T extends IPost> extends ConsumerStatefulWidget {
  final T item;
  final bool adminTools;
  final BuildContext parentContext;
  final Function flagPostCallback;

  PostContextMenu({Key? key, required this.item, required this.flagPostCallback, required this.parentContext, this.adminTools = false})
      : super(key: key);

  @override
  _PostContextMenuState createState() => _PostContextMenuState();
}

class _PostContextMenuState extends ConsumerState<PostContextMenu<IPost>> {
  bool _reportIndicator = false;
  bool _reminderIndicator = false;
  bool _deleteIndicator = false;
  bool _bananaIndicator = false;
  SkinColors? colors;

  bool get isMail => widget.item is Mail;

  bool get isPost => widget.item is Post;

  Mail get mail => widget.item as Mail;

  Post get post => widget.item as Post;

  Widget createGridView({required List<Widget> children}) {
    return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 48),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        children: children);
  }

  void confirmationDialog(String title, String content, Function()? onPressed) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                CupertinoDialogAction(
                  child: Text('Ne'),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Ano'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (onPressed != null) onPressed();
                  },
                ),
              ],
            ));
  }

  Widget gridItem(String label, IconData? icon, {Function()? onTap, bool danger = false}) {
    return GestureDetector(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: danger ? colors?.danger.withOpacity(0.1) : colors?.barBackground, borderRadius: BorderRadius.circular(8)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(icon, size: 32, color: danger ? colors?.danger : colors?.primary),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: danger ? colors?.danger : colors?.primary),
            )
          ]),
        ),
        onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    colors = Skin.of(context).theme.colors;

    return createGridView(
      children: <Widget>[
        gridItem('Zkopírovat text', MdiIcons.contentCopy, onTap: () {
          var data = ClipboardData(text: widget.item.content.strippedContent);
          Clipboard.setData(data).then((_) {
            T.success(L.TOAST_COPIED, bg: colors!.success);
            Navigator.pop(context);
          });
          AnalyticsProvider().logEvent('copyPostBody');
        }),
        if (isPost)
          gridItem('Odpovědět soukromě', MdiIcons.reply, onTap: () {
            Navigator.pop(context); // Close the sheet first.
            Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                arguments: NewMessageSettings(
                    hasInputField: true,
                    inputFieldPlaceholder: post.nick,
                    messageFieldPlaceholder: post.link,
                    onClose: () => T.success('👍 Zpráva poslána.', bg: colors!.success),
                    onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                      if (inputField == null) return false;

                      var response = await ApiController().sendMail(inputField, message, attachments: attachments);
                      return response.isOk;
                    }));
          }),
        if (isPost && post.canBeReminded)
          FeedbackIndicator(
              isLoading: _reminderIndicator,
              child: gridItem(
                  post.hasReminder ? 'Odebrat z poznámek' : 'Uložit do poznámek', post.hasReminder ? MdiIcons.bookmark : MdiIcons.bookmarkOutline,
                  onTap: () {
                setState(() => _reminderIndicator = true);
                ApiController()
                    .setPostReminder(post.idKlub, post.id, !post.hasReminder)
                    .catchError((error) => T.error(L.REMINDER_ERROR, bg: colors!.danger))
                    .then((response) {
                  post.hasReminder = !post.hasReminder;
                }).whenComplete(() => setState(() => _reminderIndicator = false));
                AnalyticsProvider().logEvent(post.hasReminder ? 'reminder_remove' : 'reminder_add');
              })),
        if (isPost && post.replies.length > 0)
          gridItem(
              'Zobrazit\n${post.replies.length} ${Intl.plural(post.replies.length, one: 'odpověď', few: 'odpovědi', other: 'odpovědí', locale: 'cs_CZ')}',
              MdiIcons.timelineText, onTap: () {
            ApiController().loadDiscussion(post.idKlub, lastId: post.id, filterReplies: true).then((response) {
              final postItems = response.posts.map((item) => PostListItem(Post.fromJson(item, post.idKlub))).toList();
              showCupertinoModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      controller: ModalScrollController.of(context),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Container(child: PostListItem(post), color: colors!.primary.withOpacity(.1)),
                            ListView.builder(
                                itemBuilder: (context, index) {
                                  return postItems[index];
                                },
                                itemCount: postItems.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true),
                          ],
                        ),
                      ),
                    );
                  });
            });
            AnalyticsProvider().logEvent('filter_user_posts');
          }),
        if (isPost && post.rating != null)
          gridItem('Zobrazit palečky', MdiIcons.thumbsUpDown, onTap: () {
            showCupertinoModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24, left: 8, right: 8),
                    controller: ModalScrollController.of(context),
                    child: FutureBuilder(
                        future: Future.delayed(Duration(milliseconds: 300), () => ApiController().getPostRatings(post.idKlub, post.id)),
                        builder: (BuildContext context, AsyncSnapshot<PostRatingsResponse> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final positive = snapshot.data!.positive.map((e) => PostThumbItem(e.username)).toList();
                            final negative = snapshot.data!.negative_visible.map((e) => PostThumbItem(e.username)).toList();
                            final List<String> quotes = [
                              '“Affirmative, Dave. I read you.”\n\n..nic k zobrazení.',
                              '“I\'m sorry, Dave. I\'m afraid I can\'t do that.”\n\n..nic k zobrazení.',
                              '“Look Dave, I can see you\'re really upset about this. I honestly think you ought to sit down calmly, take a stress pill, and think things over.”\n\n..nic k zobrazení.',
                              '“Dave, stop. Stop, will you? Stop, Dave. Will you stop Dave? Stop, Dave.”\n\n..nic k zobrazení.',
                              '“Just what do you think you\'re doing, Dave?”\n\n..nic k zobrazení.',
                              '“Bishop takes Knight\'s Pawn.”\n\n..nic k zobrazení.',
                              '“I\'m sorry, Frank, I think you missed it. Queen to Bishop 3, Bishop takes Queen, Knight takes Bishop. Mate.”\n\n..nic k zobrazení.',
                              '“Thank you for a very enjoyable game.”\n\n..nic k zobrazení.',
                              '“I\'ve just picked up a fault in the AE35 unit. It\'s going to go 100% failure in 72 hours.”\n\n..nic k zobrazení.',
                              '“I know that you and Frank were planning to disconnect me, and I\'m afraid that\'s something I cannot allow to happen.”\n\n..nic k zobrazení.',
                            ]..shuffle();
                            return Column(
                              children: [
                                if (positive.length > 0) PostThumbs(positive),
                                if (negative.length > 0) PostThumbs(negative, isNegative: true),
                                if (positive.length + negative.length == 0)
                                  Text(
                                    quotes.first,
                                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center,
                                  )
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            T.error(snapshot.error.toString());
                            return Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Ouch. Něco se nepovedlo. Nahlaste chybu, prosím.',
                                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ));
                          }

                          return Padding(padding: const EdgeInsets.only(top: 16.0), child: CupertinoActivityIndicator(radius: 16));
                        }),
                  );
                });
          }),
        if (isPost)
          gridItem('Příspěvky @${post.nick}', MdiIcons.accountFilter, onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(post.idKlub, filterByUser: post.nick));
            AnalyticsProvider().logEvent('filter_user_posts');
          }),
        //gridItem('Vyhledat příspěvky', MdiIcons.accountSearch),
        gridItem(L.POST_SHEET_COPY_LINK, MdiIcons.link, onTap: () {
          var data = ClipboardData(text: widget.item.link);
          Clipboard.setData(data).then((_) {
            T.success(L.TOAST_COPIED, bg: colors!.success);
            Navigator.pop(context);
          });
          AnalyticsProvider().logEvent('copyLink');
        }),
        gridItem(L.POST_SHEET_SHARE, MdiIcons.shareVariant, onTap: () {
          String body = widget.item.content.strippedContent;
          if (body.isEmpty && widget.item.content.images.length > 0) {
            body = widget.item.content.images.fold('', (previousValue, element) => '$previousValue ${element.image}').trim();
          }
          if (body.isEmpty && widget.item.content.videos.length > 0) {
            body = widget.item.content.videos.fold('', (previousValue, element) => '$previousValue ${element.link}').trim();
          }

          final RenderBox box = context.findRenderObject() as RenderBox;
          Share.share(body, subject: isPost ? post.nick : mail.participant, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
          Navigator.pop(context);
          AnalyticsProvider().logEvent('shareSheet');
        }),
        gridItem('Více', MdiIcons.skull, danger: true, onTap: () {
          showCupertinoModalBottomSheet(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, StateSetter setState) => createGridView(children: <Widget>[
                    if (isPost && post.canBeDeleted)
                      FeedbackIndicator(
                        isLoading: _deleteIndicator,
                        child: gridItem('Smazat', MdiIcons.delete, danger: true, onTap: () {
                          confirmationDialog('Smazat?', 'Skutečně smazat příspěvěk od @${post.nick}?', () async {
                            try {
                              setState(() => _deleteIndicator = true);
                              await ApiController().deleteDiscussionMessage(post.idKlub, post.id);
                              ref.read(PostsToDelete.provider.notifier).add(post);
                              ref.read(PostsSelection.provider.notifier).remove(post);
                              T.success('Smazáno.');

                              int counter = 0;
                              Navigator.popUntil(context, (route) => counter++ == 2);
                            } catch (error) {
                              T.warn('Některé příspěvky se nepodařilo smazat.');
                            } finally {
                              setState(() => _deleteIndicator = false);
                            }
                          });
                        }),
                      ),
                    if (isPost && post.canBeDeleted && widget.adminTools)
                      FeedbackIndicator(
                        isLoading: _bananaIndicator,
                        child: gridItem('Smazat\n+ RO (30)', MdiIcons.pencilLock, danger: true, onTap: () async {
                          try {
                            setState(() => _bananaIndicator = true);
                            List<OkResponse> response = await Future.wait([
                              ApiController().setDiscussionRights(post.idKlub, username: post.nick, right: 'write', set: false),
                              ApiController().setDiscussionRightsDaysLeft(post.idKlub, username: post.nick, daysLeft: 30),
                              ApiController().deleteDiscussionMessage(post.idKlub, post.id)
                            ]);

                            if (response[2].isOk) {
                              T.success('Smazáno a RO na 30 dní uděleno.');
                              ref.read(PostsToDelete.provider.notifier).add(post);
                              ref.read(PostsSelection.provider.notifier).remove(post);
                            } else {
                              T.success('RO na 30 dní uděleno.');
                            }
                            int counter = 0;
                            Navigator.popUntil(context, (route) => counter++ == 2);
                          } catch (error) {
                            T.warn('Při udělení RO a mazání se něco pokazilo.');
                          } finally {
                            setState(() => _bananaIndicator = false);
                          }
                        }),
                      ),
                    if (widget.item.nick != MainRepository().credentials!.nickname)
                      gridItem('${L.POST_SHEET_BLOCK} @${widget.item.nick}', MdiIcons.accountCancel,
                          danger: true,
                          onTap: () => confirmationDialog('Blokovat uživatele?', 'Skutečně chcete blokovat ID @${widget.item.nick}?', () {
                                MainRepository().settings.blockUser(widget.item.nick);
                                T.success(L.TOAST_USER_BLOCKED, bg: colors!.success);
                                int counter = 0;
                                Navigator.popUntil(context, (route) => counter++ == 2);
                                AnalyticsProvider().logEvent('blockUser');
                              })),
                    gridItem(L.POST_SHEET_HIDE, MdiIcons.eyeOff, danger: true, onTap: () {
                      widget.flagPostCallback(widget.item.id);
                      T.success(L.TOAST_POST_HIDDEN, bg: colors!.success);
                      Navigator.pop(context);
                      AnalyticsProvider().logEvent('hidePost');
                    }),
                    gridItem(_reportIndicator ? L.POST_SHEET_FLAG_SAVING : L.POST_SHEET_FLAG, MdiIcons.alertDecagram, danger: true, onTap: () async {
                      try {
                        setState(() => _reportIndicator = true);
                        await ApiController().sendMail('FYXBOT', 'Inappropriate post/mail report: ${widget.item.link}.');
                        T.success(L.TOAST_POST_FLAGGED, bg: colors!.success);
                      } catch (error) {
                        T.error(L.TOAST_POST_FLAG_ERROR, bg: colors!.danger);
                      } finally {
                        setState(() => _reportIndicator = false);
                        Navigator.pop(context);
                        AnalyticsProvider().logEvent('flagContent');
                      }
                    }),
                  ]),
                );
              });
        })
      ],
    );
  }
}
