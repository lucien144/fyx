class DiscussionRights {
  bool _arRead = false;
  bool _arWrite = false;
  bool _arDelete = false;
  bool _arEdit = false;
  bool _arRights = false;
  bool _public = false;

  DiscussionRights({bool arRead = false, bool arWrite = false, bool arDelete = false, bool arEdit = false, bool arRights = false, bool public = false}) {
    this._arRead = arRead;
    this._arWrite = arWrite;
    this._arDelete = arDelete;
    this._arEdit = arEdit;
    this._arRights = arRights;
    this._public = public;
  }

  bool get canRead => _arRead;

  bool get canWrite => _arWrite;

  bool get canDelete => _arDelete;

  bool get canEdit => _arEdit;

  bool get canRights => _arRights;

  bool get ispublic => _public;

  DiscussionRights.fromJson(Map<String, dynamic> json) {
    _arRead = json['ar_read'] ?? false;
    _arWrite = json['ar_write'] ?? false;
    _arDelete = json['ar_delete'] ?? false;
    _arEdit = json['ar_edit'] ?? false;
    _arRights = json['ar_rights'] ?? false;
    _public = json['public'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ar_read'] = this._arRead;
    data['ar_write'] = this._arWrite;
    data['ar_delete'] = this._arDelete;
    data['ar_edit'] = this._arEdit;
    data['ar_rights'] = this._arRights;
    data['public'] = this._public;
    return data;
  }
}
