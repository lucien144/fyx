import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
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
  Future<Response> _response;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InfoPageSettings settings = ModalRoute.of(context).settings.arguments;

    if (_response == null) {
      _response = _client.get(settings.url);
      AnalyticsProvider().setScreen(settings.title, 'InfoPage');
    }

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            middle: Text(settings.title),
            leading: CupertinoNavigationBarBackButton(
              color: T.COLOR_PRIMARY,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
        child: FutureBuilder<Response>(
            future: _response,
            builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
              if (snapshot.hasData) {
                return Markdown(data: snapshot.data.body, onTapLink: (String url) => PlatformTheme.openLink(url));
              }
              if (snapshot.hasError) {
                return PlatformTheme.feedbackScreen(
                    label: L.GENERAL_REFRESH,
                    isWarning: true,
                    title: L.GENERAL_ERROR,
                    onPress: () async {
                      setState(() => _response = _client.get(settings.url));
                    });
              }
              return PlatformTheme.feedbackScreen(isLoading: true);
            }));
  }
}
