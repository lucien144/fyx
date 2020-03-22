import 'package:flutter/cupertino.dart';
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';

class MailboxPage extends StatefulWidget {
  int _refreshData = 0;
  MailboxPage({int refreshData = 0}) : _refreshData = refreshData;

  @override
  _MailboxPageState createState() => _MailboxPageState();
}

class _MailboxPageState extends State<MailboxPage> {
  int _refreshData;

  @override
  void initState() {
    _refreshData = widget._refreshData;
    super.initState();
  }

  refreshData() {
    print('refreshData');
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void didUpdateWidget(MailboxPage oldWidget) {
    if (oldWidget._refreshData != widget._refreshData) {
      this.refreshData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefreshList(
        rebuild: _refreshData,
        isInfinite: true,
        dataProvider: (lastId) async {
          var result = await ApiController().loadMail(lastId: lastId);
          var mails = result.data.map((_mail) {
            var mail = Mail.fromJson(_mail);
            return ContentBoxLayout(
              content: mail.content,
              topLeftWidget: PostAvatar(
                mail.direction == MailDirection.from ? mail.participant : MainRepository().credentials.nickname,
                description: '→ ${mail.direction == MailDirection.to ? mail.participant : MainRepository().credentials.nickname}',
              ),
            );
          }).toList();
          var id = Mail.fromJson(result.data.last).id;
          return DataProviderResult(mails, lastId: id);
        });
  }
}
