class RatingResponse {
  final int? currentRating;
  final String myRating; // positive / negative
  final bool isGiven;
  final bool needsConfirmation;

  RatingResponse({required this.currentRating, required this.myRating, required this.isGiven, this.needsConfirmation = false});
}
