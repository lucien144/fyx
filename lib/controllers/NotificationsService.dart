import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';

typedef ErrorCallback = Function(dynamic error);
typedef TokenCallback = Function(String token);
typedef DiscussionCallback = Function({int? discussionId, int? postId});

class NotificationService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription<String> _tokenStream;
  Function onNewMail;
  DiscussionCallback onNewPost;
  ErrorCallback onError;

  TokenCallback _onToken;
  TokenCallback _onTokenRefresh;

  NotificationService({@required TokenCallback onToken, @required TokenCallback onTokenRefresh})
      : this._onToken = onToken,
        this._onTokenRefresh = onTokenRefresh {
    _firebaseMessaging.configure(
      // This is triggered when the app is in foreground (active)
      // onMessage: (Map<String, dynamic> message) async {
      //   _handleNotifications(message);
      // },
      onLaunch: (Map<String, dynamic> message) async {
        _handleNotifications(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _handleNotifications(message);
      },
    );

    _tokenStream = _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      if (fcmToken is String && this._onTokenRefresh is TokenCallback) {
        this._onTokenRefresh(fcmToken);
      }
    });
    _firebaseMessaging.getToken().then((fcmToken) {
      if (fcmToken is String && this._onToken is TokenCallback) {
        this._onToken(fcmToken);
      }
    });
  }

  request() {
    return _firebaseMessaging.requestNotificationPermissions();
  }

  void _handleNotifications(Map<String, dynamic> message) {
    try {
      if (message['type'] == 'new_mail') {
        if (onNewMail is Function) {
          onNewMail();
          return;
        }
      }
      if (message['type'] == 'reply') {
        if (onNewPost is DiscussionCallback) {
          onNewPost(discussionId: int.parse(message['discussion_id'] ?? '0'), postId: int.parse(message['post_id'] ?? '0'));
          return;
        }
      }
    } catch (e) {
      if (onError is ErrorCallback) {
        onError(e);
      }
    }
  }

  dispose() {
    _tokenStream.cancel();
  }
}
