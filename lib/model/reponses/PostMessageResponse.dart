import 'package:fyx/model/System.dart';

class PostMessageResponse {
  String result;
  System system;

  PostMessageResponse({this.result, this.system});

  bool get isOk => result == 'ok' ? true : false;

  PostMessageResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    system = json['system'] != null ? System.fromJson(json['system']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    if (this.system != null) {
      data['system'] = this.system.toJson();
    }
    return data;
  }
}
