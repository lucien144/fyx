import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/bottom_sheets/post_rating_sheet.dart';
import 'package:fyx/components/feedback_indicator.dart';
import 'package:fyx/components/gesture_feedback.dart';
import 'package:fyx/components/post/rating_value.dart';
import 'package:fyx/components/text_icon.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/shared/services/service_locator.dart' as DI;
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

  bool get makeDense => MediaQuery.textScaleFactorOf(context) > 1 || MediaQuery.sizeOf(context).width <= 375;
  bool get isVelvetTime => DateTime.now().day == 17 && DateTime.now().month == 11;

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

  Widget _thumbsUp(SkinColors colors) {
    if (this.isVelvetTime) {
      return TextIcon(
        makeDense ? '' : 'Pravda & láska',
        icon: MdiIcons.handPeaceVariant,
        iconColor: _post!.myRating == 'positive' ? colors.primary : colors.text.withOpacity(0.38),
        shader: _post!.myRating == 'positive' ? true : false,
      );
    }

    return TextIcon(
      makeDense ? '' : 'Paleček',
      icon: MdiIcons.thumbUpOutline,
      iconColor: _post!.myRating == 'positive' ? colors.primary : colors.text.withOpacity(0.38),
    );
  }


  _saveLikingStats(bool like, bool remove) {
    if (like) {
      DI.userstatsRepo.upsertGlobalStat(GlobalStat(year: DateTime.now().year, statType: GlobalStatType.likes.value, number: remove ? -1 : 1));
    } else {
      DI.userstatsRepo.upsertGlobalStat(GlobalStat(year: DateTime.now().year, statType: GlobalStatType.dislikes.value, number: remove ? -1 : 1));
    }
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
                child: _thumbsUp(colors),
                onTap: _givingRating
                    ? null
                    : () {
                        setState(() => _givingRating = true);
                        var removing = _post!.myRating == 'positive';
                        ApiController().giveRating(_post!.idKlub, _post!.id, remove: removing).then((response) {
                          setState(() {
                            _post!.rating = response.currentRating;
                            _post!.myRating = response.myRating;
                          });
                          if (widget.onRatingChange != null) {
                            widget.onRatingChange!(_post);
                            _saveLikingStats(true, removing);
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
                  makeDense || this.isVelvetTime ? '' : 'Mínusko',
                  icon: MdiIcons.thumbDownOutline,
                  iconColor: ['negative', 'negative_visible'].contains(_post!.myRating) ? Color.alphaBlend(colors.primary, colors.danger) : colors.text.withOpacity(0.38),
                ),
                onTap: _givingRating
                    ? null
                    : () {
                        setState(() => _givingRating = true);
                        var removing = _post!.myRating.startsWith('negative');
                        ApiController().giveRating(_post!.idKlub, _post!.id, positive: false, remove: removing).then((response) {
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
                                            _saveLikingStats(false, removing);
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
                              _saveLikingStats(false, removing);
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
