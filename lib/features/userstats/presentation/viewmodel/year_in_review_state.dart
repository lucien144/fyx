import 'package:flutter/foundation.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';

enum YearInReviewStatus { loading, ready, failed }

/// State of the Year in Review: the review being shown plus what the January
/// Window currently offers.
@immutable
class YearInReviewState {
  final YearInReviewStatus status;
  final YearInReview? review;

  /// Index of the slide on screen.
  final int index;

  /// The year the January Window is about; null while the window is closed.
  final int? windowYear;

  /// Active days of [windowYear].
  final int windowActiveDays;

  const YearInReviewState({
    this.status = YearInReviewStatus.loading,
    this.review,
    this.index = 0,
    this.windowYear,
    this.windowActiveDays = 0,
  });

  List<YearInReviewSlide> get slides => review?.slides ?? const [];

  YearInReviewSlide? get slide => index < slides.length ? slides[index] : null;

  bool get isLast => index >= slides.length - 1;

  YearInReviewState copyWith({
    YearInReviewStatus? status,
    YearInReview? review,
    bool clearReview = false,
    int? index,
    int? windowYear,
    bool clearWindowYear = false,
    int? windowActiveDays,
  }) {
    return YearInReviewState(
      status: status ?? this.status,
      review: clearReview ? null : (review ?? this.review),
      index: index ?? this.index,
      windowYear: clearWindowYear ? null : (windowYear ?? this.windowYear),
      windowActiveDays: windowActiveDays ?? this.windowActiveDays,
    );
  }
}
