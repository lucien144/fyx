import 'package:flutter/cupertino.dart';
import 'package:fyx/FyxApp.dart';

void main() async {
  FyxApp.init();
  try {
    return runApp(FyxApp()..setEnv(Environment.production));
  } catch (error) {
    return runApp(FyxApp()..setEnv(Environment.production));
  }
}
