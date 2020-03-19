import 'package:flutter/cupertino.dart';
import 'package:fyx/FyxApp.dart';

void main() async {
  await FyxApp.init();
  try {
    return runApp(FyxApp()..setEnv(Environment.dev));
  } catch (error) {
    return runApp(FyxApp()..setEnv(Environment.dev));
  }
}
