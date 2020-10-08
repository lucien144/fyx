import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyx/model/MainRepository.dart';
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
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: duration,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static success(String message, {int duration: 7}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: duration,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0);
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

  static prefillGithubIssue(String body, {String title = ''}) async {
    var pkg = MainRepository().packageInfo;
    var device = MainRepository().deviceInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';
    var system = '${device.systemName} ${device.systemVersion} ${device.localizedModel}';

    var _body = Uri.encodeComponent('$body\n\n---\n*Verze: $version\niOS: $system*');
    var _title = Uri.encodeFull(title);
    var url = 'https://github.com/lucien144/fyx/issues/new?title=$_title&body=$_body&labels=user+report';
    PlatformTheme.openLink(url);
  }

  static Widget somethingsWrongButton(String content) {
    return GestureDetector(
      onTap: () => PlatformTheme.prefillGithubIssue('**Zdroj:**\n```$content```', title: 'Chyba zobrazení příspěvku'),
      child: Column(children: <Widget>[
        Icon(Icons.warning),
        Text(
          'Nastal problém se zobrazením příspěvku.\n Vyplňte prosím github issue kliknutím sem...',
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  static Widget feedbackScreen({bool isLoading = false, bool isWarning = false, String label = '', String title = '', Function onPress, IconData icon = Icons.warning}) {
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
            visible: (!isLoading && isWarning) || icon != Icons.warning,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon),
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
