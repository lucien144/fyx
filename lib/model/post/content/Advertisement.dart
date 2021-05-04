import 'package:fyx/model/enums/AdEnums.dart';
import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';

import 'Regular.dart';

class ContentAdvertisement extends Content {
  ContentRegular contentRegular;

  int _discussion_id;
  String _full_name;
  List<int> _parent_categories;
  List<String> _photo_ids;
  String _ad_type;
  int _price;
  String _location;
  String _currency;
  String _state;
  String _summary;
  int _refreshed_at;
  int _posts_count;
  List _parameters;

  ContentAdvertisement.fromJson(Map<String, dynamic> json, {bool isCompact}) : super(PostTypeEnum.advertisement, isCompact: isCompact) {
    _discussion_id = json['discussion_id'];
    _full_name = json['full_name'] ?? '';
    _parent_categories = List.castFrom(json['parent_categories'] ?? []);
    _photo_ids = List.castFrom(json['photo_ids'] ?? []);
    _ad_type = json['ad_type'];
    _price = json['price'];
    _location = json['location'] ?? '';
    _currency = json['currency'] ?? '';
    _state = json['state'];
    _summary = json['summary'] ?? '';
    _posts_count = json['posts_count'];
    _parameters = List.castFrom(json['parameters'] ?? []);

    try {
      _refreshed_at = DateTime.parse(json['refreshed_at']).millisecondsSinceEpoch;
    } catch (error) {
      _refreshed_at = 0;
    }
  }

  ContentAdvertisement.fromDiscussionJson(Map<String, dynamic> json, {bool isCompact}):
        this.fromJson(json, isCompact: isCompact);

  factory ContentAdvertisement.fromPostJson(Map<String, dynamic> json, {bool isCompact}) {
    var result = ContentAdvertisement.fromJson(json['content_raw']['data'], isCompact: isCompact);
    result.contentRegular = ContentRegular(json['content']);
    return result;
  }

  List get parameters => _parameters;

  int get postsCount => _posts_count;

  int get refreshedAt => _refreshed_at;

  String get summary => _summary;

  AdStateEnum get state {
    switch (_state) {
      case 'active': return AdStateEnum.active;
      case 'old': return AdStateEnum.old;
      case 'sold': return AdStateEnum.sold;
      default: return AdStateEnum.unknown;
    }
  }

  String get currency => _currency;

  String get location => _location;

  int get price => _price;

  AdTypeEnum get type => _ad_type == 'offer' ? AdTypeEnum.offer : AdTypeEnum.need;

  List<String> get photoIds => _photo_ids;

  List<int> get parentCategories => _parent_categories;

  String get fullName => _full_name;

  int get discussionId => _discussion_id;
}
