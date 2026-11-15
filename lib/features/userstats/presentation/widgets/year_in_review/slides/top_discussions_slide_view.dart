import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TopDiscussionsSlideView extends StatelessWidget {
  const TopDiscussionsSlideView({super.key, required this.slide, required this.palette});

  final TopDiscussionsSlide slide;
  final YearInReviewPalette palette;

  @override
  Widget build(BuildContext context) {
    final discussions = slide.discussions;
    final most = discussions.first.visits;

    return CenteredSlide(
      gap: 20,
      children: [
        const SlideHeading(icon: LucideIcons.trophy, label: 'Tvoje top diskuze'),
        Column(
          children: [
            for (var i = 0; i < discussions.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                child: _item(i + 1, discussions[i], most),
              ),
          ],
        ),
        MarkedText(YearInReviewTexts.topSentence(most), style: inter(16, height: 1.4)),
      ],
    );
  }

  Widget _item(int rank, DiscussionVisit discussion, int most) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(6)),
            child: Text('$rank', style: inter(15, weight: FontWeight.w700, color: palette.onAccent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion.discussionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: inter(15, weight: FontWeight.w600, color: palette.cardText),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 4,
                    color: palette.cardLabel.withValues(alpha: 0.2),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: most == 0 ? 0 : discussion.visits / most,
                      child: Container(color: palette.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            YearInReviewTexts.number(discussion.visits),
            style: inter(15, weight: FontWeight.w700, color: palette.cardValue),
          ),
        ],
      ),
    );
  }
}
