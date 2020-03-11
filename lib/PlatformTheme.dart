import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyx/theme/L.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static error(String message, {int duration: 7}) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIos: duration, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
  }

  static openLink(String link) async {
    try {
      if (await canLaunch(link)) {
        await launch(link);
      } else {
        PlatformTheme.error(L.INAPPBROWSER_ERROR);
      }
    } catch (e) {
      PlatformTheme.error(L.INAPPBROWSER_ERROR);
    }
  }
}
