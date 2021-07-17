import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

typedef ErrorCallback = Function(dynamic error);
typedef TokenCallback = Function(String token);
typedef DiscussionCallback = Function({int? discussionId, int? postId});

class NotificationService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late StreamSubscription<String> _tokenStream;
  Function? onNewMail;
  DiscussionCallback? onNewPost;
  ErrorCallback? onError;

  late TokenCallback _onToken;
  late TokenCallback _onTokenRefresh;

  NotificationService({required TokenCallback onToken, required TokenCallback onTokenRefresh})
      : this._onToken = onToken,
        this._onTokenRefresh = onTokenRefresh {

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

  configure() async {
    RemoteMessage? message = await _firebaseMessaging.getInitialMessage();

    // Get any messages which caused the application to open from
    // a terminated state.
    if (message != null) {
      _handleNotifications(message);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotifications(message);
    });
  }

  request() {
    return _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void _handleNotifications(RemoteMessage message) {
    try {
      if (message.data['type'] == 'new_mail') {
        if (onNewMail != null) {
          onNewMail!();
          return;
        }
      }
      if (message.data['type'] == 'reply') {
        if (onNewPost != null) {
          onNewPost!(discussionId: int.parse(message.data['discussion_id'] ?? '0'), postId: int.parse(message.data['post_id'] ?? '0'));
          return;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError!(e);
      }
    }
  }

  dispose() {
    _tokenStream.cancel();
  }
}
