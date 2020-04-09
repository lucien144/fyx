import 'package:device_info/device_info.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:package_info/package_info.dart';

class MainRepository {
  static final MainRepository _singleton = MainRepository._internal();
  Credentials _credentials;
  PackageInfo _packageInfo;
  IosDeviceInfo _deviceInfo;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();

  set credentials(Credentials value) {
    _credentials = value;
  }

  Credentials get credentials => _credentials;

  PackageInfo get packageInfo => _packageInfo;

  set packageInfo(PackageInfo value) {
    _packageInfo = value;
  }

  IosDeviceInfo get deviceInfo => _deviceInfo;

  set deviceInfo(IosDeviceInfo value) {
    _deviceInfo = value;
  }
}
