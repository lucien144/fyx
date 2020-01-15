import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/theme/L.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider implements IApiProvider {
  final Dio dio = Dio();

  // ignore: non_constant_identifier_names
  final URL = 'https://www.nyx.cz/api.php';

  Options _options = Options(headers: {'user-agent': 'Fyx'});

  Credentials _credentials;

  TOnError onError;
  TOnAuthError onAuthError;

  getCredentials() async {
    if (_credentials != null && _credentials.isValid) {
      return Future(() => _credentials);
    }
    var prefs = await SharedPreferences.getInstance();
    setCredentials(Credentials(prefs.getString('nickname'), prefs.getString('token')));
    return Future(() => _credentials);
  }

  setCredentials(Credentials val) => _credentials = val.isValid ? val : throw Exception('Invalid credentials');

  ApiProvider() {
    try {
      DeviceInfoPlugin()
        ..iosInfo.then((iosInfo) {
          PackageInfo.fromPlatform().then((info) {
            _options.headers['user-agent'] = '${_options.headers['user-agent']} | ${iosInfo.systemName} | ${info.version} (${info.buildNumber}) | ${iosInfo.name}';
          });
        });
    } catch (e) {}
    
    SharedPreferences.getInstance().then((prefs) {
      _credentials = Credentials(prefs.getString('nickname'), prefs.getString('token'));
    });

    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      print('[API] ${options.method.toUpperCase()}: ${options.uri}');
      print('[API] -> query: ${options.queryParameters}');
      print('[API] -> query: ${(options.data as FormData).fields}');
      return options;
    }, onResponse: (Response response) async {
      Map data = jsonDecode(response.data);

      // All seems ok.
      if (data.containsKey('data')) {
        return response;
      }

      // Not Authorized
      if (data['result'] == 'error' && data['code'] == '401') {
        onAuthError();
        return response;
      }

      // Other problem
      if (data['result'] == 'error') {
        onError(data['error']);
        return response;
      }

      // Malformed response
      onError(L.API_ERROR);
      return response;
    }, onError: (DioError e) async {
      onError(e.message);
    }));
  }

  Future<Response> login(String username) async {
    FormData formData = new FormData.fromMap({'auth_nick': username});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchBookmarks() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'all'});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchHistory() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'history'});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchDiscussion(int id) async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'discussion', 'l2': 'messages', 'id': id});
    return await dio.post(URL, data: formData, options: _options);
  }
}
