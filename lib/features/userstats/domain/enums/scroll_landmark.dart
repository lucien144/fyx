/// What a scrolled distance is compared to in a Year in Review.
enum ScrollLandmark {
  petrin(63.5),
  zizkov(216),
  everest(8849);

  /// Height of the landmark in meters.
  final double meters;

  const ScrollLandmark(this.meters);

  static ScrollLandmark fromMeters(double meters) {
    if (meters < 2000) return petrin;
    if (meters < 20000) return zizkov;
    return everest;
  }

  /// How many times the landmark fits into [distance] (whole times only).
  int countIn(double distance) => (distance / meters).floor();
}
