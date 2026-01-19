import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/mail_list_item.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/features/message/domain/message_settings.dart';
import 'package:fyx/features/message/presentation/message_screen.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MailboxTabArguments {
  final int? mailId;

  MailboxTabArguments({this.mailId});
}

class MailboxTab extends StatefulWidget {
  final int refreshTimestamp;

  MailboxTab({this.refreshTimestamp = 0});

  @override
  _MailboxTabState createState() => _MailboxTabState();
}

class _MailboxTabState extends State<MailboxTab> {
  int _refreshData = 0;
  final _newMessage = MessageScreen(key: UniqueKey());

  refreshData() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    AnalyticsProvider().setScreen('Mailbox', 'MailboxTab');
    super.initState();
  }

  @override
  void didUpdateWidget(MailboxTab oldWidget) {
    if (widget.refreshTimestamp > _refreshData) {
      this.refreshData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Reset the language context.
    // TODO: Not ideal. Get rid of the static.
    SyntaxHighlighter.languageContext = '';
    SkinColors colors = Skin.of(context).theme.colors;

    MailboxTabArguments? tabArguments =
        ModalRoute.of(context)?.settings.arguments is MailboxTabArguments ? ModalRoute.of(context)?.settings.arguments as MailboxTabArguments : null;

    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Visibility(
              visible: tabArguments?.mailId != null,
              child: CupertinoNavigationBarBackButton(
                color: colors.primary,
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
            middle: Text(
              'Pošta',
              style: TextStyle(color: colors.text),
            )),
        child: Stack(children: [
          PullToRefreshList(
              rebuild: _refreshData,
              isInfinite: true,
              sliverListBuilder: (List data, {controller}) {
                return ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails', 'blockedUsers']),
                  builder: (BuildContext context, value, Widget? child) {
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
                var result = await ApiController().loadMail(lastId: lastId ?? tabArguments?.mailId);
                var mails = result.mails
                    .map((_mail) => Mail.fromJson(_mail, isCompact: MainRepository().settings.useCompactMode))
                    .where((mail) => !MainRepository().settings.isMailBlocked(mail.id))
                    .where((mail) => !MainRepository().settings.isUserBlocked(mail.participant))
                    .map((mail) {
                  (mail.content as ContentRegular).parseEmailAddresses();
                  (mail.content as ContentRegular).parsePhoneNumbers();
                  return MailListItem(
                    mail,
                    onUpdate: this.refreshData,
                  );
                }).toList();
                var id = result.mails.isEmpty ? lastId : Mail.fromJson(result.mails.last, isCompact: MainRepository().settings.useCompactMode).id;
                return DataProviderResult(mails, lastId: id);
              }),
          Positioned(
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: FloatingActionButton(
                backgroundColor: colors.primary,
                foregroundColor: colors.background,
                child: Icon(Icons.add),
                onPressed: () {
                  final viewModel = getIt<MessageViewModel>();
                  viewModel.initializeFromSettings(MessageSettings(
                      onClose: this.refreshData,
                      hasInputField: true,
                      onSubmit: (String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachments) async {
                        if (inputField == null) {
                          return false;
                        }

                        var response = await ApiController().sendMail(inputField, message, attachments: attachments);
                        return response.isOk;
                      }));

                  showCupertinoModalBottomSheet(
                      context: context,
                      backgroundColor: colors.barBackground,
                      barrierColor: colors.dark.withOpacity(0.5),
                      useRootNavigator: true,
                      builder: (BuildContext context) => _newMessage);
                },
              ),
            ),
          )
        ]),
      );
    });
  }
}
