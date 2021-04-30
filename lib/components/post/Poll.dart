import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/model/post/ContentPoll.dart';
import 'package:fyx/model/post/ContentRegular.dart';
import 'package:fyx/theme/T.dart';

class Poll extends StatefulWidget {
  final ContentPoll content;

  Poll(this.content);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<Poll> {
  List _votes = [];

  Widget buildAnswers(BuildContext context) {
    var totalRespondents = widget.content.pollComputedValues.totalRespondents;

    return ListView.builder(
        itemBuilder: (context, index) {
          final answer = widget.content.answers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: GestureDetector(
              onTap: () => setState(() {
                if (_votes.contains(index)) {
                  _votes.remove(index);
                } else {
                  if (_votes.length >= widget.content.allowedVotes) {
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
                    color: _votes.contains(index) ? Color(0xff76b9b9) : Color(0xffa9ccd3), border: widget.content.canVote ? Border.all(color: T.COLOR_PRIMARY) : null),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PostHtml(ContentRegular(answer.answer)),
                  if (answer.result != null)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          color: answer.result.isMyVote ? Color(0xffB60F0F) : T.COLOR_PRIMARY,
                          width: totalRespondents > 0 ? (MediaQuery.of(context).size.width * .7) * (answer.result.respondentsCount / totalRespondents) : 1,
                          height: 10,
                        ),
                        SizedBox(width: 8),
                        Text('${answer.result.respondentsCount} (${totalRespondents == 0 ? 0 : (answer.result.respondentsCount / totalRespondents * 100).toStringAsFixed(1)}%)',
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13)),
                      ],
                    )
                ]),
              ),
            ),
          );
        },
        itemCount: widget.content.answers.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.content.question, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          if (widget.content.instructions != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PostHtml(ContentRegular(widget.content.instructions)),
            ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: '${widget.content.pollComputedValues.totalVotes} hlasů od ${widget.content.pollComputedValues.totalRespondents} hlasujících',
                style: DefaultTextStyle.of(context).style),
          ])),
          buildAnswers(context),
          if (widget.content.canVote)
            CupertinoButton(
              onPressed: _votes.length == 0 ? null : () => null,
              child: Text('Hlasovat ${_votes.length}/${widget.content.allowedVotes}'),
              color: T.COLOR_PRIMARY,
              padding: EdgeInsets.all(0),
              disabledColor: Colors.black26,
            )
        ]),
        color: Color(0xffcde5e9),
        padding: EdgeInsets.all(15));
  }
}
