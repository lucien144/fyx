import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StreakSlideView extends StatelessWidget {
  const StreakSlideView({super.key, required this.slide, required this.palette});

  final StreakSlide slide;
  final YearInReviewPalette palette;

  static const _columns = 15;

  @override
  Widget build(BuildContext context) {
    return CenteredSlide(
      children: [
        const SlideHeading(icon: LucideIcons.flame, label: 'Nejdelší streak'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              YearInReviewTexts.number(slide.longest),
              style: inter(120, weight: FontWeight.w900, height: 0.85, letterSpacing: -6),
            ),
            const SizedBox(height: 10),
            Text(
              YearInReviewTexts.streakUnit(slide.longest),
              style: inter(28, weight: FontWeight.w900, letterSpacing: -0.28),
            ),
          ],
        ),
        _dots(),
        if (slide.current != null) _currentStreak(slide.current!),
      ],
    );
  }

  Widget _dots() {
    const rows = StreakSlideExtension.totalDots ~/ _columns;

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 4),
            child: Row(
              children: [
                for (var column = 0; column < _columns; column++) ...[
                  if (column > 0) const SizedBox(width: 4),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: row * _columns + column < slide.litDots
                              ? palette.foreground
                              : palette.foreground.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _currentStreak(int current) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.foreground.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.flame, size: 30, color: palette.foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(opacity: 0.8, child: Text('Aktuální streak', style: inter(14))),
                const SizedBox(height: 2),
                Text(YearInReviewTexts.days(current), style: inter(28, weight: FontWeight.w800)),
              ],
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Text(
              YearInReviewTexts.recordHint(slide),
              textAlign: TextAlign.right,
              style: inter(14, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
