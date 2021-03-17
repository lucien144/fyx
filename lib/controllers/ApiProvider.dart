import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/theme/L.dart';
import 'package:package_info/package_info.dart';

class ApiProvider implements IApiProvider {
  final Dio dio = Dio();

  // ignore: non_constant_identifier_names
  final URL = 'https://alpha.nyx.cz/api';

  Options _options = Options(headers: {'user-agent': 'Fyx'});

  Credentials _credentials;

  TOnError onError;
  TOnAuthError onAuthError;
  TOnSystemData onSystemData;

  Credentials getCredentials() {
    if (_credentials != null && _credentials.isValid) {
      return _credentials;
    }
    return null;
  }

  Credentials setCredentials(Credentials creds) {
    if (creds != null && creds.isValid) {
      _credentials = creds;
    }
    return _credentials;
  }

  ApiProvider() {
    try {
      // TODO: Use the MainRepository() to obtain this info... or not?
      DeviceInfoPlugin()
        ..iosInfo.then((iosInfo) {
          PackageInfo.fromPlatform().then((info) {
            // Basic sanitize due to the Xr unicode character and others...
            // TODO: Perhaps, solve Czech characters too...
            var deviceName = iosInfo.name
                .replaceAll(RegExp(r'[ʀ]', caseSensitive: false), 'r');
            deviceName = deviceName.replaceAll(
                RegExp(r'[^\w _\-]', caseSensitive: false), '_');
            _options.headers['user-agent'] =
                '${_options.headers['user-agent']} | ${iosInfo.systemName} | ${info.version} (${info.buildNumber}) | $deviceName';
          });
        }).catchError((error) {
          _options.headers['user-agent'] =
              '${_options.headers['user-agent']} | Fyx';
        });
    } catch (e) {}

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      print('[API] ${options.method.toUpperCase()}: ${options.uri}');
      if (_credentials != null && _credentials.isValid) {
        print('[API] -> Bearer: ${_credentials.token}');
        options.headers['Authorization'] = 'Bearer ${_credentials.token}';
      }
      return options;
    }, onResponse: (Response response) async {
      // All seems ok.
      if (response.statusCode == 200) {
        return response;
      }

      // Malformed response
      onError(L.API_ERROR);
      return response;
    }, onError: (DioError e) async {
      // Not Authorized
      if (e.response?.statusCode == 401) {
        onAuthError(e.response.data['message']);
        return e.response;
      }

      // Other problem
      if (e.response?.statusCode == 400) {
        onError(e.response.data['message']);
        return e.response;
      }

      // Negative rating confirmation
      if (e.response?.statusCode == 403) {
        return e.response;
      }

      onError(e.message);
    }));
  }

  Future<Response> login(String username) async {
    return await dio.post('$URL/create_token/$username', options: _options);
  }

  Future<Response> registerFcmToken(String token) async {
    String client = 'fyx';
    return await dio.post(
        '$URL/register_for_notifications/${_credentials.token}/$client/$token',
        options: _options);
  }

  Future<Response> fetchBookmarks() async {
    return await dio.get('$URL/bookmarks/all', options: _options);
  }

  Future<Response> fetchHistory() async {
    return await dio.get('$URL/bookmarks/history/more', options: _options);
  }

  Future<Response> fetchDiscussion(int discussionId, {int lastId, String user}) async {
    Map<String, dynamic> params = {
      'order': lastId == null ? 'newest' : 'older_than',
      'from_id': lastId,
      'user': user
    };
    return await dio.get('$URL/discussion/$discussionId', queryParameters: params, options: _options);
  }

  Future<Response> fetchDiscussionHome(int id) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'home',
      'id_klub': id
    });
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> fetchNotices({bool keepNew = false}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'feed',
      'l2': 'notices',
      'keep_new': keepNew ? '1' : '0'
    });
    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> postDiscussionMessage(int id, String message,
      {Map<ATTACHMENT, dynamic> attachment}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'discussion',
      'l2': 'send',
      'id': id,
      'message': message,
      'attachment': attachment is Map
          ? MultipartFile.fromBytes(attachment[ATTACHMENT.bytes],
              filename: attachment[ATTACHMENT.filename])
          : null
    });

    return await dio.post(URL, data: formData, options: _options);
  }

  Future<Response> setPostReminder(
      int discussionId, int postId, bool setReminder) async {
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

  Future<Response> giveRating(
      int discussionId, int postId, bool positive, bool confirm, bool remove) async {
    String action = positive ? 'positive' : 'negative';
    action = remove ? 'remove' : action;
    action = confirm ? 'negative_visible' : action;
    return await dio.post('$URL/discussion/$discussionId/rating/$postId/$action', options: _options);
  }

  Future<Response> logout() async {
    return await dio.delete('$URL/profile/delete_token/${_credentials.token}', options: _options);
  }

  Future<Response> fetchMail({int lastId, String username}) async {
    Map<String, dynamic> params = {
      'order': lastId == null ? 'newest' : 'older_than',
      'from_id': lastId,
      'user': username
    };
    return await dio.get('$URL/mail', queryParameters: params, options: _options);
  }

  Future<Response> sendMail(String recipient, String message,
      {Map<ATTACHMENT, dynamic> attachment}) async {
    FormData formData = new FormData.fromMap({
      'auth_nick': _credentials.nickname,
      'auth_token': _credentials.token,
      'l': 'mail',
      'l2': 'send',
      'recipient': recipient,
      'message': message,
      'attachment': attachment is Map
          ? MultipartFile.fromBytes(attachment[ATTACHMENT.bytes],
              filename: attachment[ATTACHMENT.filename])
          : null
    });
    return await dio.post(URL, data: formData, options: _options);
  }
}
