import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Move some methods to Helpers?
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

  static Future<bool> openLink(String link) async {
    try {
      var status = await launch(link);
      if (status == false) {
        throw ('Cannot open webview. URL: $link');
      }
      return true;
    } catch (e) {
      PlatformTheme.error(L.INAPPBROWSER_ERROR);
      MainRepository().sentry.captureException(exception: e);
      return false;
    }
  }

  static prefillGithubIssue({MainRepository appContext, String title = '', String body = '', String user = '-', String url = ''}) async {
    var version = '-';
    var system = '-';
    var phone = '-';
    if (appContext != null) {
      var pkg = appContext.packageInfo;
      var device = appContext.deviceInfo;
      version = Uri.encodeComponent('${pkg.version} (${pkg.buildNumber})');
      system = Uri.encodeComponent('${device.systemName} ${device.systemVersion}');
      phone = Uri.encodeComponent(device.localizedModel);
    }

    var _body = Uri.encodeComponent(body);
    var _title = Uri.encodeComponent(title);
    var _url = Uri.encodeComponent(url);
    var link = 'https://docs.google.com/forms/d/e/1FAIpQLSdbUIaF8IFd-ybZVXARRmtdgIGbSuYg7Vs1HDCYUJrJFInV8w/viewform?entry.76077276=$_title&entry.1416760014=$_body&entry.1520830537=$version&entry.931510077=$user&entry.594008397=$system&entry.1758179395=$phone&entry.17618653=$_url';
    PlatformTheme.openLink(link);
  }

  static Widget somethingsWrongButton(String content, {String url = ''}) {
    return GestureDetector(
      onTap: () => PlatformTheme.prefillGithubIssue(title: 'Chyba zobrazení příspěvku', body: '**Zdroj:**\n```$content```', user: MainRepository().credentials.nickname, url: url, appContext: MainRepository()),
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
