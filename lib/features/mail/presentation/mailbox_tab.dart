import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/features/mail/presentation/widgets/mail_list_item.dart';
import 'package:fyx/components/post/syntax_highlighter.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mail_viewmodel.dart';
import 'package:fyx/features/message/domain/entities/attachment.dart';
import 'package:fyx/features/message/domain/message_settings.dart';
import 'package:fyx/features/message/presentation/message_screen.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MailboxTabArguments {
  final int? mailId;

  MailboxTabArguments({this.mailId});
}

class MailboxTab extends WatchingStatefulWidget {
  final int refreshTimestamp;

  MailboxTab({super.key, this.refreshTimestamp = 0});

  @override
  _MailboxTabState createState() => _MailboxTabState();
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
      // Defer to after this frame: didUpdateWidget runs during the parent build,
      // so notifying a watching widget synchronously would mark it dirty mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) => getIt<MailViewModel>().refresh());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Reset the language context.
    // TODO: Not ideal. Get rid of the static.
    SyntaxHighlighter.languageContext = '';
    SkinColors colors = Skin.of(context).theme.colors;

    final viewModel = watchIt<MailViewModel>();

    MailboxTabArguments? tabArguments =
        ModalRoute.of(context)?.settings.arguments is MailboxTabArguments ? ModalRoute.of(context)?.settings.arguments as MailboxTabArguments : null;

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
              rebuild: viewModel.state.refreshTimestamp,
              isInfinite: true,
              searchEnabled: viewModel.state.searchTerm != null,
              searchLabel: 'Hledej @nick a nebo text...',
              searchTerm: viewModel.state.searchTerm,
              onSearch: (term) => viewModel.setSearchTerm(term),
              onSearchClear: () => viewModel.setSearchTerm(null),
              onPullDown: (scrollInfo) {
                if (scrollInfo.metrics.pixels > 80 && viewModel.state.searchTerm != null) {
                  if (viewModel.state.searchTerm == '') viewModel.setSearchTerm(null);
                } else if (scrollInfo.metrics.pixels < -60 && viewModel.state.searchTerm == null) {
                  viewModel.setSearchTerm('');
                }
              },
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
                var isCompact = MainRepository().settings.useCompactMode;
                // A null cursor means an initial load or a pull-to-refresh -> reset the
                // list; otherwise continue paginating. State lives in the ViewModel so the
                // list can be rendered from it once PullToRefreshList is refactored away.
                var mails = lastId == null
                    ? await viewModel.loadInitial(fromId: tabArguments?.mailId, isCompact: isCompact)
                    : await viewModel.loadMore(isCompact: isCompact);
                var items = mails
                    .where((mail) => !MainRepository().settings.isMailBlocked(mail.id))
                    .where((mail) => !MainRepository().settings.isUserBlocked(mail.participant))
                    .map((mail) => MailListItem(mail, onUpdate: viewModel.refresh))
                    .toList();
                return DataProviderResult(items, lastId: viewModel.state.lastId);
              }),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: colors.primary,
              foregroundColor: colors.background,
              child: Icon(Icons.add),
              onPressed: () {
                final messageViewModel = getIt<MessageViewModel>();
                messageViewModel.initializeFromSettings(MessageSettings(
                    onClose: viewModel.refresh,
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
