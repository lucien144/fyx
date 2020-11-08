import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/System.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/reponses/BookmarksResponse.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/model/reponses/LoginResponse.dart';
import 'package:fyx/model/reponses/MailResponse.dart';
import 'package:fyx/model/reponses/PostMessageResponse.dart';
import 'package:fyx/model/reponses/RatingResponse.dart';
import 'package:fyx/model/reponses/SendMailResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AUTH_STATES { AUTH_INVALID_USERNAME, AUTH_NEW, AUTH_EXISTING }

class ApiController {
  static ApiController _instance = ApiController._init();
  IApiProvider provider;
  bool isLoggingIn = false;
  BuildContext _context;

  set context(BuildContext value) {
    if (_context == null) {
      _context = value;
    }
  }

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

    provider.onError = (message) {
      if (['access denied'].indexOf(message.toLowerCase()) == -1) {
        PlatformTheme.error(message);
      }
    };

    provider.onSystemData = (data) {
      if (_context == null) {
        return;
      }

      var system = System.fromJson(data);
      Provider.of<NotificationsModel>(_context, listen: false).setNewMails(system.unreadPost);
    };
  }

  Future<LoginResponse> login(String nickname) async {
    isLoggingIn = true;
    Response response = await provider.login(nickname);
    var loginResponse = LoginResponse.fromJson(jsonDecode(response.data));
    if (!loginResponse.isAuthorized) {
      throwAuthException(loginResponse, message: 'Cannot authorize user.');
    }

    await this.setCredentials(Credentials(nickname, loginResponse.authToken));
    isLoggingIn = false;
    return loginResponse;
  }

  Future<Credentials> setCredentials(Credentials credentials) async {
    if (credentials.isValid) {
      var storage = await SharedPreferences.getInstance();
      await storage.setString('identity', jsonEncode(credentials));
      return Future(() => credentials);
    }

    return Future(() => null);
  }

  Future<Credentials> getCredentials() async {
    Credentials creds = provider.getCredentials();

    if (creds is Credentials) {
      return creds;
    }

    var prefs = await SharedPreferences.getInstance();
    String identity = prefs.getString('identity');

    // Breaking change fix -> old identity storage
    if (identity == null) {
      // Load identity from old storage
      creds = Credentials(prefs.getString('nickname'), prefs.getString('token'));
      // Save the identity into the new storage
      this.setCredentials(creds);
      // Remove the old fragments
      prefs.remove('nickname');
      prefs.remove('token');
      // Update the provider's identity
      return this.provider.setCredentials(creds);
    }

    creds = Credentials.fromJson(jsonDecode(identity));
    return this.provider.setCredentials(creds);
  }

  Future<bool> testAuth() async {
    isLoggingIn = true;
    var response = await provider.testAuth();
    var json = jsonDecode(response.data);
    isLoggingIn = false;
    return json['result'] == 'ok';
  }

  void registerFcmToken(String token) {
    this.getCredentials().then((creds) async {
      if (creds == null) {
        return;
      }

      if (creds.fcmToken == null || creds.fcmToken == '') {
        try {
          await provider.registerFcmToken(token);
          print('registerFcmToken');
          this.setCredentials(creds.copyWith(fcmToken: token));
        } catch (error) {
          debugPrint(error);
          MainRepository().sentry.captureException(exception: error);
        }
      }
    });
  }

  void refreshFcmToken(String token) {
    this.getCredentials().then((creds) async {
        try {
          if (creds == null) {
            return;
          }

          print('refreshFcmToken');
          await provider.registerFcmToken(token);
          this.setCredentials(creds.copyWith(fcmToken: token));
        } catch (error) {
          debugPrint(error);
          MainRepository().sentry.captureException(exception: error);
      }
    });
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

  Future<PostMessageResponse> postDiscussionMessage(int id, String message, {Map<String, dynamic> attachment, Post replyPost}) async {
    if (replyPost != null) {
      message = '{reply ${replyPost.nick}|${replyPost.id}}: $message';
    }
    var result = await provider.postDiscussionMessage(id, message, attachment: attachment);
    return PostMessageResponse.fromJson(jsonDecode(result.data));
  }

  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) {
    return provider.setPostReminder(discussionId, postId, setReminder);
  }

  Future<RatingResponse> giveRating(int discussionId, int postId, {bool positive = true, bool confirm = false}) async {
    Response response = await provider.giveRating(discussionId, postId, positive, confirm);
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

  Future<MailResponse> loadMail({int lastId}) async {
    var response = await provider.fetchMail(lastId: lastId);
    return MailResponse.fromJson(jsonDecode(response.data));
  }

  Future<SendMailResponse> sendMail(String recipient, String message, {Map<String, dynamic> attachment}) async {
    var result = await provider.sendMail(recipient, message, attachment: attachment);
    return SendMailResponse.fromJson(jsonDecode(result.data));
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
