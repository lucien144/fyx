import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/shared/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await PlatformAssetBundle().load('assets/lets-encrypt-r3.cer');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  setupServiceLocator();
  await FyxApp.init();
  runApp(ProviderScope(child: FyxApp()..setEnv(Environment.production)));
}
