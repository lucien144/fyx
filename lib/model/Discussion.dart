// ignore_for_file: non_constant_identifier_names

import 'package:fyx/model/AccessRights.dart';
import 'package:fyx/model/DiscussionCommonBookmark.dart';
import 'package:fyx/model/DiscussionOwner.dart';
import 'package:fyx/model/DiscussionRights.dart';
import 'package:fyx/model/enums/DiscussionTypeEnum.dart';
import 'package:fyx/model/post/content/Advertisement.dart';

class Discussion {
  late int _id_klub;

  String _name = '';
  String _name_main = '';
  String _name_sub = '';
  String _discussion_type = '';
  int _last_visit = 0;
  bool _has_home = false;
  bool _has_header = false;
  int _id_domain = 0;

  bool _accessDenied = false;

  late DiscussionRights _discussion_rights;
  late AccessRights _access_rights;
  DiscussionOwner? _owner;
  ContentAdvertisement? _advertisement;
  DiscussionCommonBookmark? _bookmark;

  Discussion.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      this._accessDenied = true;
      return;
    }

    // Personal rights
    if (json['access_right'] is Map) {
      this._access_rights = AccessRights.fromJson(json['access_right']);
    } else {
      // If no access rights returned, we expect full access.
      this._access_rights = AccessRights.fullAccess();
    }
    if (!this._access_rights.canRead) {
      this._accessDenied = true;
      return;
    }

    // Global rights
    this._discussion_rights = DiscussionRights.fromJson(json['discussion']);
    if (this._access_rights.canRead != true && !this._discussion_rights.canRead) {
      this._accessDenied = true;
      return;
    }

    this._id_klub = json['discussion']['id'];
    this._name_main = json['discussion']['name_static'] ?? '';
    this._name_sub = json['discussion']['name_dynamic'] ?? '';
    this._name = '${this._name_main} ${this._name_sub}';
    this._has_home = json['discussion']['has_home'];
    this._has_header = json['discussion']['has_header'];
    this._id_domain = json['domain_id'] ?? 0;
    this._discussion_type = json['discussion']['discussion_type'] ?? 'discussion';

    if (json['owner'] is Map) {
      this._owner = DiscussionOwner.fromJson(json['owner']);
    }

    if (json['bookmark'] is Map) {
      this._bookmark = DiscussionCommonBookmark.fromJson(json['bookmark']);
    }

    try {
      this._last_visit = DateTime.parse(json['bookmark']['last_visited_at']).millisecondsSinceEpoch;
    } catch (error) {
      this._last_visit = 0;
    }

    if (type == DiscussionTypeEnum.advertisement &&
        json['advertisement_specific_data'] != null &&
        json['advertisement_specific_data']['advertisement'] != null) {
      _advertisement = ContentAdvertisement.fromDiscussionJson(json['advertisement_specific_data']);
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

  bool get accessDenied => _accessDenied;

  ContentAdvertisement? get advertisement => _advertisement;

  DiscussionCommonBookmark? get bookmark => _bookmark;

  DiscussionOwner? get owner => _owner;

  AccessRights get accessRights => _access_rights;

  DiscussionRights get rights => _discussion_rights;

  DiscussionTypeEnum get type {
    switch (_discussion_type) {
      case 'discussion':
        return DiscussionTypeEnum.discussion;
      case 'advertisement':
        return DiscussionTypeEnum.advertisement;
      case 'event':
        return DiscussionTypeEnum.event;
      default:
        throw Exception('Unknown discussion type: "$_discussion_type"');
    }
  }
}
