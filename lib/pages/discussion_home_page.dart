import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/reponses/DiscussionHomeResponse.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscussionHomePageArguments {
  final DiscussionResponse discussionResponse;

  DiscussionHomePageArguments(this.discussionResponse);
}

class DiscussionHomePage extends StatelessWidget {
  final bool header;
  DiscussionHomePage({Key? key, this.header = false}) : super(key: key) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    DiscussionHomePageArguments? pageArguments = ModalRoute.of(context)?.settings.arguments as DiscussionHomePageArguments?;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: colors.primary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width - 120,
            child: Text(
                // https://github.com/flutter/flutter/issues/18761
                Characters(pageArguments?.discussionResponse.discussion.nameMain ?? '').replaceAll(Characters(''), Characters('\u{200B}')).toString(),
                style: TextStyle(color: colors.text),
                overflow: TextOverflow.ellipsis)),
      ),
      child: FutureBuilder(
          future: this.header
              ? ApiController().getDiscussionHeader(pageArguments?.discussionResponse.discussion.idKlub ?? -1)
              : ApiController().getDiscussionHome(pageArguments?.discussionResponse.discussion.idKlub ?? -1),
          builder: (BuildContext context, AsyncSnapshot<DiscussionHomeResponse> snapshot) {
            if (snapshot.hasError) {
              return T.feedbackScreen(context,
                  isWarning: true, title: snapshot.error.toString(), label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop());
            } else if (snapshot.hasData) {
              final html = '''
              <!doctype html>
              <head>
                <meta http-equiv=Content-Type content="text/html; charset=UTF-8">
                <meta name=viewport content="width=device-width,initial-scale=1,maximum-scale=3,user-scalable=1">
                <link id=default-style rel="preload stylesheet" as=style href="https://nyx.cz/css/forest4/nc.css">
              </head>
              <body style="padding-top: 0;">
              ${snapshot.data?.items.map((item) => '<div style="margin: 10px; padding: 5px; border: 1px solid #617e6a;">${item.content ?? ''}</div>').join('')}
              </body>
              </html>
''';
              final String contentBase64 = base64Encode(const Utf8Encoder().convert(html));
              return WebView(
                initialUrl: 'data:text/html;base64,$contentBase64',
              );
            }
            return T.feedbackScreen(context, isLoading: true);
          }),
    );
  }
}
