import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/post/content/Poll.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class Poll extends StatefulWidget {
  final ContentPoll content;

  Poll(this.content);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<Poll> {
  List<int> _votes = [];
  bool _loading = false;
  ContentPoll? _poll;
  ScrollController controller = ScrollController();


  @override
  void initState() {
    _poll = widget.content;
    super.initState();
  }

  Widget buildAnswers(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    var totalRespondents = _poll!.pollComputedValues != null ? _poll!.pollComputedValues!.totalRespondents : 0;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
        controller: controller,
        itemBuilder: (context, index) {
          final answer = _poll!.answers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: GestureDetector(
              onTap: !_poll!.canVote ? null : () => setState(() {
                if (_votes.contains(index)) {
                  _votes.remove(index);
                } else {
                  if (_votes.length >= _poll!.allowedVotes) {
                    _votes.removeLast();
                    _votes.add(index);
                  } else {
                    _votes.add(index);
                  }
                }
              }),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: _votes.contains(index) ? colors.pollAnswerSelected : colors.pollAnswer, border: _poll!.canVote ? Border.all(color: colors.primaryColor) : null),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PostHtml(ContentRegular(answer.answer)),
                  if (answer.result != null)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            widthFactor: totalRespondents > 0 ? (answer.result.respondentsCount / totalRespondents) + 0.005 : .005,
                            child: Container(
                              color: answer.result.isMyVote ? colors.dangerColor : colors.primaryColor,
                              height: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('${totalRespondents == 0 ? 0 : (answer.result.respondentsCount / totalRespondents * 100).toStringAsFixed(1)}% / ${answer.result.respondentsCount}',
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13)),
                      ],
                    )
                ]),
              ),
            ),
          );
        },
        itemCount: _poll!.answers.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0));
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Container(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_poll!.question, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          if (_poll!.instructions != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PostHtml(ContentRegular(_poll!.instructions)),
            ),
          if (_poll!.pollComputedValues != null) Text('Hlasů: ${_poll!.pollComputedValues!.totalVotes}\nHlasujících: ${_poll!.pollComputedValues!.totalRespondents}'),
          SizedBox(height: 8,),
          buildAnswers(context),
          if (_poll!.canVote)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: CupertinoButton(
                onPressed: _votes.length == 0 || _loading ? null : () async {
                  setState(() => _loading = true);
                  try {
                    var votes = _votes.map((index) => index + 1).toList(); // Votes starting from 1 and not from 0.
                    var poll = await ApiController().votePoll(_poll!.discussionId, _poll!.postId, votes);
                    setState(() => _poll = poll);
                  } catch (error) {
                    T.error(error.toString());
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                child: _loading ? CupertinoActivityIndicator() : Text('Hlasovat ${_votes.length}/${_poll!.allowedVotes}'),
                color: colors.primaryColor,
                padding: EdgeInsets.all(0),
                disabledColor: colors.disabledColor,
              ),
            )
        ]),
        color: colors.pollBackground,
        padding: EdgeInsets.all(15));
  }
}
