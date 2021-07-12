class DiscussionRights {
  bool _arRead;
  bool _arWrite;
  bool _arDelete;
  bool _arEdit;
  bool _arRights;
  bool _public;

  DiscussionRights({bool arRead, bool arWrite, bool arDelete, bool arEdit, bool arRights, bool public}) {
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
