// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:sentry/sentry.dart';
import 'package:url_launcher/url_launcher.dart';

// Theme helpers
class T {
  // ************************
  // Colors
  // ************************

  // Color scheme -> https://mycolor.space/?hex=%231AD592&sub=1
  static const Color COLOR_PRIMARY = Color(0xFF196378);
  static const Color COLOR_SECONDARY = Color(0xff007F90);
  static const Color COLOR_LIGHT = Color(0xffE9F3F5);
  static const Color COLOR_BLACK = Color(0xFF282828);
  static const Color COLOR_ACCENT = Color(0xffB60F0F);

  // Others
  static final BoxShadow BOX_SHADOW = BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16);
  static final BoxDecoration TEXTFIELD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_SHADOW_DECORATION =
      BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY), boxShadow: [BOX_SHADOW]);
  static final LinearGradient GRADIENT = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)]);


  // ************************
  // Theme mixins
  // ************************
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
      T.error(L.INAPPBROWSER_ERROR);
      Sentry.captureException(e);
      return false;
    }
  }

  static prefillGithubIssue({MainRepository? appContext, String title = '', String body = '', String user = '-', String url = ''}) async {
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
    var link =
        'https://docs.google.com/forms/d/e/1FAIpQLSdbUIaF8IFd-ybZVXARRmtdgIGbSuYg7Vs1HDCYUJrJFInV8w/viewform?entry.76077276=$_title&entry.1416760014=$_body&entry.1520830537=$version&entry.931510077=$user&entry.594008397=$system&entry.1758179395=$phone&entry.17618653=$_url';
    T.openLink(link);
  }

  static Widget somethingsWrongButton(String content, {String url = '', IconData icon = Icons.warning, String title = 'Chyba zobrazení příspěvku.', String stack = ''}) {
    return GestureDetector(
      onTap: () => T.prefillGithubIssue(
          title: title, body: '**Zdroj:**\n```$content```\n\n**Stack:**\n```$stack```', user: MainRepository().credentials!.nickname, url: url, appContext: MainRepository()),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Icon(icon, size: 48,),
        Text(
          '$title\n Problém nahlásíte kliknutím zde.',
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  static Widget feedbackScreen({bool isLoading = false, bool isWarning = false, String label = '', String title = '', VoidCallback? onPress, IconData icon = Icons.warning}) {
    return Container(
      width: double.infinity,
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
                      decoration: BoxDecoration(color: T.COLOR_LIGHT, border: Border.all(width: 1, color: T.COLOR_PRIMARY), borderRadius: BorderRadius.circular(8)),
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
              color: T.COLOR_PRIMARY,
              child: Text(label),
              onPressed: onPress,
            ),
          )
        ],
      ),
    );
  }
}
