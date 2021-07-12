import 'package:flutter/material.dart';

class GestureFeedback extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;

  GestureFeedback({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  _GestureFeedbackState createState() => _GestureFeedbackState();
}

class _GestureFeedbackState extends State<GestureFeedback> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Opacity(
        child: widget.child,
        opacity: _isDown ? 0.8 : 1,
      ),
      onTap: () async {
        setState(() => _isDown = true);
        if (widget.onTap is Function) {
          widget.onTap();
        }
        await Future.delayed(Duration(milliseconds: 50));
        setState(() => _isDown = false);
      },
      onTapDown: (details) => setState(() => _isDown = true),
    );
  }
}
