import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedbackIndicator extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  FeedbackIndicator({Key key, this.child, this.isLoading}) : super(key: key);

  @override
  _FeedbackIndicatorState createState() => _FeedbackIndicatorState();
}

class _FeedbackIndicatorState extends State<FeedbackIndicator> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Opacity(opacity: widget.isLoading ? 0.4 : 1, child: widget.child),
      Visibility(
          visible: widget.isLoading,
          child: CupertinoActivityIndicator(radius: 8))
    ]);
  }
}
