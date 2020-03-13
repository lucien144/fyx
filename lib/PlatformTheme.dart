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

  static Widget feedbackScreen({bool isLoading = false, bool isWarning = false, String label = '', String title = '', Function onPress}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: isLoading && !isWarning,
            child: CupertinoActivityIndicator(
              radius: 16,
            ),
          ),
          Visibility(
            visible: !isLoading && isWarning,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.warning),
            ),
          ),
          Visibility(
            visible: title.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title),
            ),
          ),
          Visibility(
            visible: !isLoading && onPress is Function,
            child: CupertinoButton(
              color: Colors.black26,
              child: Text(label),
              onPressed: onPress,
            ),
          )
        ],
      ),
    );
  }
}
