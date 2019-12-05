import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/ApiController.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final BoxDecoration _boxDecoration = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: Color(0xff007F90)));
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
      child: _tokenController.text.isNotEmpty ? tokenFactory(context) : formFactory(),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Widget tokenFactory(BuildContext context) {
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
                var data = ClipboardData(text: _tokenController.text);
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

  Widget formFactory() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CupertinoTextField(
          placeholder: 'NICKNAME',
          controller: _loginController,
          decoration: _boxDecoration,
        ),
        SizedBox(
          height: 8,
        ),
        CupertinoButton(
          child: Text(
            'Přihlásit',
            style: TextStyle(color: Color(0xff007F90)),
          ),
          onPressed: () async {
            ApiController.login(_loginController.text).then((response) {
              setState(() {
                _tokenController.text = response.authCode;
              });
            });
          },
          color: Colors.white,
        )
      ],
    );
  }
}
