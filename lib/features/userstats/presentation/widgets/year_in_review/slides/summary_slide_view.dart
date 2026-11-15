import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// The closing slide. Only its two buttons take touches; the rest lets taps
/// fall through to the navigation zones underneath.
class SummarySlideView extends StatelessWidget {
  const SummarySlideView({
    super.key,
    required this.slide,
    required this.palette,
    required this.year,
    required this.nickname,
    required this.cardKey,
    required this.onShare,
    required this.onRestart,
    this.countedFrom,
  });

  final SummarySlide slide;
  final YearInReviewPalette palette;
  final int year;
  final String nickname;
  final DateTime? countedFrom;

  /// Key of the [RepaintBoundary] around the card that gets shared.
  final GlobalKey cardKey;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return CenteredSlide(
      gap: 16,
      children: [
        IgnorePointer(child: RepaintBoundary(key: cardKey, child: _card())),
        Row(
          children: [
            Expanded(child: _button(LucideIcons.share, 'Sdílet', onShare, filled: true)),
            const SizedBox(width: 10),
            Expanded(child: _button(LucideIcons.rotateCcw, 'Znovu', onRestart, filled: false)),
          ],
        ),
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Opacity(
              opacity: 0.75,
              child: Text(
                YearInReviewTexts.disclaimer,
                textAlign: TextAlign.center,
                style: inter(12, height: 1.45),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card() {
    final figures = [
      if (slide.seconds != null) ('Čas v aplikaci', YearInReviewTexts.duration(slide.seconds!)),
      if (slide.meters != null) ('Doomscroll', YearInReviewTexts.distance(slide.meters!)),
      ('Palečky', YearInReviewTexts.number(slide.likes)),
      ('Nejdelší streak', YearInReviewTexts.days(slide.longestStreak)),
    ];
    final title = [
      YearInReviewTexts.header(year),
      if (countedFrom != null) YearInReviewTexts.countedFromShort(countedFrom!),
    ].join(' · ');

    return DefaultTextStyle.merge(
      style: TextStyle(color: palette.onAccent),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: inter(15, weight: FontWeight.w700))),
                Opacity(opacity: 0.75, child: Text(nickname, style: inter(13))),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              YearInReviewTexts.summaryHeadline(slide.rhythm, slide.character),
              style: inter(36, weight: FontWeight.w900, height: 1, letterSpacing: -0.72),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 14,
                children: [
                  for (final (label, value) in figures)
                    SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(opacity: 0.75, child: Text(label, style: inter(12))),
                          Text(value, style: inter(22, weight: FontWeight.w800)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (slide.topDiscussionName != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.onAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(opacity: 0.75, child: Text('Top diskuze', style: inter(12))),
                    const SizedBox(height: 2),
                    Text(
                      slide.topDiscussionName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: inter(15, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback onTap, {required bool filled}) {
    final color = filled ? palette.onAccent : palette.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? palette.accent : null,
          border: filled ? null : Border.all(color: palette.accent, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: inter(17, weight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
