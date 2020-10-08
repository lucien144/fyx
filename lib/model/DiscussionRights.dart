class DiscussionRights {
  bool canWrite = true;
  bool canDelete = true;

  DiscussionRights({this.canWrite, this.canDelete});

  DiscussionRights.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    canWrite = int.parse(json['write'] ?? '0') == 1;
    canDelete = int.parse(json['delete'] ?? '0') == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['write'] = this.canWrite;
    data['delete'] = this.canDelete;
    return data;
  }
}
