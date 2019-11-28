import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlatformTheme {
  static of(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTheme.of(context);
    }
    if (Platform.isAndroid) {
      return Theme.of(context);
    }

    throw Exception('Invalid platform theme.');
  }
}
