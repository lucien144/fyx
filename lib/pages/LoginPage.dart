import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/reponses/LoginResponse.dart';
import 'package:fyx/pages/TutorialPage.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/NyxColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  bool _isRunning = false;
  bool _useTokenToLogin = false;

  @override
  void initState() {
    super.initState();

    _loginController.addListener(() {
      if (RegExp(r"FYXBOT|LUCIEN", caseSensitive: false).hasMatch(_loginController.text)) {
        setState(() => _useTokenToLogin = true);
      } else {
        setState(() => _useTokenToLogin = false);
      }
    });

    AnalyticsProvider().setScreen('Login', 'LoginPage');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: T.GRADIENT),
        child: formFactory(context),
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Widget formFactory(context) {
    NyxColors colors = Skin.of(context).theme.colors;
    final textfieldDecoration = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: colors.secondaryColor));

    var offset = (MediaQuery.of(context).viewInsets.bottom / 3);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 120,
          padding: EdgeInsets.all(16),
          child: Image.asset(
            'assets/logo.png',
            color: colors.secondaryColor,
          ),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 16)]),
        ),
        AnimatedPadding(
          padding: EdgeInsets.only(top: 128 - offset),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              CupertinoTextField(
                enabled: !_isRunning,
                textCapitalization: TextCapitalization.characters,
                placeholder: 'NICKNAME',
                controller: _loginController,
                decoration: textfieldDecoration,
                autocorrect: false,
              ),
              Visibility(
                visible: _useTokenToLogin,
                child: CupertinoTextField(
                  obscureText: true,
                  enabled: !_isRunning,
                  placeholder: 'TOKEN',
                  controller: _tokenController,
                  decoration: textfieldDecoration,
                  autocorrect: false,
                ),
              )
            ],
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
    NyxColors colors = Skin.of(context).theme.colors;

    return Container(
      width: 200,
      child: CupertinoButton(
        child: _isRunning
            ? CupertinoActivityIndicator()
            : Text(
                'Přihlásit',
                style: TextStyle(color: colors.secondaryColor),
              ),
        onPressed: () {
          if (_isRunning) {
            return;
          }

          setState(() => _isRunning = true);

          if (_useTokenToLogin && _tokenController.text.length > 0) {
            ApiController().setCredentials(Credentials(_loginController.text, _tokenController.text)).then((Credentials? credentials) {
              if (credentials != null) {
                // TODO: Refactor 👇? This is edge case usage...
                ApiController().provider.setCredentials(credentials);
                MainRepository().credentials = credentials;
                Navigator.of(context).pushNamed('/home');
              }
            }).whenComplete(() {
              setState(() => _isRunning = false);
            });
            return;
          }

          ApiController().login(_loginController.text).then((LoginResponse response) {
            Navigator.of(context).pushNamed('/token', arguments: new TutorialPageArguments(token: response.authCode, username: _loginController.text));
          }).catchError((error) {
            print(error);
            T.error(error.toString());
          }).whenComplete(() => setState(() => _isRunning = false));
        },
        color: Colors.white,
      ),
    );
  }
}
