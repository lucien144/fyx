import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class ThrowItAway extends StatefulWidget {
  ThrowItAway({Key? key, required this.child, this.onDismiss, this.onTap, this.onDoubleTap, this.enabled = true}) : super(key: key);

  final Widget child;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onDoubleTap;
  final bool enabled;

  @override
  State<ThrowItAway> createState() => _ThrowItAwayState();
}

class _ThrowItAwayState extends State<ThrowItAway> {
  double _initialY = 0;
  double _initialX = 0;
  double _x = 0;
  double _y = 0;
  double _scale = 1;
  Duration _duration = Duration.zero;
  bool _enabled = true;

  TapDownDetails? tapDownDetails;

  @override
  void initState() {
    _enabled = widget.enabled;
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.enabled != widget.enabled) {
      setState(() => _enabled = widget.enabled);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedPositioned(
          curve: Curves.fastOutSlowIn,
          top: _y,
          bottom: 0 - _y,
          left: _x,
          right: 0 - _x,
          child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: widget.onTap,
              onDoubleTapDown: (details) => tapDownDetails = details,
              onDoubleTap: () {
                if (widget.onDoubleTap != null && tapDownDetails != null) {
                  widget.onDoubleTap!(tapDownDetails!);
                }
              },
              onVerticalDragStart: !_enabled
                  ? null
                  : (details) => setState(() {
                        _duration = Duration.zero;
                        _initialY = details.localPosition.dy;
                        _initialX = details.localPosition.dx;
                      }),
              onVerticalDragUpdate: !_enabled
                  ? null
                  : (details) {
                      setState(() {
                        _y = details.localPosition.dy - _initialY;
                        _x = details.localPosition.dx - _initialX;
                        _scale = 1 - (_y.abs() + _x.abs()) / 2000;
                      });
                    },
              onVerticalDragEnd: !_enabled
                  ? null
                  : (details) async {
                      if (_y.abs() > 40 && widget.onDismiss != null) {
                        setState(() {
                          var speed = 100;
                          _duration = Duration(milliseconds: speed);
                          _y = _y > 0 ? MediaQuery.of(context).size.height : -MediaQuery.of(context).size.height;
                        });
                        widget.onDismiss!();
                      } else {
                        setState(() {
                          _duration = Duration(milliseconds: 400);
                          _y = 0;
                          _x = 0;
                          _scale = 1;
                        });
                      }
                    },
              child: AnimatedScale(
                child: widget.child,
                scale: _scale,
                duration: Duration.zero,
              )),
          duration: _duration)
    ]);
  }
}
