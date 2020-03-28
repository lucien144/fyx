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

  setCredentials(Credentials val) => _credentials = val.isValid ? val : null;

  ApiProvider() {
    try {
      DeviceInfoPlugin()
        ..iosInfo.then((iosInfo) {
          PackageInfo.fromPlatform().then((info) {
            // Basic sanitize due to the Xr unicode character and others...
            // TODO: Perhaps, solve Czech characters too...
            var deviceName = iosInfo.name.replaceAll(RegExp(r'[ʀ]', caseSensitive: false), 'r');
            deviceName = deviceName.replaceAll(RegExp(r'[^\w _\-]', caseSensitive: false), '_');
            _options.headers['user-agent'] = '${_options.headers['user-agent']} | ${iosInfo.systemName} | ${info.version} (${info.buildNumber}) | $deviceName';
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
      // Endpoints: Auth + pulling data
      if (data.containsKey('data')) {
        return response;
      }

      // All seems ok.
      // Endpoints: Send new message.
      // Endpoints: Rating given/removed.
      if (data.containsKey('result') && ['ok', 'RATING_GIVEN', 'RATING_REMOVED', 'RATING_NEEDS_CONFIRMATION', 'RATING_CHANGED'].indexOf(data['result']) > -1) {
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

  Future<Response> testAuth() async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'help',
      'l2': 'test',
    });
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchBookmarks() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'all'});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchHistory() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'history', 'more_results': 1});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchDiscussion(int id, {int lastId}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'messages',
      'id': id,
      'id_wu': lastId,
      'direction': lastId == null ? 'newest' : 'older'
    });
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> postDiscussionMessage(int id, String message, {Map<String, dynamic> attachment}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'send',
      'id': id,
      'message': message,
      'attachment': attachment is Map ? MultipartFile.fromBytes(attachment['bytes'], filename: attachment['filename']) : null
    });

    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'reminder',
      'id_klub': discussionId,
      'id_wu': postId,
      'reminder': setReminder ? 1 : 0
    });

    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> giveRating(int discussionId, int postId, bool positive, bool confirm) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'rating_give',
      'id_klub': discussionId,
      'id_wu': postId,
      'rating': positive ? 'positive' : 'negative',
      'toggle': 1,
      'neg_confirmation': confirm ? 1 : 0
    });

    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> logout() async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'util',
      'l2': 'remove_authorization',
    });

    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchMail({int lastId}) async {
    FormData formData = new FormData.fromMap(
        {'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'mail', 'l2': 'messages', 'id_mail': lastId, 'direction': lastId == null ? 'newest' : 'older'});
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> sendMail(String recipient, String message, {Map<String, dynamic> attachment}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'mail',
      'l2': 'send',
      'recipient': recipient,
      'message': message,
      'attachment': attachment is Map ? MultipartFile.fromBytes(attachment['bytes'], filename: attachment['filename']) : null
    });
    return await dio.post(URL, data: formData, options: _options);
  }
}
