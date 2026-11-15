import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WritingSlideView extends StatelessWidget {
  const WritingSlideView({super.key, required this.slide, required this.palette});

  final WritingSlide slide;
  final YearInReviewPalette palette;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (LucideIcons.messageSquare, 'Nové příspěvky', slide.posts),
      (LucideIcons.reply, 'Odpovědi', slide.replies),
      (LucideIcons.paperclip, 'Přílohy', slide.attachments),
      (LucideIcons.mail, 'Zprávy v poště', slide.mails),
    ];

    return CenteredSlide(
      children: [
        const SlideHeading(icon: LucideIcons.pencil, label: 'Z tvé klávesnice'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BigFigure(
              child: Text(
                YearInReviewTexts.number(slide.characters),
                style: inter(88, weight: FontWeight.w900, height: 0.9, letterSpacing: -3.52),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              YearInReviewTexts.charactersUnit(slide.characters),
              style: inter(28, weight: FontWeight.w900, letterSpacing: -0.28),
            ),
          ],
        ),
        Text(YearInReviewTexts.writingSentence(slide), style: inter(18, height: 1.4)),
        Container(
          decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: i == rows.length - 1
                        ? null
                        : Border(bottom: BorderSide(color: palette.cardLabel.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    children: [
                      Icon(rows[i].$1, size: 20, color: palette.cardValue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rows[i].$2, style: inter(16, color: palette.cardLabel))),
                      Text(
                        YearInReviewTexts.number(rows[i].$3),
                        style: inter(16, weight: FontWeight.w700, color: palette.cardValue),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
