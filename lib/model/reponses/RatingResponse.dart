class RatingResponse {
  final int currentRating;
  final String myRating; // positive / negative
  final bool isGiven;
  final bool _needsConfirmation;

  RatingResponse(
      {required this.currentRating,
      required this.myRating,
      required this.isGiven,
      needsConfirmation = false})
      : _needsConfirmation = needsConfirmation;

  bool get needsConfirmation => _needsConfirmation;
}
