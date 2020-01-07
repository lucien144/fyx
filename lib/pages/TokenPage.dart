import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TokenPage extends StatefulWidget {
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  final BoxDecoration _boxDecoration = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: Color(0xff007F90)));
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        actionsForegroundColor: Colors.white,
        border: Border.all(color: Colors.transparent, width: 0.0, style: BorderStyle.none),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
        child: tokenFactory(context),
      ),
    );
  }

  Widget tokenFactory(BuildContext context) {
    final token = ModalRoute.of(context).settings.arguments;
    _tokenController.text = token;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: CupertinoTextField(
              decoration: _boxDecoration,
              controller: _tokenController,
              enabled: false,
            )),
            CupertinoButton(
              child: Icon(Icons.content_copy),
              onPressed: () {
                var data = ClipboardData(text: token);
                Clipboard.setData(data).then((_) => print('TODO: Toast it!'));
              },
            )
          ],
        ),
        CupertinoButton(
          child: Text(
            'Přihlásit',
            style: TextStyle(color: Color(0xff007F90)),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/home');
          },
          color: Colors.white,
        )
      ],
    );
  }
}
