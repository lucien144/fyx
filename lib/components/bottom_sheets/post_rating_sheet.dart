import 'package:flutter/cupertino.dart';
import 'package:fyx/components/post/post_thumbs.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/model/reponses/PostRatingsResponse.dart';
import 'package:fyx/theme/T.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostRatingBottomSheet extends StatelessWidget {
  final Post post;

  const PostRatingBottomSheet(this.post, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  if (positive.length > 0) PostThumbs(positive, isHorizontal: false),
                  if (negative.length > 0) PostThumbs(negative, isNegative: true, isHorizontal: false),
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
  }
}
