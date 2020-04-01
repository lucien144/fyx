import 'package:flutter/cupertino.dart';

class RatingResponse {
  final int currentRating;
  final int currentRatingStep;
  final bool isGiven;
  final bool _needsConfirmation;

  RatingResponse({@required this.currentRating, @required this.currentRatingStep, @required this.isGiven, needsConfirmation = false})
      : assert(currentRating != null && currentRatingStep != null && isGiven != null),
        _needsConfirmation = needsConfirmation;

  bool get needsConfirmation => _needsConfirmation;
}
