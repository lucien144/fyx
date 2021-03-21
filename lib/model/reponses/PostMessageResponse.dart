import 'package:fyx/model/System.dart';

class PostMessageResponse {
  bool _isOk;

  PostMessageResponse();

  PostMessageResponse.fromJson(Map<String, dynamic> json) {
    _isOk = json.isEmpty;
  }

  bool get isOk => _isOk;
}
