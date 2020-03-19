import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/BookmarksResponse.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/DiscussionResponse.dart';
import 'package:fyx/model/LoginResponse.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/RatingResponse.dart';
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

      this.logout(removeAuthrorization: false);
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

  Future<BookmarksResponse> loadHistory() async {
    var response = await provider.fetchHistory();
    return BookmarksResponse.fromJson(jsonDecode(response.data));
  }

  Future<BookmarksResponse> loadBookmarks() async {
    var response = await provider.fetchBookmarks();
    return BookmarksResponse.fromJson(jsonDecode(response.data));
  }

  Future<DiscussionResponse> loadDiscussion(int id, {int lastId}) async {
    var response = await provider.fetchDiscussion(id, lastId: lastId);
    return DiscussionResponse.fromJson(jsonDecode(response.data));
  }

  Future<Response> postDiscussionMessage(int id, String message, {Map<String, dynamic> attachment, Post replyPost}) {
    if (replyPost != null) {
      message = '{reply ${replyPost.nick}|${replyPost.id}}: ${message}';
    }
    return provider.postDiscussionMessage(id, message, attachment: attachment);
  }

  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) {
    return provider.setPostReminder(discussionId, postId, setReminder);
  }

  Future<RatingResponse> giveRating(int discussionId, int postId, {bool positive = true, bool confirm = false}) async {
    Response response = await provider.giveRating(discussionId, postId, positive, confirm);
    print(response.data);
    var data = jsonDecode(response.data);
    return RatingResponse(
        isGiven: data['result'] == 'RATING_GIVEN',
        needsConfirmation: data['result'] == 'RATING_NEEDS_CONFIRMATION',
        currentRating: int.parse(data['current_rating']),
        currentRatingStep: int.parse(data['current_rating_step']));
  }

  void logout({bool removeAuthrorization = true}) {
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
    if (removeAuthrorization) {
      provider.logout();
    }
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
