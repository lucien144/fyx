import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget widget;
  final bool isVisible;
  final int counter;

  const NotificationBadge({Key key, @required this.widget, this.counter = 0, this.isVisible = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget,
        Visibility(
          visible: isVisible,
          child: Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(3),
              constraints: BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
              child: Text(
                counter.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
