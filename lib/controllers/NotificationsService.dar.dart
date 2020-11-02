import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:meta/meta.dart';

typedef ErrorCallback = Function(dynamic error);
typedef TokenCallback = Function(String token);

class NotificationService {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription<String> _tokenStream;
  Function onNewMail;
  Function onNewPost;
  ErrorCallback onError;

  TokenCallback _onToken;
  TokenCallback _onTokenRefresh;

  NotificationService({@required TokenCallback onToken, @required TokenCallback onTokenRefresh}): this._onToken = onToken, this._onTokenRefresh = onTokenRefresh {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _handleNotifications(message);
      },
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
      PlatformTheme.success(message.toString());
      String type = message['type'] ?? null;
      if (type == 'new_mail') {
        if (onNewMail is Function) {
          onNewMail();
          return;
        }
      }
      if (onNewPost is Function) {
        onNewPost();
        return;
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