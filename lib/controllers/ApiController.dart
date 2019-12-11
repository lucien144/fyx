import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fyx/controllers/ApiProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/LoginResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AUTH_STATES { AUTH_INVALID_USERNAME, AUTH_NEW, AUTH_EXISTING }

class ApiController {
  static ApiController _instance = ApiController._init();

  IApiProvider provider;

  factory ApiController() {
    return _instance;
  }

  ApiController._init() {
    provider = ApiProvider();
  }

  Future<LoginResponse> login(String nickname) async {
    Response response = await provider.login(nickname);
    var loginResponse = LoginResponse.fromJson(jsonDecode(response.data));
    if (!loginResponse.isAuthorized) {
      throwAuthException(loginResponse, message: 'Cannot authorize user.');
    }

    var prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.setString('token', loginResponse.authToken), prefs.setString('nickname', nickname)]);
    var credentials = Credentials(nickname, loginResponse.authToken);
    provider.setCredentials(credentials);
    return loginResponse;
  }

  Future<dynamic> loadHistory() async {
    var response = await provider.fetchHistory();
    return jsonDecode(response.data)['data'];
  }

  Future<dynamic> loadBookmarks() async {
    var response = await provider.fetchBookmarks();
    return jsonDecode(response.data)['data'];
  }

  throwAuthException(LoginResponse loginResponse, {String message: ''}) {
    var state = AUTH_STATES.values.firstWhere((state) => state.toString() == 'AUTH_STATES.${loginResponse.authState}', orElse: () => null);
    if (state != null) {
      switch (state) {
        case AUTH_STATES.AUTH_EXISTING:
          throw AuthException('Je mi líto, ale autorizace se nezdařila. Zkuste si vyresetovat autorizaci v nastavení nyxu.');
          break;
        case AUTH_STATES.AUTH_INVALID_USERNAME:
          throw AuthException('Špatné uživatelské jméno nebo heslo.');
          break;
        case AUTH_STATES.AUTH_NEW:
          // This is valid!
          break;
      }
    }

    if (loginResponse.authDevComment.isNotEmpty) {
      throw AuthException(loginResponse.authDevComment);
    }

    if (loginResponse.error.isNotEmpty) {
      throw AuthException(loginResponse.error);
    }

    throw AuthException(message);
  }
}
