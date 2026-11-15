/// The January Window: when the Year in Review of the previous year is offered.
abstract final class YearInReviewWindow {
  static const lastDay = 14;

  /// Below this many active days there is no story worth telling.
  static const minActiveDays = 7;

  static bool isOpen(DateTime now) => now.month == DateTime.january && now.day <= lastDay;

  /// The year the window opened at [now] is about.
  static int yearFor(DateTime now) => now.year - 1;

  /// Whether the menu entry is shown. [activeDays] are those of [yearFor].
  static bool isOffered({required DateTime now, required bool isPremium, required int activeDays}) {
    return isOpen(now) && isPremium && activeDays >= minActiveDays;
  }

  /// Whether it should open on its own; happens once per reviewed year.
  static bool shouldAutoOpen({
    required DateTime now,
    required bool isPremium,
    required int activeDays,
    required int? lastAutoOpenedYear,
  }) {
    return isOffered(now: now, isPremium: isPremium, activeDays: activeDays) && lastAutoOpenedYear != yearFor(now);
  }
}
