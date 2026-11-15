import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/components/christmas_refresh_indicator.dart';

void main() {
  test('is active only on December 24', () {
    expect(ChristmasRefreshIndicator.isChristmasEve(DateTime(2026, 12, 24, 0, 0)), isTrue);
    expect(ChristmasRefreshIndicator.isChristmasEve(DateTime(2026, 12, 24, 23, 59)), isTrue);
    expect(ChristmasRefreshIndicator.isChristmasEve(DateTime(2026, 12, 23, 23, 59)), isFalse);
    expect(ChristmasRefreshIndicator.isChristmasEve(DateTime(2026, 12, 25)), isFalse);
    expect(ChristmasRefreshIndicator.isChristmasEve(DateTime(2026, 11, 24)), isFalse);
  });

  Widget indicator(RefreshIndicatorMode mode, double pulledExtent) => Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: pulledExtent,
          child: ChristmasRefreshIndicator(refreshState: mode, pulledExtent: pulledExtent, refreshTriggerPullDistance: 100),
        ),
      );

  final emoji = find.byWidgetPredicate((w) => w is Text && christmasEmojis.contains(w.data));
  final sparks = find.text(christmasSparkEmoji);

  // The closest Transform above the emoji is the scale one.
  double scaleOf(WidgetTester tester) =>
      tester.widget<Transform>(find.ancestor(of: emoji, matching: find.byType(Transform)).first).transform.entry(0, 0);

  testWidgets('grows with the pull and spins while refreshing', (tester) async {
    await tester.pumpWidget(indicator(RefreshIndicatorMode.drag, 10));
    expect(emoji, findsOneWidget);
    final small = scaleOf(tester);

    await tester.pumpWidget(indicator(RefreshIndicatorMode.drag, 90));
    expect(scaleOf(tester), greaterThan(small));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(indicator(RefreshIndicatorMode.refresh, 60));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(indicator(RefreshIndicatorMode.done, 30));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('bursts sparks once the user lets go', (tester) async {
    await tester.pumpWidget(indicator(RefreshIndicatorMode.drag, 90));
    await tester.pumpWidget(indicator(RefreshIndicatorMode.armed, 105));
    await tester.pumpWidget(indicator(RefreshIndicatorMode.armed, 120));
    expect(sparks, findsNothing);

    // Still armed, but the pull starts shrinking back.
    await tester.pumpWidget(indicator(RefreshIndicatorMode.armed, 115));
    await tester.pump(const Duration(milliseconds: 200));
    expect(sparks, findsNWidgets(8));

    // Reaching the refresh state must not restart the burst.
    await tester.pumpWidget(indicator(RefreshIndicatorMode.refresh, 60));
    await tester.pump(const Duration(milliseconds: 500));
    expect(sparks, findsNothing);
  });

  testWidgets('bursts sparks when a fast refresh finishes while still armed', (tester) async {
    await tester.pumpWidget(indicator(RefreshIndicatorMode.armed, 120));
    await tester.pumpWidget(indicator(RefreshIndicatorMode.done, 120));
    await tester.pump(const Duration(milliseconds: 200));
    expect(sparks, findsNWidgets(8));
  });
}
