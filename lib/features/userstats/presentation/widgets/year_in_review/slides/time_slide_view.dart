import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TimeSlideView extends StatelessWidget {
  const TimeSlideView({super.key, required this.slide, required this.palette});

  final TimeSlide slide;
  final YearInReviewPalette palette;

  @override
  Widget build(BuildContext context) {
    final time = YearInReviewTexts.hoursAndMinutes(slide.seconds);
    final unit = inter(48, weight: FontWeight.w900);

    return CenteredSlide(
      gap: 28,
      children: [
        const SlideHeading(icon: LucideIcons.clock, label: 'Tvůj čas ve Fyxu'),
        BigFigure(
          child: Text.rich(
            TextSpan(children: [
              if (time.hours > 0) ...[
                TextSpan(text: YearInReviewTexts.number(time.hours)),
                TextSpan(text: 'h\n', style: unit),
              ],
              TextSpan(text: '${time.minutes}'),
              TextSpan(text: 'm', style: unit),
            ]),
            style: inter(96, weight: FontWeight.w900, height: 0.9, letterSpacing: -3.84),
          ),
        ),
        MarkedText(YearInReviewTexts.timeComparison(slide), style: inter(18, height: 1.4)),
        Row(
          children: [
            Expanded(child: _card(LucideIcons.smartphone, slide.appLaunches, 'spuštění aplikace')),
            const SizedBox(width: 10),
            Expanded(child: _card(LucideIcons.image, slide.galleryOpens, 'otevření galerie')),
          ],
        ),
      ],
    );
  }

  Widget _card(IconData icon, int count, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: palette.cardValue),
          const SizedBox(height: 8),
          BigFigure(
            child: Text(
              '${YearInReviewTexts.number(count)}×',
              style: inter(32, weight: FontWeight.w800, color: palette.cardValue),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: inter(14, color: palette.cardLabel)),
        ],
      ),
    );
  }
}
