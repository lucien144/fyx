import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Emojis the indicator picks from, one at random for every pull.
const List<String> christmasEmojis = ['🎅', '🎄', '🎁', '⛄', '❄️', '🦌', '🔔', '🌟', '🕯️'];

/// Emoji that bursts out of the indicator when the user lets go.
const String christmasSparkEmoji = '✨';

/// Christmas Eve easter egg: a festive emoji replaces the pull-to-refresh spinner.
class ChristmasRefreshIndicator extends StatefulWidget {
  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;

  const ChristmasRefreshIndicator({
    Key? key,
    required this.refreshState,
    required this.pulledExtent,
    required this.refreshTriggerPullDistance,
  }) : super(key: key);

  static bool isChristmasEve([DateTime? now]) {
    final date = now ?? DateTime.now();
    return date.month == 12 && date.day == 24;
  }

  @override
  State<ChristmasRefreshIndicator> createState() => _ChristmasRefreshIndicatorState();
}

class _ChristmasRefreshIndicatorState extends State<ChristmasRefreshIndicator> with TickerProviderStateMixin {
  static const double _maxProgress = 1.5;
  static const int _sparkCount = 8;
  static const double _sparkDistance = 48;
  static final Random _random = Random();

  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _release = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late String _emoji = _pickEmoji();
  bool _released = false;

  bool get _isSpinning => widget.refreshState == RefreshIndicatorMode.armed || widget.refreshState == RefreshIndicatorMode.refresh;

  String _pickEmoji() => christmasEmojis[_random.nextInt(christmasEmojis.length)];

  @override
  void initState() {
    super.initState();
    _syncSpin();
  }

  @override
  void didUpdateWidget(ChristmasRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.refreshState;
    final current = widget.refreshState;

    // A new pull gets a new emoji.
    if (current == RefreshIndicatorMode.drag && (previous == RefreshIndicatorMode.inactive || previous == RefreshIndicatorMode.done)) {
      _emoji = _pickEmoji();
      _released = false;
    }
    // The control stays armed while the finger is down, so letting go shows up as the pull shrinking back.
    // A fast refresh can also skip straight to refresh/done.
    final wasArmed = previous == RefreshIndicatorMode.armed;
    final letGo = current == RefreshIndicatorMode.armed && wasArmed && widget.pulledExtent < oldWidget.pulledExtent;
    final movedOn = wasArmed && (current == RefreshIndicatorMode.refresh || current == RefreshIndicatorMode.done);
    if (!_released && (letGo || movedOn)) {
      _released = true;
      _release.forward(from: 0);
    }
    _syncSpin();
  }

  void _syncSpin() {
    if (_isSpinning && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!_isSpinning && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _release.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.pulledExtent / widget.refreshTriggerPullDistance).clamp(0.0, _maxProgress);

    return Center(
      child: OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge([_spin, _release]),
          builder: (context, child) {
            final release = _release.isAnimating ? _release.value : 0.0;
            // One bounce up and back while the sparks fly out.
            final pop = 1 + 0.5 * sin(pi * Curves.easeOut.transform(release));

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (release > 0) ..._buildSparks(release),
                // The drag turns the emoji once per trigger distance, the refresh keeps it spinning on top of that.
                Transform.rotate(
                  angle: (progress + _spin.value) * 2 * pi,
                  child: Transform.scale(scale: (0.3 + 0.7 * progress) * pop, child: child),
                ),
              ],
            );
          },
          child: Text(_emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }

  List<Widget> _buildSparks(double release) {
    final distance = _sparkDistance * Curves.easeOutCubic.transform(release);
    return List.generate(_sparkCount, (i) {
      final angle = i * 2 * pi / _sparkCount;
      return Transform.translate(
        offset: Offset(cos(angle), sin(angle)) * distance,
        child: Opacity(
          opacity: 1 - release,
          child: const Text(christmasSparkEmoji, style: TextStyle(fontSize: 14)),
        ),
      );
    });
  }
}
