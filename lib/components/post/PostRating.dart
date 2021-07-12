import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/FeedbackIndicator.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class PostRating extends StatefulWidget {
  final Post post;

  PostRating(this.post, {Key key}) : super(key: key);

  @override
  _PostRatingState createState() => _PostRatingState();
}

class _PostRatingState extends State<PostRating> {
  Post _post;
  bool _givingRating = false;

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
    return FeedbackIndicator(
      isLoading: _givingRating,
      child: Row(
        children: <Widget>[
          Visibility(
            visible: _post.canBeRated,
            child: GestureDetector(
              child: Icon(
                Icons.thumb_up,
                color: _post.myRating == 'positive' ? Colors.green : Colors.black38,
              ),
              onTap: _givingRating
                  ? null
                  : () {
                      setState(() => _givingRating = true);
                      ApiController().giveRating(_post.idKlub, _post.id, remove: _post.myRating != 'none').then((response) {
                        setState(() {
                          _post.rating = response.currentRating;
                          _post.myRating = response.myRating;
                        });
                      }).catchError((error) {
                        print(error);
                        T.error(L.RATING_ERROR);
                      }).whenComplete(() => setState(() => _givingRating = false));
                    },
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Visibility(
            visible: _post.rating != 0 || MainRepository().credentials.nickname != _post.nick,
            child: Opacity(
              opacity: _givingRating ? 0 : 1,
              child: Text(
                _post.rating > 0 ? '+${_post.rating}' : _post.rating.toString(),
                style: TextStyle(fontSize: 14, color: _post.rating > 0 ? Colors.green : (_post.rating < 0 ? Colors.redAccent : Colors.black38)),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Visibility(
            visible: _post.canBeRated,
            child: GestureDetector(
              child: Icon(
                Icons.thumb_down,
                color: ['negative', 'negative_visible'].contains(_post.myRating) ? Colors.redAccent : Colors.black38,
              ),
              onTap: _givingRating
                  ? null
                  : () {
                      setState(() => _givingRating = true);
                      ApiController().giveRating(_post.idKlub, _post.id, positive: false, remove: _post.myRating != 'none').then((response) {
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
                                      ApiController().giveRating(_post.idKlub, _post.id, positive: false, confirm: true, remove: _post.myRating != 'none').then((response) {
                                        setState(() {
                                          _post.rating = response.currentRating;
                                          _post.myRating = response.myRating;
                                        });
                                      }).catchError((error) {
                                        print(error);
                                        T.error(L.RATING_ERROR);
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
                            _post.rating = response.currentRating;
                            _post.myRating = response.myRating;
                            _givingRating = false;
                          });
                        }
                      }).catchError((error) {
                        setState(() => _givingRating = false);
                        T.error(L.RATING_ERROR);
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}
