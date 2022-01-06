import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/controllers/ApiProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/exceptions/AuthException.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/ResponseContext.dart';
import 'package:fyx/model/post/content/Poll.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/reponses/BookmarksAllResponse.dart';
import 'package:fyx/model/reponses/BookmarksHistoryResponse.dart';
import 'package:fyx/model/reponses/DiscussionHomeResponse.dart';
import 'package:fyx/model/reponses/DiscussionResponse.dart';
import 'package:fyx/model/reponses/FeedNoticesResponse.dart';
import 'package:fyx/model/reponses/FileUploadResponse.dart';
import 'package:fyx/model/reponses/LoginResponse.dart';
import 'package:fyx/model/reponses/MailResponse.dart';
import 'package:fyx/model/reponses/OkResponse.dart';
import 'package:fyx/model/reponses/RatingResponse.dart';
import 'package:fyx/model/reponses/WaitingFilesResponse.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AUTH_STATES { AUTH_INVALID_USERNAME, AUTH_NEW, AUTH_EXISTING }

class ApiController {
  static ApiController _instance = ApiController._init();
  IApiProvider provider = ApiProvider();
  bool isLoggingIn = false;
  BuildContext? buildContext;

  factory ApiController() {
    return _instance;
  }

  ApiController._init() {
    provider.onAuthError = (String message) {
      // API returns the same error on authorization as well as on normal data request. Therefore this "workaround".
      if (isLoggingIn) {
        return;
      }

      this.logout(removeAuthrorization: false);
      T.error(message == '' ? L.AUTH_ERROR : message);
      if (FyxApp.navigatorKey.currentState != null) {
        FyxApp.navigatorKey.currentState!.pushNamed('/login');
      }
    };

    provider.onError = (message) {
      T.error(message);
    };

    provider.onContextData = (data) {
      if (buildContext == null) {
        return;
      }

      ResponseContext responseContext = ResponseContext.fromJson(data);
      Provider.of<NotificationsModel>(buildContext!, listen: false).setNewMails(responseContext.user.mailUnread);
      Provider.of<NotificationsModel>(buildContext!, listen: false).setNewNotices(responseContext.user.notificationsUnread);
    };
  }

  Future<LoginResponse> login(String nickname) async {
    isLoggingIn = true;
    Response response = await provider.login(nickname);
    var loginResponse = LoginResponse.fromJson(response.data);
    if (!loginResponse.isAuthorized) {
      throwAuthException(loginResponse, message: 'Cannot authorize user.');
    }

    await this.setCredentials(Credentials(nickname, loginResponse.authToken));
    isLoggingIn = false;
    return loginResponse;
  }

  Future<Credentials?> setCredentials(Credentials credentials) async {
    if (credentials.isValid) {
      provider.setCredentials(credentials);
      var storage = await SharedPreferences.getInstance();
      await storage.setString('identity', jsonEncode(credentials));
      return Future(() => credentials);
    }

    return Future(() => null);
  }

  Future<Credentials?> getCredentials() async {
    Credentials? creds = provider.getCredentials();

    if (creds != null) {
      return creds;
    }

    var prefs = await SharedPreferences.getInstance();
    String? identity = prefs.getString('identity');

    // Breaking change fix -> old identity storage
    // TODO: Delete in 3/2021 ?
    if (identity == null) {
      // Load identity from old storage
      creds = Credentials(prefs.getString('nickname') ?? '', prefs.getString('token') ?? '');
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
          debugPrint(error.toString());
          Sentry.captureException(error);
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
        debugPrint(error.toString());
        Sentry.captureException(error);
      }
    });
  }

  Future<BookmarksHistoryResponse> loadHistory() async {
    var response = await provider.fetchHistory();
    return BookmarksHistoryResponse.fromJson(response.data);
  }

  Future<BookmarksAllResponse> loadBookmarks() async {
    var response = await provider.fetchBookmarks();
    return BookmarksAllResponse.fromJson(response.data);
  }

  Future<DiscussionResponse> loadDiscussion(int id, {int? lastId, String? user, String? search}) async {
    try {
      var response = await provider.fetchDiscussion(id, lastId: lastId, user: user, search: search);
      if (response.statusCode == 400) {
        return DiscussionResponse.accessDenied();
      }
      return DiscussionResponse.fromJson(response.data);
    } catch (error) {
      if (error is DioError) {
        if (error.response?.statusCode == 400) {
          return DiscussionResponse.accessDenied();
        }
      }
    }
    return DiscussionResponse.error();
  }

  Future<DiscussionHomeResponse> getDiscussionHome(int id) async {
    var response = await provider.fetchDiscussionHome(id);
    return DiscussionHomeResponse.fromJson(response.data);
  }

  Future<FeedNoticesResponse> loadFeedNotices() async {
    var response = await provider.fetchNotices();
    return FeedNoticesResponse.fromJson(response.data);
  }

  Future<OkResponse> postDiscussionMessage(int id, String message, {List<Map<ATTACHMENT, dynamic>>? attachments, Post? replyPost}) async {
    if (attachments != null) {
      try {
        WaitingFilesResponse waitingFilesResponse = await this.fetchDiscussionWaitingFiles(id);
        await this.deleteAllWaitingFiles(waitingFilesResponse.files);
      } catch (error) {
        debugPrint(error.toString());
        Sentry.captureException(error);
        // TODO: Notify user?
      }

      try {
        await provider.uploadFile(attachments, id: id);
      } catch (error) {
        if (provider.onError != null) {
          provider.onError!('👎 Nějakteré z obrázků se nepodařilo nahrát.');
        }
      }
    }

    if (replyPost != null) {
      message = '{reply ${replyPost.nick}|${replyPost.id}}: $message';
    }

    var result = await provider.postDiscussionMessage(id, message);
    return OkResponse.fromJson(result.data);
  }

  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) {
    return provider.setPostReminder(discussionId, postId, setReminder);
  }

  Future<RatingResponse> giveRating(int discussionId, int postId, {bool positive = true, bool confirm = false, bool remove = false}) async {
    Response response = await provider.giveRating(discussionId, postId, positive, confirm, remove);
    var data = response.data;
    return RatingResponse(
        isGiven: data['error'] ?? true,
        needsConfirmation: data['code'] == 'NeedsConfirmation',
        currentRating: data['rating'],
        myRating: data['my_rating'] ?? 'none');
  }

  void logout({bool removeAuthrorization = true}) {
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
    if (removeAuthrorization) {
      provider.logout();
    }
  }

  Future<MailResponse> loadMail({int? lastId}) async {
    var response = await provider.fetchMail(lastId: lastId);
    return MailResponse.fromJson(response.data);
  }

  Future<List> deleteAllWaitingFiles(List<FileUploadResponse> files) async {
    List<Future> deletes = [];
    for (FileUploadResponse file in files) {
      deletes.add(provider.deleteFile(file.id));
    }
    return await Future.wait(deletes);
  }

  Future<OkResponse> sendMail(String recipient, String message, {List<Map<ATTACHMENT, dynamic>>? attachments}) async {
    // Upload image
    if (attachments != null) {
      try {
        WaitingFilesResponse waitingFilesResponse = await this.fetchMailWaitingFiles();
        await this.deleteAllWaitingFiles(waitingFilesResponse.files);
      } catch (error) {
        debugPrint(error.toString());
        Sentry.captureException(error);
        // TODO: Notify user?
      }
      try {
        await provider.uploadFile(attachments);
      } catch (error) {
        if (provider.onError != null) {
          provider.onError!('👎 Nějakteré z obrázků se nepodařilo nahrát.');
        }
      }
    }

    var result = await provider.sendMail(recipient, message);
    return OkResponse.fromJson(result.data);
  }

  Future<WaitingFilesResponse> fetchDiscussionWaitingFiles(int id) async {
    Response response = await provider.fetchDiscussionWaitingFiles(id);
    return WaitingFilesResponse.fromJson(response.data);
  }

  Future<WaitingFilesResponse> fetchMailWaitingFiles() async {
    Response response = await provider.fetchMailWaitingFiles();
    return WaitingFilesResponse.fromJson(response.data);
  }

  Future<ContentPoll> votePoll(discussionId, postId, votes) async {
    Response response = await provider.votePoll(discussionId, postId, votes);
    Map<String, dynamic> json = response.data;
    return ContentPoll.fromJson(json['content_raw']['data'], discussionId: json['discussion_id'] ?? 0, postId: json['post_id'] ?? 0);
  }

  throwAuthException(LoginResponse loginResponse, {String message: ''}) {
    if (loginResponse.error) {
      throw AuthException(loginResponse.message);
    }

    throw AuthException(message);
  }
}
