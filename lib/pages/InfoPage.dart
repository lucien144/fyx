import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:http/http.dart';

class InfoPageSettings {
  String url;
  String title;

  InfoPageSettings(this.title, this.url);
}

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  var _client = Client();
  Future<Response>? _response;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    InfoPageSettings settings = ModalRoute.of(context)!.settings.arguments as InfoPageSettings;

    if (_response == null) {
      _response = _client.get(Uri.parse(settings.url));
      AnalyticsProvider().setScreen(settings.title, 'InfoPage');
    }

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text(settings.title, style: TextStyle(color: colors.text)),
            leading: CupertinoNavigationBarBackButton(
              color: colors.primary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
        child: FutureBuilder<Response>(
            future: _response,
            builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
              if (snapshot.hasData) {
                return Markdown(data: snapshot.data!.body, styleSheet: MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context)), onTapLink: (String text, String? url, String title) => url != null ? T.openLink(url) : null);
              }
              if (snapshot.hasError) {
                return T.feedbackScreen(
                    context,
                    label: L.GENERAL_REFRESH,
                    isWarning: true,
                    title: L.GENERAL_ERROR,
                    onPress: () async {
                      setState(() => _response = _client.get(Uri.parse(settings.url)));
                    });
              }
              return T.feedbackScreen(context, isLoading: true);
            }));
  }
}
