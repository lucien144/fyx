class DiscussionOwner {
  late String _username;

  DiscussionOwner({String username = ''}) {
    this._username = username;
  }

  String get username => _username;

  DiscussionOwner.fromJson(Map<String, dynamic> json) {
    _username = json['user']['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this._username;
    return data;
  }
}
