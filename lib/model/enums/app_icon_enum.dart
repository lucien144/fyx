/// The app icons a user can choose from. iOS only — Android has no supported
/// way to swap the launcher icon at runtime.
///
/// [alternateIconName] must match an App Icon set in `Assets.xcassets` that is
/// listed in the `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` build setting.
/// The default icon is represented by a null name, which is what iOS expects
/// when restoring the primary icon.
enum AppIconEnum {
  fyx(alternateIconName: null, label: 'Fyx', preview: 'assets/app_icon.png'),
  dark(alternateIconName: 'AppIconDark', label: 'Dark', preview: 'assets/app_icon-dark.png'),
  love(alternateIconName: 'AppIconLove', label: 'Fyx ❤️', preview: 'assets/app_icon-love.png'),
  original(alternateIconName: 'AppIconOriginal', label: 'Nyx', preview: 'assets/app_icon-orig.png'),
  typingBrigade(
    alternateIconName: 'AppIconTypingBrigade',
    label: 'Typing Brigade',
    preview: 'assets/app_icon-tb.png',
  );

  const AppIconEnum({required this.alternateIconName, required this.label, required this.preview});

  final String? alternateIconName;
  final String label;

  /// Flutter asset used for the preview tile in the picker.
  final String preview;

  static const AppIconEnum defaultIcon = AppIconEnum.fyx;

  /// Resolves an icon from the name iOS reports back; unknown names (e.g. an
  /// icon removed in a newer build) fall back to the default.
  static AppIconEnum fromAlternateIconName(String? name) {
    return AppIconEnum.values.firstWhere((icon) => icon.alternateIconName == name, orElse: () => defaultIcon);
  }
}
