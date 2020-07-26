class System {
  int maxFileSize;
  int noticeCount;
  bool premium;
  String systemMessage;
  int unreadPost;
  String unreadPostLastFrom;

  System({this.maxFileSize, this.noticeCount, this.premium, this.systemMessage});

  System.fromJson(Map<String, dynamic> json) {
    maxFileSize = int.parse(json['max_file_size'] ?? '0');
    noticeCount = int.parse(json['notice_count'] ?? '0');
    premium = json['premium'] == '1' ? true : false;
    systemMessage = json['system_message'];
    unreadPost = int.parse(json['unread_post'] ?? '0');
    unreadPostLastFrom = json['unread_post_last_from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max_file_size'] = this.maxFileSize;
    data['notice_count'] = this.noticeCount;
    data['premium'] = this.premium;
    data['system_message'] = this.systemMessage;
    data['unread_post'] = this.unreadPost;
    data['unread_post_last_from'] = this.unreadPostLastFrom;
    return data;
  }
}
