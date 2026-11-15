/// The label a Year in Review gives the user for their most active hour.
enum YearInReviewRhythm {
  earlyBird,
  craftsman,
  barfly,
  nightBird;

  /// [hour] is 0–23.
  static YearInReviewRhythm fromHour(int hour) {
    if (hour >= 5 && hour <= 9) return earlyBird;
    if (hour >= 10 && hour <= 19) return craftsman;
    if (hour >= 20 || hour == 0) return barfly;
    return nightBird;
  }
}
