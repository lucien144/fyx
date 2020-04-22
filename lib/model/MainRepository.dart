import 'package:device_info/device_info.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:package_info/package_info.dart';

class MainRepository {
  static final MainRepository _singleton = MainRepository._internal();
  Credentials credentials;
  PackageInfo packageInfo;
  IosDeviceInfo iosDeviceInfo;
  AndroidDeviceInfo androidDeviceInfo;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();
}
