import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyx/FyxApp.dart';
import 'package:sentry/sentry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  final sentry = SentryClient(dsn: DotEnv().env['SENTRY_KEY'], environmentAttributes: const Event(environment: 'development'));

  runZonedGuarded(
    () async {
      await FyxApp.init(sentry);
      return runApp(FyxApp()..setEnv(Environment.dev));
    },
    (error, stackTrace) async {
      try {
        await sentry.captureException(
          exception: error,
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
