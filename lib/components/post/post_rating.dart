import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/bottom_sheets/post_rating_sheet.dart';
import 'package:fyx/components/feedback_indicator.dart';
import 'package:fyx/components/gesture_feedback.dart';
import 'package:fyx/components/post/rating_value.dart';
import 'package:fyx/components/text_icon.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostRating extends StatefulWidget {
  final Post post;
  Function? onRatingChange;

  PostRating(this.post, {Key? key, this.onRatingChange}) : super(key: key);

  @override
  _PostRatingState createState() => _PostRatingState();
}

class _PostRatingState extends State<PostRating> {
  Post? _post;
  bool _givingRating = false;

  bool get makeDense => MediaQuery.of(context).textScaleFactor > 1 || MediaQuery.of(context).size.width <= 375;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void didUpdateWidget(PostRating oldWidget) {
    if (oldWidget.post != widget.post) {
      setState(() => _post = widget.post);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Expanded(
      child: FeedbackIndicator(
        isLoading: _givingRating,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureFeedback(
              onTap: () => showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return PostRatingBottomSheet(_post!);
                  }),
              child: Opacity(
                opacity: _givingRating ? 0 : (_post!.rating == null ? .2 : 1),
                child: RatingValue(_post!.rating),
              ),
            ),
            if (_post!.canBeRated)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: TextIcon(
                  makeDense ? '' : 'Paleček',
                  icon: MdiIcons.thumbUpOutline,
                  iconColor: _post!.myRating == 'positive' ? colors.primary : colors.text.withOpacity(0.38),
                ),
                onTap: _givingRating
                    ? null
                    : () {
                        setState(() => _givingRating = true);
                        ApiController().giveRating(_post!.idKlub, _post!.id, remove: _post!.myRating == 'positive').then((response) {
                          setState(() {
                            _post!.rating = response.currentRating;
                            _post!.myRating = response.myRating;
                          });
                          if (widget.onRatingChange != null) {
                            widget.onRatingChange!(_post);
                          }
                        }).catchError((error) {
                          print(error);
                          T.error(L.RATING_ERROR, bg: colors.danger);
                        }).whenComplete(() => setState(() => _givingRating = false));
                      },
              ),
            if (_post!.canBeRated)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: TextIcon(
                  makeDense ? '' : 'Mínusko',
                  icon: MdiIcons.thumbDownOutline,
                  iconColor: ['negative', 'negative_visible'].contains(_post!.myRating) ? Color.alphaBlend(colors.primary, colors.danger) : colors.text.withOpacity(0.38),
                ),
                onTap: _givingRating
                    ? null
                    : () {
                        setState(() => _givingRating = true);
                        ApiController().giveRating(_post!.idKlub, _post!.id, positive: false, remove: _post!.myRating.startsWith('negative')).then((response) {
                          if (response.needsConfirmation) {
                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) => new CupertinoAlertDialog(
                                title: new Text(L.GENERAL_WARNING),
                                content: new Text(L.RATING_CONFIRMATION),
                                actions: [
                                  CupertinoDialogAction(
                                    child: new Text(L.GENERAL_CANCEL),
                                    onPressed: () {
                                      setState(() => _givingRating = false);
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                      isDefaultAction: true,
                                      isDestructiveAction: true,
                                      child: new Text('Hodnotit'),
                                      onPressed: () {
                                        ApiController()
                                            .giveRating(_post!.idKlub, _post!.id, positive: false, confirm: true, remove: _post!.myRating != 'none')
                                            .then((response) {
                                          setState(() {
                                            _post!.rating = response.currentRating;
                                            _post!.myRating = response.myRating;
                                          });
                                          if (widget.onRatingChange != null) {
                                            widget.onRatingChange!(_post);
                                          }
                                        }).catchError((error) {
                                          print(error);
                                          T.error(L.RATING_ERROR, bg: colors.danger);
                                        }).whenComplete(() {
                                          setState(() => _givingRating = false);
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      })
                                ],
                              ),
                            );
                          } else {
                            setState(() {
                              _post!.rating = response.currentRating;
                              _post!.myRating = response.myRating;
                              _givingRating = false;
                            });
                            if (widget.onRatingChange != null) {
                              widget.onRatingChange!(_post);
                            }
                          }
                        }).catchError((error) {
                          setState(() => _givingRating = false);
                          T.error(L.RATING_ERROR, bg: colors.danger);
                        });
                      },
              ),
            SizedBox()
          ],
        ),
      ),
    );
  }
}
