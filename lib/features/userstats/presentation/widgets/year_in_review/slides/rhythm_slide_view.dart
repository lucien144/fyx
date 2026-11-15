import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RhythmSlideView extends StatelessWidget {
  const RhythmSlideView({super.key, required this.slide, required this.palette});

  final RhythmSlide slide;
  final YearInReviewPalette palette;

  @override
  Widget build(BuildContext context) {
    final weekday = slide.peakWeekday;
    final month = slide.peakMonth;

    return CenteredSlide(
      gap: 22,
      children: [
        const SlideHeading(icon: LucideIcons.sunrise, label: 'Tvůj rytmus'),
        Text(
          YearInReviewTexts.rhythmHeadline(slide.rhythm),
          style: inter(64, weight: FontWeight.w900, height: 0.95, letterSpacing: -1.92),
        ),
        _section('Nejaktivnější hodina', YearInReviewTexts.hour(slide.peakHour), _hours()),
        if (weekday >= 1)
          _section(
            'Nejaktivnější den',
            YearInReviewTexts.weekdays[weekday - 1],
            _tiles(YearInReviewTexts.weekdaysShort, selected: weekday - 1, gap: 4, radius: 8, fontSize: 13),
          ),
        if (month >= 1)
          _section(
            'Nejaktivnější měsíc',
            YearInReviewTexts.months[month - 1],
            _tiles(YearInReviewTexts.monthsShort, selected: month - 1, gap: 3, radius: 6, fontSize: 11),
          ),
      ],
    );
  }

  Widget _section(String label, String value, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(opacity: 0.7, child: Text(label, style: inter(14))),
            Text(value, style: inter(14, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        chart,
      ],
    );
  }

  Widget _hours() {
    final peak = max(1, slide.hourCounts.reduce(max));

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var hour = 0; hour < slide.hourCounts.length; hour++) ...[
            if (hour > 0) const SizedBox(width: 3),
            Expanded(
              child: FractionallySizedBox(
                heightFactor: max(0.08, slide.hourCounts[hour] / peak),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: hour == slide.peakHour ? palette.accent : palette.foreground.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tiles(
    List<String> labels, {
    required int selected,
    required double gap,
    required double radius,
    required double fontSize,
  }) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: i == selected ? palette.accent : palette.card,
              ),
              child: Text(
                labels[i],
                style: inter(fontSize, weight: FontWeight.w700, color: i == selected ? palette.onAccent : palette.cardLabel),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
