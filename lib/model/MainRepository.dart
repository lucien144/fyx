import 'package:device_info/device_info.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

class MainRepository {
  static final MainRepository _singleton = MainRepository._internal();
  Credentials credentials;
  PackageInfo packageInfo;
  IosDeviceInfo deviceInfo;
  SettingsProvider settings;
  SentryClient sentry;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();
}
