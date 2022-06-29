import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/FyxApp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await PlatformAssetBundle().load('assets/lets-encrypt-r3.cer');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  await dotenv.load();

  runZonedGuarded(
    () async {
      await FyxApp.init();
      SentryFlutter.init((options) {
        options.dsn = dotenv.env['SENTRY_KEY'];
        options.environment = 'development';
      }, appRunner: () => runApp(ProviderScope(child: FyxApp()..setEnv(Environment.dev))));
    },
    (error, stackTrace) async {
      try {
        await Sentry.captureException(
          error,
          stackTrace: stackTrace,
        );
        print('Error sent to sentry.io: $error');
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
        print('Original error: $error');
      }
    },
  );
}
