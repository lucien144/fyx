/// The film character a Year in Review assigns from the share of positive
/// ratings among all ratings the user gave.
enum YearInReviewCharacter {
  forrestGump,
  gandalf,
  shrek,
  darthVader,
  silentBob;

  static YearInReviewCharacter fromRatings({required int likes, required int dislikes}) {
    final percent = positivePercent(likes: likes, dislikes: dislikes);
    if (percent == null) return silentBob;
    if (percent >= 95) return forrestGump;
    if (percent >= 75) return gandalf;
    if (percent >= 40) return shrek;
    return darthVader;
  }

  /// Rounded share of likes, or null when the user gave no rating at all.
  static int? positivePercent({required int likes, required int dislikes}) {
    final total = likes + dislikes;
    if (total <= 0) return null;
    return (likes * 100 / total).round();
  }
}
