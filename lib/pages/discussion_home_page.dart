import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/discussion_page_scaffold.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/reponses/DiscussionHomeResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscussionHomePageArguments {
  final int discussionId;

  /// Known upfront when navigating from within the discussion, unknown when
  /// the page is opened through a deeplink. Saves an empty navigation bar
  /// while the content is loading.
  final String? title;

  DiscussionHomePageArguments(this.discussionId, {this.title});
}

class DiscussionHomePage extends StatelessWidget {
  final bool header;

  DiscussionHomePage({Key? key, this.header = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DiscussionHomePageArguments? pageArguments = ModalRoute.of(context)?.settings.arguments as DiscussionHomePageArguments?;

    return FutureBuilder(
        future: this.header
            ? ApiController().getDiscussionHeader(pageArguments?.discussionId ?? -1)
            : ApiController().getDiscussionHome(pageArguments?.discussionId ?? -1),
        builder: (BuildContext context, AsyncSnapshot<DiscussionHomeResponse> snapshot) {
          final title = pageArguments?.title ?? snapshot.data?.discussion.name ?? '';

          if (snapshot.hasError) {
            return DiscussionPageScaffold(
                title: title,
                child: T.feedbackScreen(context,
                    isWarning: true, title: snapshot.error.toString(), label: L.GENERAL_CLOSE, onPress: () => Navigator.of(context).pop()));
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
            final controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString(html);
            return DiscussionPageScaffold(
                title: title,
                child: WebViewWidget(
                  controller: controller,
                ));
          }
          return DiscussionPageScaffold(title: title, child: T.feedbackScreen(context, isLoading: true));
        });
  }
}
