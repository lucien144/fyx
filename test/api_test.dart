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
import 'package:shared_preferences/shared_preferences.dart';

class ApiMock implements IApiProvider {
  final String loginJsonResponse;

  ApiMock(this.loginJsonResponse);

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
  // TODO
  setCredentials(Credentials val) {}

  @override
  // TODO
  getCredentials() {}

  @override
  // TODO
  Future<Response> fetchDiscussion(int id) {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('nickname'), loginName);
    expect(prefs.getString('token'), '44a3d1241830ca61a592e28df783007d');
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
