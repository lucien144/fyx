/// Enum representing types of global statistics
enum GlobalStatType {
  totalScrollPx('total_scroll_px'),
  likes('likes'),
  dislikes('dislikes');

  final String value;

  const GlobalStatType(this.value);

  /// Create StatType from string value
  static GlobalStatType? fromValue(String value) {
    return GlobalStatType.values.where((e) => e.value == value).firstOrNull;
  }
}
