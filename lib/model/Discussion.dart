// ignore_for_file: non_constant_identifier_names

import 'package:fyx/model/enums/DiscussionTypeEnum.dart';
import 'package:fyx/model/post/content/Advertisement.dart';

class Discussion {
  int _id_klub;

  String _name;
  String _name_main;
  String _name_sub;
  String _discussion_type;
  int _last_visit;
  bool _has_home;
  bool _has_header;
  int _id_domain;

  bool _canWrite = true;
  bool _canDelete = false;
  bool _canEdit = false;
  bool _canEditRights = false;
  bool _accessDenied = false;

  ContentAdvertisement _advertisement;

  Discussion.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      this._accessDenied = true;
      return;
    } else {
      bool canRead = json['discussion']['ar_read'] ?? true;
      this._accessDenied = !canRead;
    }

    this._id_klub = json['discussion']['id'];
    this._name_main = json['discussion']['name_static'] ?? '';
    this._name_sub = json['discussion']['name_dynamic'] ?? '';
    this._name = '${this._name_main} ${this._name_sub}';
    this._has_home = json['discussion']['has_home'];
    this._has_header = json['discussion']['has_header'];
    this._id_domain = json['domain_id'] ?? 0;
    this._discussion_type = json['discussion']['discussion_type'] ?? 'discussion';
    this._canWrite = json['discussion']['ar_write'] ?? true;
    this._canDelete = json['discussion']['ar_delete'] ?? false;
    this._canEdit = json['discussion']['ar_edit'] ?? false;
    this._canEditRights = json['discussion']['ar_rights'] ?? false;

    try {
      this._last_visit = DateTime.parse(json['bookmark']['last_visited_at']).millisecondsSinceEpoch;
    } catch (error) {
      this._last_visit = 0;
    }

    print(json['discussion_type']);
    if (type == DiscussionTypeEnum.advertisement && json['advertisement_specific_data'] != null && json['advertisement_specific_data']['advertisement'] != null) {
      _advertisement = ContentAdvertisement.fromDiscussionJson(json['advertisement_specific_data']['advertisement']);
    }
  }

  String get jmeno => _name;

  String get name => _name;

  String get nameMain => _name_main;

  String get nameSubtitle => _name_sub;

  int get idKlub => _id_klub;

  int get lastVisit => _last_visit;

  bool get hasHome => _has_home;

  bool get hasHeader => _has_header;

  int get domainId => _id_domain;

  bool get canEditRights => _canEditRights;

  bool get canEdit => _canEdit;

  bool get canDelete => _canDelete;

  bool get canWrite => _canWrite;

  bool get accessDenied => _accessDenied;

  ContentAdvertisement get advertisement => _advertisement;

  DiscussionTypeEnum get type {
    switch (_discussion_type) {
      case 'discussion': return DiscussionTypeEnum.discussion;
      case 'advertisement': return DiscussionTypeEnum.advertisement;
      case 'event': return DiscussionTypeEnum.event;
      default:
        throw Exception('Unknown discussion type: "$_discussion_type"');
    }
  }
}
