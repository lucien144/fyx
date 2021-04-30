import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fyx/model/post/ContentPoll.dart';
import 'package:fyx/theme/T.dart';

class Poll extends StatefulWidget {
  ContentPoll content;

  Poll(this.content);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<Poll> {
  bool _showColumnStats = false;
  bool _showRowStats = false;
  TapGestureRecognizer votesRecognizer;
  TapGestureRecognizer columnsRecognizer;
  TapGestureRecognizer rowsRecognizer;

  @override
  void initState() {
    votesRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = false;
          _showColumnStats = false;
        });
      };

    columnsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = false;
          _showColumnStats = !_showColumnStats;
        });
      };

    rowsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showRowStats = !_showRowStats;
          _showColumnStats = false;
        });
      };

    super.initState();
  }

  List<Widget> buildAnswers(BuildContext context) {
    var totalRespondents = widget.content.pollComputedValues.totalRespondents;

    return widget.content.answers
        .map((answer) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                textAlign: TextAlign.left,
                text: TextSpan(children: [TextSpan(
                    text: answer.answer,
                    style: DefaultTextStyle.of(context)
                        .style
                ),
                ]),
            ),
            if (answer.result != null)
              FractionallySizedBox(
                widthFactor: (answer.result.respondentsCount/totalRespondents).toDouble() + 0.001,
                child: Container(
                  color: answer.result.isMyVote ? T.COLOR_LIGHT : T.COLOR_PRIMARY,
                  height: 10,
                )
              ),
            if (answer.result != null)
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(children: [TextSpan(
                    text: "${answer.result.respondentsCount} (${(answer.result.respondentsCount/totalRespondents*100).toStringAsFixed(1)}%)",
                    style: DefaultTextStyle.of(context)
                        .style
                ),
                ]),
              )
          ]
    ))
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          RichText(
                    text: TextSpan(children: [TextSpan(
                      text: widget.content.question,
                      style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.2)
                    )])
          ),
          RichText(
              text: TextSpan(children: [TextSpan(
                  text: widget.content.instructions,
                  style: DefaultTextStyle.of(context)
                      .style
              ),
              ])
          ),
          RichText(
              text: TextSpan(children: [TextSpan(
                  text: "${widget.content.pollComputedValues.totalVotes} hlasů od ${widget.content.pollComputedValues.totalRespondents} hlasujících",
                  style: DefaultTextStyle.of(context)
                      .style
              ),
              ])
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
           children: buildAnswers(context)
          )
        ]),
      color: Color(0xffcde5e9),
      padding: EdgeInsets.all(15)
    );
  }
}
