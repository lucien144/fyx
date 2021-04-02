class ResponseContext {
  User _user;
  List<ActiveFriends> _activeFriends;

  ResponseContext({User user, List<ActiveFriends> activeFriends}) {
    this._user = user;
    this._activeFriends = activeFriends;
  }

  User get user => _user;

  List<ActiveFriends> get activeFriends => _activeFriends;

  ResponseContext.fromJson(Map<String, dynamic> json) {
    _user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['active_friends'] != null) {
      _activeFriends = new List<ActiveFriends>();
      json['active_friends'].forEach((v) {
        _activeFriends.add(new ActiveFriends.fromJson(v));
      });
    }
  }
}

class User {
  String _username;
  int _mailUnread;
  String _mailLastFrom;
  int _notificationsUnread;
  String _notificationsLastVisit;

  User({String username, int mailUnread, String mailLastFrom, int notificationsUnread, String notificationsLastVisit}) {
    this._username = username;
    this._mailUnread = mailUnread;
    this._mailLastFrom = mailLastFrom;
    this._notificationsUnread = notificationsUnread;
    this._notificationsLastVisit = notificationsLastVisit;
  }

  String get username => _username;

  int get mailUnread => _mailUnread;

  String get mailLastFrom => _mailLastFrom;

  int get notificationsUnread => _notificationsUnread;

  String get notificationsLastVisit => _notificationsLastVisit;

  User.fromJson(Map<String, dynamic> json) {
    _username = json['username'];
    _mailUnread = json['mail_unread'];
    _mailLastFrom = json['mail_last_from'];
    _notificationsUnread = json['notifications_unread'];
    _notificationsLastVisit = json['notifications_last_visit'];
  }
}

class ActiveFriends {
  String _username;
  String _lastActivity;
  String _lastAccessMethod;
  String _statusDetails;
  String _location;
  String _locationUrl;

  ActiveFriends({String username, String lastActivity, String lastAccessMethod, String statusDetails, String location, String locationUrl}) {
    this._username = username;
    this._lastActivity = lastActivity;
    this._lastAccessMethod = lastAccessMethod;
    this._statusDetails = statusDetails;
    this._location = location;
    this._locationUrl = locationUrl;
  }

  String get username => _username;

  String get lastActivity => _lastActivity;

  String get lastAccessMethod => _lastAccessMethod;

  String get statusDetails => _statusDetails;

  String get location => _location;

  String get locationUrl => _locationUrl;

  ActiveFriends.fromJson(Map<String, dynamic> json) {
    _username = json['username'];
    _lastActivity = json['last_activity'];
    _lastAccessMethod = json['last_access_method'];
    _statusDetails = json['status_details'];
    _location = json['location'];
    _locationUrl = json['location_url'];
  }
}
