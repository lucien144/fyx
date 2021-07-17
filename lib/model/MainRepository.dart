import 'package:fyx/controllers/NotificationsService.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/libs/DeviceInfo.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:package_info/package_info.dart';

class MainRepository {
  // TODO: Refactor -> rename MainRepository to AppContext?
  static final MainRepository _singleton = MainRepository._internal();
  late Credentials credentials;
  late PackageInfo packageInfo;
  late DeviceInfo deviceInfo;
  late SettingsProvider settings;
  late NotificationService notifications;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();
}
