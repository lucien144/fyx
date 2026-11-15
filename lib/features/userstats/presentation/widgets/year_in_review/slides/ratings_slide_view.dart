import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RatingsSlideView extends StatelessWidget {
  const RatingsSlideView({super.key, required this.slide, required this.palette});

  final RatingsSlide slide;
  final YearInReviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return CenteredSlide(
      gap: 28,
      children: [
        const SlideHeading(icon: LucideIcons.thumbsUp, label: 'Palečky'),
        BigFigure(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                YearInReviewTexts.number(slide.likes),
                style: inter(120, weight: FontWeight.w900, height: 0.85, letterSpacing: -6),
              ),
              const SizedBox(width: 16),
              Opacity(
                opacity: 0.45,
                child: Text(': ${YearInReviewTexts.number(slide.dislikes)}', style: inter(40, weight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        Column(
          children: [
            _bar(),
            const SizedBox(height: 8),
            Opacity(
              opacity: 0.75,
              child: Row(
                children: [
                  Icon(LucideIcons.thumbsUp, size: 16, color: palette.foreground),
                  const SizedBox(width: 6),
                  Text('Paleček', style: inter(14)),
                  const Spacer(),
                  Text('Mínusko', style: inter(14)),
                  const SizedBox(width: 6),
                  Icon(LucideIcons.thumbsDown, size: 16, color: palette.foreground),
                ],
              ),
            ),
          ],
        ),
        Text(YearInReviewTexts.ratingsSentence(slide), style: inter(22, weight: FontWeight.w700, height: 1.35)),
      ],
    );
  }

  /// Share of likes vs. dislikes; an empty track when nothing was rated.
  Widget _bar() {
    final percent = slide.positivePercent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        color: palette.background == palette.card ? palette.track : palette.card,
        child: percent == null
            ? null
            : LayoutBuilder(builder: (context, constraints) {
                // Keep the label readable even for a tiny share of likes.
                final positive = slide.likes == 0 ? 0.0 : (constraints.maxWidth * percent / 100).clamp(72.0, constraints.maxWidth);
                return Row(
                  children: [
                    Container(
                      width: positive,
                      color: palette.positive.withValues(alpha: 0.25),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 14),
                      child: slide.likes == 0
                          ? null
                          : Text(
                              '+${YearInReviewTexts.number(slide.likes)}',
                              style: inter(16, weight: FontWeight.w700, color: palette.positive),
                            ),
                    ),
                    Expanded(child: Container(color: palette.negative.withValues(alpha: 0.25))),
                  ],
                );
              }),
      ),
    );
  }
}
