class System {
  int maxFileSize;
  int noticeCount;
  bool premium;

  System({this.maxFileSize, this.noticeCount, this.premium});

  System.fromJson(Map<String, dynamic> json) {
    maxFileSize = int.parse(json['max_file_size']);
    noticeCount = int.parse(json['notice_count']);
    premium = json['premium'] == '1' ? true : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max_file_size'] = this.maxFileSize;
    data['notice_count'] = this.noticeCount;
    data['premium'] = this.premium;
    return data;
  }
}
