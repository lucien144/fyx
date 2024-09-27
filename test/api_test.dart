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
  final Map<String, dynamic> loginJsonResponse;
  TOnError? onError;
  TOnAuthError? onAuthError;
  Credentials? _credentials;
  final bool emptyCredentials;

  ApiMock(this.loginJsonResponse, {this.emptyCredentials = false});

  @override
  Future<Response> login(String username) {
    // TODO update examples
    // Invalid call (GET)
    // {"result":"error","code":"401","error":"Not Authorized"}

    // Not existing user
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_INVALID_USERNAME","auth_dev_comment":"Invalid username!"}

    // Not authorized existing user
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_NEW","auth_token":"44a3d1246830ca61a592e28df783007d","auth_code":"6f9a40647d","auth_dev_comment":"Direct user to PERSONAL \/ SETTINGS \/ AUTHORIZATIONS and tell him to accept request from this app. He will have to confirm it by transcribing passcode from [auth_code]. After confirming it, access using [token] should be working."}

    // Wrong token
    // {"result":"error","code":"401","error":"Not Authorized","auth_state":"AUTH_EXISTING","auth_dev_comment":"There is already confirmed authorization for this App name, but you haven't provided correct token. If you you've lost your auth token, tell user to cancel existing authorization. It might be also caused by using the same App name by the same app on different devices or different apps."}

    return Future(() => Response<Map<String, dynamic>>(data: this.loginJsonResponse, requestOptions: RequestOptions(path: 'dummy')));
  }

  @override
  // TODO
  Future<Response> fetchBookmarks() {
    throw UnimplementedError();
  }

  @override
  // TODO
  Future<Response> fetchHistory() {
    throw UnimplementedError();
  }

  @override
  var onContextData;

  @override
  Future<Response> fetchDiscussion(int id, {int? lastId, String? search, String? user, bool filterReplies = false}) {
    // TODO: implement fetchDiscussion
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchMail({int? lastId}) {
    // TODO: implement fetchMail
    throw UnimplementedError();
  }

  @override
  Credentials? getCredentials() {
    if (_credentials != null && _credentials!.isValid) {
      return _credentials;
    }
    return null;
  }

  @override
  Credentials? setCredentials(Credentials? creds) {
    if (creds != null && creds.isValid) {
      _credentials = creds;
    }
    return _credentials;
  }

  @override
  Future<Response> giveRating(int discussionId, int postId, bool add, bool confirm, bool remove) {
    // TODO: implement giveRating
    throw UnimplementedError();
  }

  @override
  Future<Response> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<Response> postDiscussionMessage(int id, String message, {Map<ATTACHMENT, dynamic>? attachment}) {
    // TODO: implement postDiscussionMessage
    throw UnimplementedError();
  }

  @override
  Future<Response> sendMail(String recipient, String message, {Map<ATTACHMENT, dynamic>? attachment}) {
    // TODO: implement sendMail
    throw UnimplementedError();
  }

  @override
  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) {
    // TODO: implement setPostReminder
    throw UnimplementedError();
  }

  @override
  Future<Response> testAuth() {
    // TODO: implement testAuth
    throw UnimplementedError();
  }

  @override
  Future<Response> registerFcmToken(String token) {
    // TODO: implement registerFcmToken
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchDiscussionHome(int id) {
    // TODO: implement fetchDiscussionInfo
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchNotices() {
    // TODO: implement fetchNotices
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteFile(int id) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchDiscussionWaitingFiles(int id) {
    // TODO: implement fetchDiscussionWaitingFiles
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchMailWaitingFiles() {
    // TODO: implement fetchMailWaitingFiles
    throw UnimplementedError();
  }

  @override
  Future<List> uploadFile(List<Map<ATTACHMENT, dynamic>> attachments, {int? id}) {
    // TODO: implement uploadFile
    throw UnimplementedError();
  }

  @override
  Future<Response> votePoll(int discussionId, int postId, List<int> votes) {
    // TODO: implement votePoll
    throw UnimplementedError();
  }

  @override
  Future<Response> rollDice(int discussionId, int postId) {
    // TODO: implement rollDice
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteDiscussionMessage(int discussionId, int postId) {
    // TODO: implement deleteDiscussionMessage
    throw UnimplementedError();
  }

  @override
  Future<Response> getPostRatings(int discussionId, int postId) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> searchDiscussions(String term) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> bookmarkDiscussion(int id, bool state) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchDiscussionHeader(int id) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> setDiscussionRights(int id, {required String username, required String right, required bool set}) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> setDiscussionRightsDaysLeft(int id, {required String username, required int daysLeft}) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> search(String term, {int? lastId}) {
    // TODO: implement getPostRatings
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchLast() {
    // TODO: implement fetchLast
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchReminders() {
    // TODO: implement fetchReminders
    throw UnimplementedError();
  }

  @override
  Future<Response> discussionCreateRequest(int discussionId, int postId, [bool against = false]) {
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteMail(int mailId) {
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
    api.provider = ApiMock({"message": "Not Authorized", "code": "401", "error": true});
    expect(() async => await api.login(loginName), throwsA(predicate((e) => (e is AuthException && e.toString() == 'Not Authorized'))));
  });

  test('User is authorized.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock({"id": 1212, "token": "44a3d1241830ca61a592e28df783007d", "confirmation_code": "6f9a10647d"});
    var loginResponse = await api.login(loginName);
    expect(loginResponse.code, 0);
    expect(loginResponse.error, false);
    expect(loginResponse.authCode, '6f9a10647d');
    expect(loginResponse.authToken, '44a3d1241830ca61a592e28df783007d');
    expect(loginResponse.isAuthorized, true);

    var creds = await api.getCredentials();
    expect(creds?.nickname, loginName);
    expect(creds?.token, '44a3d1241830ca61a592e28df783007d');
    expect(creds?.fcmToken, null);
  });

  test('User is logged in and uses old identity storage.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock({
      "result": "error",
      "code": "401",
      "error": true,
      "auth_state": "AUTH_NEW",
      "auth_token": "44a3d1241830ca61a592e28df783007d",
      "auth_code": "6f9a10647d",
      "auth_dev_comment":
          "Direct user to PERSONAL \/ SETTINGS \/ AUTHORIZATIONS and tell him to accept request from this app. He will have to confirm it by transcribing passcode from [auth_code]. After confirming it, access using [token] should be working."
    }, emptyCredentials: true // 👀 👈
        );

    var prefs = await SharedPreferences.getInstance();
    String? identity = prefs.getString('identity');
    expect(identity, null);

    // Set the old storage manually.
    await Future.wait([prefs.setString('nickname', loginName), prefs.setString('token', '44a3d1241830ca61a592e28df783007d')]);

    // Load the credentials
    var creds = await api.getCredentials();

    // Check the identity object
    expect(creds?.nickname, loginName);
    expect(creds?.token, '44a3d1241830ca61a592e28df783007d');
    expect(creds?.fcmToken, null);

    // Reload the prefs
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('identity'), '{"nickname":"TOMMYSHELBY","token":"44a3d1241830ca61a592e28df783007d","fcmToken":null}');
    expect(prefs.getString('nickname'), null);
    expect(prefs.getString('token'), null);
  });

  test('User types invalid username.', () async {
    var loginName = 'TOMMYSHELBY';

    var api = ApiController();
    api.provider = ApiMock({"error": true, "message": "Nepodařilo se načíst uživatele."});
    expect(
        () async => await api.login(loginName), throwsA(predicate((e) => (e is AuthException && e.toString() == 'Nepodařilo se načíst uživatele.'))));
  });

  // TODO is this still possible response? Can't reproduce it
  // test('User uses wrong token.', () async {
  //   var loginName = 'TOMMYSHELBY';
  //
  //   var api = ApiController();
  //   api.provider = ApiMock(
  //       '{"result": "error", "code": "401", "error": "Not Authorized", "auth_state": "AUTH_EXISTING", "auth_dev_comment": "There is already confirmed authorization for this App name, but you haven\'t provided correct token. If you you\'ve lost your auth token, tell user to cancel existing authorization. It might be also caused by using the same App name by the same app on different devices or different apps."}');
  //   expect(() async => await api.login(loginName),
  //       throwsA(predicate((e) => (e is AuthException && e.toString() == 'Je mi líto, ale autorizace se nezdařila. Zkuste si vyresetovat autorizaci v nastavení nyxu.'))));
  // });
}
