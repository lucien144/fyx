import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

/// Marks the top-right corner of [widget] with a counter, or with a plain
/// dot when [counter] is null.
class NotificationBadge extends StatelessWidget {
  static const double dotSize = 8;

  final Widget widget;
  final bool isVisible;
  final int? counter;

  const NotificationBadge({Key? key, required this.widget, this.counter, this.isVisible = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget,
        if (isVisible)
          Positioned(
            top: 0,
            right: 0,
            child: counter == null
                ? Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(color: colors.danger, shape: BoxShape.circle),
                  )
                : Container(
                    padding: EdgeInsets.all(3),
                    constraints: BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(color: colors.danger, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      counter.toString(),
                      style: TextStyle(color: colors.background, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
      ],
    );
  }
}
