import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IntroSlideView extends StatelessWidget {
  const IntroSlideView({super.key, required this.palette, required this.nickname, this.countedFrom});

  final YearInReviewPalette palette;
  final String nickname;
  final DateTime? countedFrom;

  static const _icons = [
    LucideIcons.clock,
    LucideIcons.flame,
    LucideIcons.thumbsUp,
    LucideIcons.messageSquare,
    LucideIcons.trophy,
  ];

  @override
  Widget build(BuildContext context) {
    return FullHeightSlide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                for (var i = 0; i < _icons.length; i++)
                  Container(
                    width: 56,
                    height: 56,
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(12)),
                    child: Icon(_icons[i], size: 28, color: palette.cardValue),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(opacity: 0.75, child: Text('Ahoj, $nickname', style: inter(15, weight: FontWeight.w600))),
              const SizedBox(height: 12),
              Text('Tvůj rok\ns Fyxem.', style: inter(64, weight: FontWeight.w900, height: 0.95, letterSpacing: -1.92)),
              const SizedBox(height: 20),
              Opacity(
                opacity: 0.85,
                child: Text(
                  'Každý tvůj paleček, scroll, galerie nebo rozepsaný příspěvek.',
                  style: inter(18, height: 1.4),
                ),
              ),
              if (countedFrom != null) ...[
                const SizedBox(height: 12),
                Opacity(opacity: 0.7, child: Text(YearInReviewTexts.countedFromLong(countedFrom!), style: inter(13))),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.7,
                child: Row(
                  children: [
                    Text('Ťukni pro pokračování', style: inter(14, weight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.chevronRight, size: 18, color: palette.foreground),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Opacity(opacity: 0.7, child: Text(YearInReviewTexts.disclaimer, style: inter(12, height: 1.45))),
            ],
          ),
        ],
      ),
    );
  }
}
