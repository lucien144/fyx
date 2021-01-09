// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiMock implements IApiProvider {
  final String loginJsonResponse;
  TOnError onError;
  TOnAuthError onAuthError;
  Credentials _credentials;
  final bool emptyCredentials;

  ApiMock(this.loginJsonResponse, {this.emptyCredentials = false});

  @override
  Future<Response> login(String username) {
    // Invalid call (GET)
    // {"result":"error","code":"401","error":"Not Authorized"}

    // Not existing user
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_INVALID_USERNAME","auth_dev_comment":"Invalid username!"}

    // Not authorized existing user
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_NEW","auth_token":"44a3d1246830ca61a592e28df783007d","auth_code":"6f9a40647d","auth_dev_comment":"Direct user to PERSONAL \/ SETTINGS \/ AUTHORIZATIONS and tell him to accept request from this app. He will have to confirm it by transcribing passcode from [auth_code]. After confirming it, access using [token] should be working."}

    // Wrong token
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_EXISTING","auth_dev_comment":"There is already confirmed authorization for this App name, but you haven't provided correct token. If you you've lost your auth token, tell user to cancel existing authorization. It might be also caused by using the same App name by the same app on different devices or different apps."}

    return Future(() => Response<String>(data: this.loginJsonResponse));
  }

  @override
  // TODO
  Future<Response> fetchBookmarks() {
    return Future(() => Response<String>(data: ''));
  }

  @override
  // TODO
  Future<Response> fetchHistory() {
    return Future(() => Response<String>(data: ''));
  }

  @override
  var onSystemData;

  @override
  Future<Response> fetchDiscussion(int id, {int lastId, String user}) {
    // TODO: implement fetchDiscussion
    return null;
  }

  @override
  Future<Response> fetchMail({int lastId}) {
    // TODO: implement fetchMail
    return null;
  }

  @override
  Credentials getCredentials() {
    if (_credentials != null && _credentials.isValid) {
      return _credentials;
    }
    return null;
  }

  @override
  Credentials setCredentials(Credentials creds) {
    if (creds != null && creds.isValid) {
      _credentials = creds;
    }
    return _credentials;
  }


  @override
  Future<Response> giveRating(int discussionId, int postId, bool add, bool confirm) {
    // TODO: implement giveRating
    return null;
  }

  @override
  Future<Response> logout() {
    // TODO: implement logout
    return null;
  }

  @override
  Future<Response> postDiscussionMessage(int id, String message, {Map<ATTACHMENT, dynamic> attachment}) {
    // TODO: implement postDiscussionMessage
    return null;
  }

  @override
  Future<Response> sendMail(String recipient, String message, {Map<ATTACHMENT, dynamic> attachment}) {
    // TODO: implement sendMail
    return null;
  }

  @override
  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) {
    // TODO: implement setPostReminder
    return null;
  }

  @override
  Future<Response> testAuth() {
    // TODO: implement testAuth
    return null;
  }

  @override
  Future<Response> registerFcmToken(String token) {
    // TODO: implement registerFcmToken
    return null;
  }

  @override
  Future<Response> fetchDiscussionHome(int id) {
    // TODO: implement fetchDiscussionInfo
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchNotices({bool keepNew}) {
    // TODO: implement fetchNotices
    throw UnimplementedError();
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('User is not authorized.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock('{"result": "error", "code": "401", "error": "Not Authorized"}');
    expect(() async => await api.login(loginName), throwsA(predicate((e) => (e is AuthException && e.toString() == 'Not Authorized'))));
  });

  test('User is authorized.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock(
        '{"result": "error", "code": "401", "error": "Not Authorized", "auth_state": "AUTH_NEW", "auth_token": "44a3d1241830ca61a592e28df783007d", "auth_code": "6f9a10647d", "auth_dev_comment": "Direct user to PERSONAL \/ SETTINGS \/ AUTHORIZATIONS and tell him to accept request from this app. He will have to confirm it by transcribing passcode from [auth_code]. After confirming it, access using [token] should be working."}');
    var loginResponse = await api.login(loginName);
    expect(loginResponse.result, 'error');
    expect(loginResponse.code, 401);
    expect(loginResponse.error, 'Not Authorized');
    expect(loginResponse.authCode, '6f9a10647d');
    expect(loginResponse.authToken, '44a3d1241830ca61a592e28df783007d');
    expect(loginResponse.authState, 'AUTH_NEW');
    expect(loginResponse.isAuthorized, true);

    var creds = await api.getCredentials();
    expect(creds.nickname, loginName);
    expect(creds.token, '44a3d1241830ca61a592e28df783007d');
    expect(creds.fcmToken, null);
  });

  test('User is logged in and uses old identity storage.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock(
        '{"result": "error", "code": "401", "error": "Not Authorized", "auth_state": "AUTH_NEW", "auth_token": "44a3d1241830ca61a592e28df783007d", "auth_code": "6f9a10647d", "auth_dev_comment": "Direct user to PERSONAL \/ SETTINGS \/ AUTHORIZATIONS and tell him to accept request from this app. He will have to confirm it by transcribing passcode from [auth_code]. After confirming it, access using [token] should be working."}',
      emptyCredentials: true // 👀 👈
    );

    var prefs = await SharedPreferences.getInstance();
    String identity = prefs.getString('identity');
    expect(identity, null);

    // Set the old storage manually.
    await Future.wait([prefs.setString('nickname', loginName), prefs.setString('token', '44a3d1241830ca61a592e28df783007d')]);

    // Load the credentials
    var creds = await api.getCredentials();

    // Check the identity object
    expect(creds.nickname, loginName);
    expect(creds.token, '44a3d1241830ca61a592e28df783007d');
    expect(creds.fcmToken, null);

    // Reload the prefs
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('identity'), '{"nickname":"TOMMYSHELBY","token":"44a3d1241830ca61a592e28df783007d","fcmToken":null}');
    expect(prefs.getString('nickname'), null);
    expect(prefs.getString('token'), null);
  });

  test('User types invalid username.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock('{"result": "error", "code": "401", "error": "Not Authorized", "auth_state": "AUTH_INVALID_USERNAME", "auth_dev_comment": "Invalid username!"}');
    expect(() async => await api.login(loginName), throwsA(predicate((e) => (e is AuthException && e.toString() == 'Špatné uživatelské jméno nebo heslo.'))));
  });

  test('User uses wrong token.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock(
        '{"result": "error", "code": "401", "error": "Not Authorized", "auth_state": "AUTH_EXISTING", "auth_dev_comment": "There is already confirmed authorization for this App name, but you haven\'t provided correct token. If you you\'ve lost your auth token, tell user to cancel existing authorization. It might be also caused by using the same App name by the same app on different devices or different apps."}');
    expect(() async => await api.login(loginName),
        throwsA(predicate((e) => (e is AuthException && e.toString() == 'Je mi líto, ale autorizace se nezdařila. Zkuste si vyresetovat autorizaci v nastavení nyxu.'))));
  });
}
