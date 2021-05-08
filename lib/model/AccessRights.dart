class AccessRights {
  int _discussionId;
  bool _arRead;
  bool _arWrite;
  bool _arDelete;
  bool _arEdit;
  bool _arRights;
  int _daysLeft;

  AccessRights({int discussionId, bool arRead, bool arWrite, bool arDelete, bool arEdit, bool arRights, int daysLeft}) {
    this._discussionId = discussionId;
    this._arRead = arRead;
    this._arWrite = arWrite;
    this._arDelete = arDelete;
    this._arEdit = arEdit;
    this._arRights = arRights;
    this._daysLeft = daysLeft;
  }

  int get discussionId => _discussionId;

  bool get canRead => _arRead;

  bool get canWrite => _arWrite;

  bool get canDelete => _arDelete;

  bool get canEdit => _arEdit;

  bool get canRights => _arRights;

  int get daysLeft => _daysLeft;

  AccessRights.fromJson(Map<String, dynamic> json) {
    _discussionId = json['discussion_id'];
    _arRead = json['ar_read'] ?? true;
    _arWrite = json['ar_write'] ?? true;
    _arDelete = json['ar_delete'] ?? true;
    _arEdit = json['ar_edit'] ?? true;
    _arRights = json['ar_rights'] ?? true;
    _daysLeft = json['days_left'] ?? -1;
  }

  AccessRights.fullAccess() {
    _arRead = true;
    _arWrite = true;
    _arDelete = true;
    _arEdit = true;
    _arRights = true;
    _daysLeft = -1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['discussion_id'] = this._discussionId;
    data['ar_read'] = this._arRead;
    data['ar_write'] = this._arWrite;
    data['ar_delete'] = this._arDelete;
    data['ar_edit'] = this._arEdit;
    data['ar_rights'] = this._arRights;
    data['days_left'] = this._daysLeft;
    return data;
  }
}
