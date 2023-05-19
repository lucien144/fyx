import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/reponses/LoginResponse.dart';
import 'package:fyx/pages/TutorialPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  late SkinColors colors;
  bool _isRunning = false;
  bool _useTokenToLogin = false;
  bool _terms = false;

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
    colors = Skin.of(context).theme.colors;

    return WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: colors.gradient),
                  child: formFactory(),
                ))));
  }

  @override
  void dispose() {
    _loginController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Widget formFactory() {
    final textfieldDecoration =
        BoxDecoration(borderRadius: BorderRadius.circular(4), color: colors.background, border: Border.all(color: colors.background));

    var offset = 128 - (MediaQuery.of(context).viewInsets.bottom / 3);
    offset = offset > 0 ? offset : 20;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: 120,
          padding: EdgeInsets.all(16),
          child: Image.asset(
            'assets/logo.png',
            color: colors.primary,
          ),
          decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: colors.dark, offset: Offset(0, 0), blurRadius: 16)]),
        ),
        AnimatedPadding(
          padding: EdgeInsets.only(top: offset),
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoTextField(
                    obscureText: true,
                    enabled: !_isRunning,
                    placeholder: 'TOKEN',
                    controller: _tokenController,
                    decoration: textfieldDecoration,
                    autocorrect: false,
                  ),
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
            child: Column(
              children: [
                this._buildButton(context),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoSwitch(
                      activeColor: colors.highlight,
                      thumbColor: colors.background,
                      trackColor: colors.primary,
                      onChanged: (bool? value) => setState(() => _terms = value ?? false),
                      value: _terms,
                    ),
                    GestureDetector(
                      child: Text(
                        'Souhlasím s podmínkami užití.',
                        style: TextStyle(color: colors.light),
                      ),
                      onTap: () => setState(() => _terms = !_terms),
                    )
                  ],
                ),
                GestureDetector(
                  child: Text(
                    '${L.TERMS} ↗',
                    style: TextStyle(decoration: TextDecoration.underline, color: colors.light, fontSize: 13),
                  ),
                  onTap: () => T.openLink('https://nyx.cz/terms'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Container(
      width: 200,
      child: CupertinoButton(
        disabledColor: colors.light.withOpacity(.3),
        child: _isRunning
            ? CupertinoActivityIndicator()
            : Text(
                'Přihlásit',
                style: TextStyle(color: colors.primary),
              ),
        onPressed: _isRunning || !_terms || _loginController.text.length == 0
            ? null
            : () {
                setState(() => _isRunning = true);

                if (_useTokenToLogin && _tokenController.text.length > 0) {
                  ApiController().setCredentials(Credentials(_loginController.text, _tokenController.text)).then((Credentials? credentials) {
                    if (credentials != null) {
                      // TODO: Refactor 👇? This is edge case usage...
                      ApiController().provider.setCredentials(credentials);
                      MainRepository().credentials = credentials;
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  }).whenComplete(() {
                    setState(() => _isRunning = false);
                  });
                  return;
                }

                ApiController().login(_loginController.text).then((LoginResponse response) {
                  Navigator.of(context)
                      .pushNamed('/token', arguments: new TutorialPageArguments(token: response.authCode, username: _loginController.text));
                }).catchError((error) {
                  print(error);
                  T.error(error.toString(), bg: colors.danger);
                }).whenComplete(() => setState(() => _isRunning = false));
              },
        color: colors.background,
      ),
    );
  }
}
