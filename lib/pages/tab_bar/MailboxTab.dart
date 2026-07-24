import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/components/mail_list_item.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mailbox_viewmodel.dart';
import 'package:fyx/features/message/domain/entities/attachment.dart';
import 'package:fyx/features/message/domain/message_settings.dart';
import 'package:fyx/features/message/presentation/message_screen.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MailboxTabArguments {
  final int? mailId;

  MailboxTabArguments({this.mailId});
}

class MailboxTab extends WatchingStatefulWidget {
  const MailboxTab({super.key, this.refreshTimestamp = 0});

  final int refreshTimestamp;

  @override
  State<MailboxTab> createState() => _MailboxTabState();
}

class _MailboxTabState extends State<MailboxTab> {
  final _newMessage = MessageScreen(key: UniqueKey());

  @override
  void initState() {
    AnalyticsProvider().setScreen('Mailbox', 'MailboxTab');
    super.initState();
  }

  @override
  void didUpdateWidget(MailboxTab oldWidget) {
    if (widget.refreshTimestamp > oldWidget.refreshTimestamp) {
      getIt<MailboxViewModel>().refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Reset the language context.
    // TODO: Not ideal. Get rid of the static.
    SyntaxHighlighter.languageContext = '';
    final colors = Skin.of(context).theme.colors;

    final tabArguments = ModalRoute.of(context)?.settings.arguments is MailboxTabArguments
        ? ModalRoute.of(context)?.settings.arguments as MailboxTabArguments
        : null;

    final mailboxViewModel = watchIt<MailboxViewModel>();

    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            automaticBackgroundVisibility: false,
            backgroundColor: colors.barBackground,
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
              rebuild: mailboxViewModel.state.refreshTimestamp,
              isInfinite: true,
              searchEnabled: mailboxViewModel.state.searchTerm != null,
              searchLabel: 'Hledej @nick a nebo text...',
              searchTerm: mailboxViewModel.state.searchTerm,
              onSearch: (term) => mailboxViewModel.setSearchTerm(term),
              onSearchClear: () => mailboxViewModel.setSearchTerm(null),
              onPullDown: (scrollInfo) {
                if (scrollInfo.metrics.pixels > 80 && mailboxViewModel.state.searchTerm != null) {
                  if (mailboxViewModel.state.searchTerm == '') {
                    mailboxViewModel.setSearchTerm(null);
                  }
                } else if (scrollInfo.metrics.pixels < -60 && mailboxViewModel.state.searchTerm == null) {
                  mailboxViewModel.setSearchTerm('');
                }
              },
              sliverListBuilder: (List data, {controller}) {
                return ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails', 'blockedUsers']),
                  builder: (BuildContext context, value, Widget? child) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => data[i],
                        childCount: data.length,
                      ),
                    );
                  },
                );
              },
              dataProvider: (lastId) async {
                final page = await mailboxViewModel.loadMails(lastId: lastId ?? tabArguments?.mailId);
                final items = page.mails
                    .map(
                      (mail) => MailListItem(
                        mail,
                        onUpdate: mailboxViewModel.refresh,
                      ),
                    )
                    .toList(growable: false);

                return DataProviderResult(items, lastId: page.nextLastId);
              }),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: colors.primary,
              foregroundColor: colors.background,
              child: Icon(Icons.add),
              onPressed: () {
                final viewModel = getIt<MessageViewModel>();
                viewModel.initializeFromSettings(MessageSettings(
                    onClose: getIt<MailboxViewModel>().refresh,
                    hasInputField: true,
                    onSubmit: (String? inputField, String message, List<Attachment> attachments) async {
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
          )
        ]),
      );
    });
  }
}
