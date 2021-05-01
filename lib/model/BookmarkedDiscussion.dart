// ignore_for_file: non_constant_identifier_names

class BookmarkedDiscussion {
  int _id_klub;
  int _unread;
  int _replies;
  int _images;
  int _links;
  String _name;
  int _last_visit;

  BookmarkedDiscussion.fromJson(Map<String, dynamic> json) {
    this._id_klub = json['discussion_id'];
    this._unread = json['new_posts_count'] ?? 0;
    this._replies = json['new_replies_count'] ?? 0; // Premium
    this._images = json['new_images_count'] ?? 0; // Premium
    this._links = json['new_links_count'] ?? 0; // Premium
    this._name = json['full_name'] ?? (json['full_name'] ?? '');
    try {
      this._last_visit = DateTime.parse(json['last_visited_at']).millisecondsSinceEpoch;
    } catch (error) {
      this._last_visit = 0;
    }
  }

  int get links => _links;

  int get images => _images;

  int get replies => _replies;

  int get unread => _unread;

  String get jmeno => _name;

  String get name => _name;

  int get idKlub => _id_klub;

  int get lastVisit => _last_visit;
}
