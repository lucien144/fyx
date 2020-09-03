import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyx/FyxApp.dart';
import 'package:sentry/sentry.dart';

void main() async {
  await DotEnv().load('.env');
  final sentry = SentryClient(dsn: DotEnv().env['SENTRY_KEY']);

  FlutterError.onError = (details, {bool forceReport = false}) {
    sentry.captureException(
      exception: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
        () async {
      await FyxApp.init();
      return runApp(FyxApp()..setEnv(Environment.production));
    },
        (error, stackTrace) {
      sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );
}
