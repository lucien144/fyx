import 'package:flutter/material.dart';

class ExpandableFadeWidget extends StatefulWidget {
  final Widget child;

  final double collapsedHeight;
  final Duration duration;
  final Curve curve;
  final bool enabled;
  final bool expanded;

  const ExpandableFadeWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.expanded = false,
    this.collapsedHeight = 120,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<ExpandableFadeWidget> createState() => _ExpandableFadeWidgetState();
}

class _ExpandableFadeWidgetState extends State<ExpandableFadeWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: widget.expanded ? const BoxConstraints() : BoxConstraints(maxHeight: widget.collapsedHeight),
        child: widget.expanded
            ? widget.child // bez fadu v otevřeném stavu
            : ClipRect(child: _FadedBottom(child: widget.child)),
      ),
    );
  }
}

class _FadedBottom extends StatelessWidget {
  final Widget child;

  const _FadedBottom({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, 0.8, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
