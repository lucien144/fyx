import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// The one slide that ignores the skin: fixed retro-shooter colours and a pixel font.
class DoomscrollSlideView extends StatelessWidget {
  const DoomscrollSlideView({super.key, required this.slide, this.bottomInset = 0});

  final DoomscrollSlide slide;

  /// Safe-area inset the status bar has to clear at the bottom.
  final double bottomInset;

  static const _black = Color(0xFF000000);
  static const _amber = Color(0xFFFFB21A);
  static const _red = Color(0xFFFF2A1A);
  static const _titleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF27A), _amber, Color(0xFFE2470E), Color(0xFF8A1405)],
    stops: [0, 0.35, 0.7, 1],
  );

  @override
  Widget build(BuildContext context) {
    final distance = YearInReviewTexts.distanceParts(slide.meters);

    return FullHeightSlide(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('E1M1: HISTORIE', style: pixel(10, color: const Color(0xFFB8A27A), letterSpacing: 0.5)),
                const SizedBox(height: 22),
                Center(child: _title()),
                const SizedBox(height: 30),
                BigFigure(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: distance.value),
                      TextSpan(text: ' ${distance.unit.toUpperCase()}', style: const TextStyle(fontSize: 24)),
                    ]),
                    style: pixel(56,
                        color: const Color(0xFFFF3B1F), height: 1, shadows: const [Shadow(offset: Offset(4, 4))]),
                  ),
                ),
                const SizedBox(height: 22),
                MarkedText(
                  YearInReviewTexts.doomSentence(slide),
                  style: inter(18, height: 1.45, color: const Color(0xFFF3E3C3)),
                  boldColor: _amber,
                ),
                const SizedBox(height: 22),
                Text(unaccented(YearInReviewTexts.secretGalleries(slide.galleryOpens)),
                    style: pixel(10, color: _amber, height: 1.7)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Opacity(opacity: 0.85, child: SizedBox(height: 56, child: CustomPaint(painter: _FlamesPainter()))),
              _statusBar(distance),
            ],
          ),
        ],
      ),
    );
  }

  /// Gradient-filled title leaning back in perspective, with a hard drop shadow.
  Widget _title() {
    final style = pixel(31, height: 1.1, color: const Color(0xFFFFFFFF));
    const text = 'DOOM\nSCROLL';

    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, -1 / 300)
        ..rotateX(18 * pi / 180),
      child: Stack(
        children: [
          Transform.translate(
            offset: const Offset(3, 3),
            child: Text(text, textAlign: TextAlign.center, style: style.copyWith(color: _black)),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => _titleGradient.createShader(bounds),
            child: Text(text, textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }

  Widget _statusBar(({String value, String unit}) distance) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 22 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF4A4A46),
        border: Border(top: BorderSide(color: Color(0xFF6E6D66), width: 4)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _cell(distance.value, distance.unit == 'm' ? 'METRY' : 'KM')),
            const SizedBox(width: 4),
            Expanded(child: _cell('${slide.healthPercent}%', 'ZDRAVI')),
            const SizedBox(width: 4),
            Container(
              width: 64,
              color: const Color(0xFF2B2A27),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.skull, size: 34, color: _amber),
            ),
            const SizedBox(width: 4),
            Expanded(child: _cell('${slide.appLaunches}', 'RESPAWNY')),
          ],
        ),
      ),
    );
  }

  Widget _cell(String value, String label) {
    return Container(
      color: const Color(0xFF2B2A27),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: pixel(16, color: _red))),
          const SizedBox(height: 6),
          Text(label, style: pixel(7, color: const Color(0xFFC9C3B2))),
        ],
      ),
    );
  }
}

/// Striped "flames" fading out towards the top.
class _FlamesPainter extends CustomPainter {
  const _FlamesPainter();

  static const _colors = [Color(0xFFE2470E), Color(0xFFFFB21A), Color(0xFF8A1405)];

  @override
  void paint(Canvas canvas, Size size) {
    final fade = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      stops: [0.1, 1],
    ).createShader(Offset.zero & size);

    canvas.saveLayer(Offset.zero & size, Paint());
    for (var x = 0.0, i = 0; x < size.width; x += 8, i++) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 6, size.height), Paint()..color = _colors[i % _colors.length]);
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = fade
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
