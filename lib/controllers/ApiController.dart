import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/LoginResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {
  static const URL = 'https://www.nyx.cz/api.php';
  static final OPTIONS = Options(headers: {'User-Agent': 'Fyx'});
  static Credentials _credentials;

  static Future<LoginResponse> login(String nickname) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': nickname,
    });
    Response response = await Dio().post(URL, data: formData, options: OPTIONS);
    var loginResponse = LoginResponse.fromJson(jsonDecode(response.data));
    print(jsonDecode(response.data));
    var prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.setString('token', loginResponse.authToken), prefs.setString('nickname', nickname)]);
    _credentials = Credentials(nickname, loginResponse.authToken);

    return loginResponse;
  }

  static Future<Response> loadHistory() async {
    Credentials credentials = await ApiController.getCredentials();
    FormData formData = new FormData.fromMap({'auth_nick': credentials.nickname, 'auth_token': credentials.token, 'l': 'bookmarks', 'l2': 'history'});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }

  static Future<Response> loadBookmarks() async {
    Credentials credentials = await ApiController.getCredentials();
    FormData formData = new FormData.fromMap({'auth_nick': credentials.nickname, 'auth_token': credentials.token, 'l': 'bookmarks', 'l2': 'all'});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }

  static getCredentials() async {
    if (_credentials is Credentials && _credentials.isValid) {
      return Future(() => _credentials);
    }

    var prefs = await SharedPreferences.getInstance();
    return Future(() => Credentials(prefs.getString('nickname'), prefs.getString('token')));
  }
}
