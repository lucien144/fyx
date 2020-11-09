import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/MailListItem.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/T.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MailboxPage extends StatefulWidget {
  final int refreshData;

  MailboxPage({this.refreshData});

  @override
  _MailboxPageState createState() => _MailboxPageState();
}

class _MailboxPageState extends State<MailboxPage> {
  int _refreshData;

  @override
  void initState() {
    _refreshData = widget.refreshData;
    AnalyticsProvider().setScreen('Mailbox', 'MailboxPage');
    super.initState();
  }

  refreshData() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void didUpdateWidget(MailboxPage oldWidget) {
    if (oldWidget.refreshData != widget.refreshData) {
      this.refreshData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      PullToRefreshList(
          rebuild: _refreshData,
          isInfinite: true,
          sliverListBuilder: (List data) {
            return ValueListenableBuilder(
              valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails', 'blockedUsers']),
              builder: (BuildContext context, value, Widget child) {
                var filtered = data;
                if (data[0] is MailListItem) {
                  filtered = data
                      .where((item) => !MainRepository().settings.isMailBlocked((item as MailListItem).mail.id))
                      .where((item) => !MainRepository().settings.isUserBlocked((item as MailListItem).mail.participant))
                      .toList();
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => filtered[i],
                    childCount: filtered.length,
                  ),
                );
              },
            );
          },
          dataProvider: (lastId) async {
            var result = await ApiController().loadMail(lastId: lastId);
            var mails = result.data
                .map((_mail) => Mail.fromJson(_mail, isCompact: MainRepository().settings.useCompactMode))
                .where((mail) => !MainRepository().settings.isMailBlocked(mail.id))
                .where((mail) => !MainRepository().settings.isUserBlocked(mail.participant))
                .map((mail) => MailListItem(mail))
                .toList();
            var id = Mail.fromJson(result.data.last, isCompact: MainRepository().settings.useCompactMode).id;
            return DataProviderResult(mails, lastId: id);
          }),
      Positioned(
        right: 20,
        bottom: 20,
        child: SafeArea(
          child: FloatingActionButton(
            backgroundColor: T.COLOR_PRIMARY,
            child: Icon(Icons.add),
            onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed('/new-message',
                arguments: NewMessageSettings(
                    hasInputField: true,
                    onSubmit: (String inputField, String message, Map<String, dynamic> attachment) async {
                      var response = await ApiController().sendMail(inputField, message, attachment: attachment);
                      return response.isOk;
                    })),
          ),
        ),
      )
    ]);
  }
}
