import 'package:device_info/device_info.dart';
import 'package:fyx/controllers/NotificationsService.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

class MainRepository {
  // TODO: Refactor -> rename MainRepository to AppContext?
  static final MainRepository _singleton = MainRepository._internal();
  Credentials credentials;
  PackageInfo packageInfo;
  IosDeviceInfo deviceInfo;
  SettingsProvider settings;
  SentryClient sentry;
  NotificationService notifications;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();
}
