import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/LoginResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AUTH_STATES { AUTH_INVALID_USERNAME, AUTH_NEW, AUTH_EXISTING }

class ApiController {
  static ApiController _instance = ApiController._init();
  IApiProvider provider;
  bool isLoggingIn = false;

  factory ApiController() {
    return _instance;
  }

  ApiController._init() {
    provider = ApiProvider();
    provider.onAuthError = () {
      // API returns the same error on authorization as well as on normal data request. Therefore this "workaround".
      if (isLoggingIn) {
        return;
      }

      this.logout();
      PlatformTheme.error(L.AUTH_ERROR);
      PlatformApp.navigatorKey.currentState.pushNamed('/login');
    };
    provider.onError = (message) => PlatformTheme.error(message);
  }

  Future<LoginResponse> login(String nickname) async {
    isLoggingIn = true;
    Response response = await provider.login(nickname);
    var loginResponse = LoginResponse.fromJson(jsonDecode(response.data));
    if (!loginResponse.isAuthorized) {
      throwAuthException(loginResponse, message: 'Cannot authorize user.');
    }

    var prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.setString('token', loginResponse.authToken), prefs.setString('nickname', nickname)]);
    var credentials = Credentials(nickname, loginResponse.authToken);
    provider.setCredentials(credentials);
    isLoggingIn = false;
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

  Future<dynamic> loadDiscussion(int id, {int lastId}) async {
    var response = await provider.fetchDiscussion(id, lastId: lastId);
    return jsonDecode(response.data)['data'];
  }

  Future<Response> postDiscussionMessage(int id, String message, {List<Map<String, dynamic>> attachments}) {
    return provider.postDiscussionMessage(id, message, attachments: attachments);
  }

  void logout() {
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
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
