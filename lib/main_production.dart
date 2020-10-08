import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyx/FyxApp.dart';
import 'package:sentry/sentry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  final sentry = SentryClient(dsn: DotEnv().env['SENTRY_KEY']);

  runZonedGuarded(
    () async {
      await FyxApp.init(sentry);
      return runApp(FyxApp()..setEnv(Environment.production));
    },
    (error, stackTrace) async {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );
}
