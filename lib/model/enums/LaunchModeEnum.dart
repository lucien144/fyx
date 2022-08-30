import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

part 'LaunchModeEnum.g.dart';

@HiveType(typeId: 15)
enum LaunchModeEnum {
  /// Leaves the decision of how to launch the URL to the platform
  /// implementation.
  @HiveField(0)
  platformDefault,

  /// Loads the URL in an in-app web view (e.g., Safari View Controller).
  @HiveField(1)
  inAppWebView,

  /// Passes the URL to the OS to be handled by another application.
  @HiveField(2)
  externalApplication,

  /// Passes the URL to the OS to be handled by another non-browser application.
  @HiveField(3)
  externalNonBrowserApplication;

  LaunchMode get original {
    switch (this) {
      case LaunchModeEnum.platformDefault:
        return LaunchMode.platformDefault;
      case LaunchModeEnum.inAppWebView:
        return LaunchMode.inAppWebView;
      case LaunchModeEnum.externalApplication:
        return LaunchMode.externalApplication;
      case LaunchModeEnum.externalNonBrowserApplication:
        return LaunchMode.externalNonBrowserApplication;
      default:
        return LaunchMode.platformDefault;
    }
  }
}
