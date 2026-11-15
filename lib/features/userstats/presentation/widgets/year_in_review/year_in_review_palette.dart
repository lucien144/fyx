import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

/// Colour mood of a slide.
enum YearInReviewTone { primary, light, plain, deep, doom }

/// Colours of one slide, derived from the active skin (except [YearInReviewTone.doom]).
@immutable
class YearInReviewPalette {
  final Color background;
  final Color foreground;

  /// Surface, numbers, body text and labels of cards placed on the slide.
  final Color card;
  final Color cardValue;
  final Color cardText;
  final Color cardLabel;

  /// Filled elements (badges, selected tiles, the summary card) and what sits on them.
  final Color accent;
  final Color onAccent;

  final Color positive;
  final Color negative;

  const YearInReviewPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardValue,
    required this.cardText,
    required this.cardLabel,
    required this.accent,
    required this.onAccent,
    required this.positive,
    required this.negative,
  });

  Color get track => foreground.withValues(alpha: 0.25);

  static const _onLight = Color(0xFF1D2A2E);

  /// White or near-black, whichever reads better on [background].
  static Color contrastOn(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : _onLight;
  }

  static Color _darken(Color color, double amount) => Color.lerp(color, Colors.black, amount)!;

  factory YearInReviewPalette.of(SkinColors colors, YearInReviewTone tone) {
    final background = switch (tone) {
      YearInReviewTone.primary => colors.primary,
      YearInReviewTone.light => colors.barBackground,
      YearInReviewTone.plain => colors.background,
      YearInReviewTone.deep => _darken(colors.primary, 0.25),
      YearInReviewTone.doom => const Color(0xFF1A0B07),
    };
    final foreground = switch (tone) {
      YearInReviewTone.primary || YearInReviewTone.deep => contrastOn(background),
      YearInReviewTone.light || YearInReviewTone.plain => colors.primary,
      YearInReviewTone.doom => const Color(0xFFFFB21A),
    };
    return YearInReviewPalette(
      background: background,
      foreground: foreground,
      card: colors.background,
      cardValue: colors.primary,
      cardText: colors.text,
      cardLabel: colors.text.withValues(alpha: 0.65),
      accent: colors.primary,
      onAccent: contrastOn(colors.primary),
      positive: colors.success,
      negative: colors.danger,
    );
  }
}
