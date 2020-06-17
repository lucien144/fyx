import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:http/http.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var _client = Client();
  Future<Response> _response;

  @override
  void initState() {
    super.initState();
    _response = _client.get('https://raw.githubusercontent.com/lucien144/fyx/develop/README.md');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            middle: Text(L.ABOUT),
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
                return Markdown(data: snapshot.data.body);
              }
              if (snapshot.hasError) {
                return PlatformTheme.feedbackScreen(
                    label: L.GENERAL_REFRESH,
                    isWarning: true,
                    title: L.GENERAL_ERROR,
                    onPress: () async {
                      setState(() => {_response = _client.get('https://raw.githubusercontent.com/lucien144/fyx/develop/README.md')});
                    });
              }
              return PlatformTheme.feedbackScreen(isLoading: true);
            }));
  }
}
