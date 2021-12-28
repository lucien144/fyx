import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class UnreadBadgeDecoration extends Decoration {
  final Color badgeColor;
  final double badgeSize;

  const UnreadBadgeDecoration({required this.badgeColor, required this.badgeSize});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _UnreadBadgePainter(badgeColor, badgeSize);
}

class _UnreadBadgePainter extends BoxPainter {
  final Color badgeColor;
  final double badgeSize;

  _UnreadBadgePainter(this.badgeColor, this.badgeSize);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    canvas.save();
    canvas.translate(0, offset.dy);
    canvas.drawPath(Path()..addRect(Rect.fromLTRB(0, 0, 5, configuration.size!.height)), getBadgePaint());
    canvas.restore();
  }

  Paint getBadgePaint() => Paint()
    ..isAntiAlias = true
    ..color = badgeColor;
}
