import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/theme/T.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
      child: formFactory(context),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  Widget formFactory(context) {
    var offset = (MediaQuery.of(context).viewInsets.bottom / 3);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 120,
          padding: EdgeInsets.all(16),
          child: Image.asset(
            'assets/logo.png',
            color: T.COLOR_SECONDARY,
          ),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 16)]),
        ),
        AnimatedPadding(
          padding: EdgeInsets.only(top: 128 - offset),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            child: CupertinoTextField(
              enabled: !isRunning,
              placeholder: 'NICKNAME',
              controller: _loginController,
              decoration: T.TEXTFIELD_DECORATION,
            ),
          ),
        ),
        AnimatedPadding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 8),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            child: this._buildButton(context),
          ),
        )
      ],
    );
  }

  Widget _buildButton(context) {
    return Container(
      width: 200,
      child: CupertinoButton(
        child: isRunning
            ? CupertinoActivityIndicator()
            : Text(
                'Přihlásit',
                style: TextStyle(color: T.COLOR_SECONDARY),
              ),
        onPressed: () {
          if (isRunning) {
            return;
          }

          setState(() => isRunning = true);

          ApiController().login(_loginController.text).then((response) {
            setState(() {
              Navigator.of(context).pushNamed('/token', arguments: response.authCode);
            });
          }).catchError((error) {
            PlatformTheme.error(error.toString());
          }).whenComplete(() => setState(() => isRunning = false));
        },
        color: Colors.white,
      ),
    );
  }
}
