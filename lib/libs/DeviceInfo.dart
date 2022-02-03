import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceInfo {
  late String systemName;
  late String systemVersion;
  late String localizedModel;

  static Future<DeviceInfo> init() async {
    return Platform.isIOS
        ? DeviceInfo.ios(await DeviceInfoPlugin().iosInfo)
        : DeviceInfo.adroid(await DeviceInfoPlugin().androidInfo);
  }

  DeviceInfo.ios(IosDeviceInfo info) {
    systemName = info.systemName;
    systemVersion = info.systemVersion;
    localizedModel = info.localizedModel;
  }

  DeviceInfo.adroid(AndroidDeviceInfo info) {
    systemName = info.device;
    systemVersion = info.version.codename;
    localizedModel = info.model;
  }
}
