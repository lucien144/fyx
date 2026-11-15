import 'package:diacritic/diacritic.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter in the fixed sizes of the design; the app's font-size setting does not apply here.
TextStyle inter(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: letterSpacing);
}

/// Press Start 2P. Its accented Czech glyphs are unreliable, so pair it with [unaccented].
TextStyle pixel(double size, {Color? color, double? height, double? letterSpacing, List<Shadow>? shadows}) {
  return GoogleFonts.pressStart2p(fontSize: size, color: color, height: height, letterSpacing: letterSpacing, shadows: shadows);
}

String unaccented(String text) => removeDiacritics(text);

/// Icon + label line opening a slide.
class SlideHeading extends StatelessWidget {
  const SlideHeading({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: DefaultTextStyle.of(context).style.color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: inter(20, weight: FontWeight.w600))),
      ],
    );
  }
}

/// Text where `*asterisks*` mark bold parts.
class MarkedText extends StatelessWidget {
  const MarkedText(this.text, {super.key, required this.style, this.boldColor});

  final String text;
  final TextStyle style;

  /// Colour of the bold parts; they keep the base colour when null.
  final Color? boldColor;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('*');
    // Each Inter weight is its own font file, so the family has to change too.
    final bold = GoogleFonts.inter(fontWeight: FontWeight.w700, color: boldColor);
    return Text.rich(
      TextSpan(children: [for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : null)]),
      style: style,
    );
  }
}

/// Vertically centred slide content that shrinks to fit on short screens.
class CenteredSlide extends StatelessWidget {
  const CenteredSlide({super.key, required this.children, this.gap = 24});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slide content that fills the whole height (e.g. a spaced-out column) and
/// shrinks when the screen is too short for it.
class FullHeightSlide extends StatelessWidget {
  const FullHeightSlide({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A big figure that scales down instead of wrapping when it gets too wide.
class BigFigure extends StatelessWidget {
  const BigFigure({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child);
  }
}
