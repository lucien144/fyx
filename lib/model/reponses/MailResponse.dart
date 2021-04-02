class MailResponse {
  List _mails;

  MailResponse.fromJson(Map<String, dynamic> json) {
    this._mails = json['posts'];
  }

  List get mails => _mails;
}
