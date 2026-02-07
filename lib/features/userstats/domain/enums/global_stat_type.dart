/// Enum representing types of global statistics
enum GlobalStatType {
  totalScrollPx('total_scroll_px');

  final String value;

  const GlobalStatType(this.value);

  /// Create StatType from string value
  static GlobalStatType? fromValue(String value) {
    return GlobalStatType.values.where((e) => e.value == value).firstOrNull;
  }
}
