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
    var estimatedVotes = widget.content.answers
      .map((answer) => answer.result?.respondentsCount)
      .reduce((a, b) => (a??=0) + (b??=0));

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
            FractionallySizedBox(

                  widthFactor: answer.result == null ? 0 : (answer.result.respondentsCount/estimatedVotes).toDouble(), //TODO compare respondentCOunt with total number of respondents when added to API

                  child: Container(
                    color: answer.result == null ? null : answer.result.isMyVote ? T.COLOR_LIGHT : T.COLOR_PRIMARY,
                    height: 10,
                  )
            )]

    ))
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
