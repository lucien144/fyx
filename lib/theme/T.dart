// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/LaunchModeEnum.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:url_launcher/url_launcher.dart';

// Theme helpers
class T {
  static nsfwMask() => ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
          )));

  // ************************
  // Theme mixins
  // ************************
  static error(String message, {int duration = 7, Color bg = Colors.red}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: duration,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static success(String message, {int duration = 7, Color bg = Colors.green}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: duration,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static warn(String message, {int duration = 7, Color bg = Colors.orangeAccent}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: duration,
        backgroundColor: bg,
        textColor: Colors.black,
        fontSize: 14.0);
  }

  static Future<bool> openLink(String link, {mode = LaunchModeEnum.externalApplication}) async {
    try {
      var encodedUri = Uri.parse(link);

      // canLaunchUrl returns false on Android, if app handling the http(s) url is installed, even though launchUrl works afterwards
      if (['http', 'https'].contains(encodedUri.scheme)) {
        var canLaunch = await canLaunchUrl(encodedUri);
        if (!canLaunch) {
          throw ('Cannot launch url: $link');
        }
      } else if (['mailto', 'tel'].contains(encodedUri.scheme)) {
        launchUrl(encodedUri);
        return true;
      }

      var status = await launchUrl(encodedUri, mode: mode.original);
      if (!status) {
        throw ('Cannot open webview. URL: $link');
      }

      return true;
    } catch (e) {
      T.error(L.INAPPBROWSER_ERROR);
      LogService.captureError(e);
      return false;
    }
  }

  static prefillGithubIssue({required MainRepository appContext, String title = '', String body = '', String user = '-', String url = ''}) async {
    var version = '-';
    var system = '-';
    var phone = '-';
    var pkg = appContext.packageInfo;
    var device = appContext.deviceInfo;
    version = Uri.encodeComponent('${pkg.version} (${pkg.buildNumber})');
    system = Uri.encodeComponent('${device.systemName} ${device.systemVersion}');
    phone = Uri.encodeComponent(device.localizedModel);

    var _body = Uri.encodeComponent(body);
    var _title = Uri.encodeComponent(title);
    var _url = Uri.encodeComponent(url);
    var link =
        'https://docs.google.com/forms/d/e/1FAIpQLSdbUIaF8IFd-ybZVXARRmtdgIGbSuYg7Vs1HDCYUJrJFInV8w/viewform?entry.76077276=$_title&entry.1416760014=$_body&entry.1520830537=$version&entry.931510077=$user&entry.594008397=$system&entry.1758179395=$phone&entry.17618653=$_url';
    T.openLink(link, mode: appContext.settings.linksMode);
  }

  static Widget somethingsWrongButton(String content,
      {String url = '', IconData icon = Icons.warning, String title = 'Chyba zobrazení příspěvku.', String stack = ''}) {
    return GestureDetector(
      onTap: () => T.prefillGithubIssue(
          title: title,
          body: '**Zdroj:**\n```$content```\n\n**Stack:**\n```$stack```',
          user: MainRepository().credentials!.nickname,
          url: url,
          appContext: MainRepository()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Icon(
          icon,
          size: 48,
        ),
        Text(
          '$title\n Problém nahlásíte kliknutím zde.',
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  static Widget feedbackScreen(BuildContext context,
      {bool isLoading = false, bool isWarning = false, String label = '', String title = '', VoidCallback? onPress, IconData icon = Icons.warning}) {
    return Container(
      width: double.infinity,
      color: (Skin.of(context).theme.colors as SkinColors).background,
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
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: isWarning
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        title,
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14),
                      ))
                  : Text(title),
            ),
          ),
          Visibility(
            visible: !isLoading && onPress is Function,
            child: CupertinoButton(
              child: Text(label),
              onPressed: onPress,
            ),
          )
        ],
      ),
    );
  }
}
