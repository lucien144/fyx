import 'package:fyx/model/System.dart';

class SendMailResponse {
  String result;
  String senderMsgId;
  String recieverMsgNick;
  String senderMsgText;
  System system;

  SendMailResponse({this.result, this.senderMsgId, this.recieverMsgNick, this.senderMsgText, this.system});

  bool get isOk => result == 'ok' ? true : false;

  SendMailResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    senderMsgId = json['sender_msg_id'];
    recieverMsgNick = json['reciever_msg_nick'];
    senderMsgText = json['sender_msg_text'];
    system = json['system'] != null ? System.fromJson(json['system']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['sender_msg_id'] = this.senderMsgId;
    data['reciever_msg_nick'] = this.recieverMsgNick;
    data['sender_msg_text'] = this.senderMsgText;
    if (this.system != null) {
      data['system'] = this.system.toJson();
    }
    return data;
  }
}
