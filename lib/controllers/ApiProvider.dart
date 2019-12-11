import 'package:dio/dio.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider implements IApiProvider {
  final URL = 'https://www.nyx.cz/api.php';
  final OPTIONS = Options(headers: {'User-Agent': 'Fyx'});
  Credentials _credentials;

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
    SharedPreferences.getInstance().then((prefs) {
      _credentials = Credentials(prefs.getString('nickname'), prefs.getString('token'));
    });
  }

  Future<Response> login(String username) async {
    FormData formData = new FormData.fromMap({'auth_nick': username});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }

  Future<Response> fetchBookmarks() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'all'});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }

  Future<Response> fetchHistory() async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'bookmarks', 'l2': 'history'});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }

  Future<Response> fetchDiscussion(int id) async {
    FormData formData = new FormData.fromMap({'auth_nick': _credentials.nickname, 'auth_token': _credentials.token, 'l': 'discussion', 'l2': 'messages', 'id': id});
    return await Dio().post(URL, data: formData, options: OPTIONS);
  }
}
