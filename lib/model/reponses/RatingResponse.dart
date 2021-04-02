import 'package:flutter/cupertino.dart';

class RatingResponse {
  final int currentRating;
  final String myRating; // positive / negative
  final bool isGiven;
  final bool _needsConfirmation;

  RatingResponse(
      {this.currentRating,
      this.myRating,
      this.isGiven,
      needsConfirmation = false})
      : _needsConfirmation = needsConfirmation;

  bool get needsConfirmation => _needsConfirmation;
}
