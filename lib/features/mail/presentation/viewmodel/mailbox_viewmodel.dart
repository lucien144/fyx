import 'package:flutter/foundation.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mailbox_state.dart';
import 'package:fyx/model/Mail.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/post/content/Regular.dart';

class MailboxViewModel extends ChangeNotifier {
  MailboxViewModel(this._mailRepository);

  final MailRepository _mailRepository;

  MailboxState _state = const MailboxState();

  MailboxState get state => _state;

  void setSearchTerm(String? value) {
    _state = value == null
        ? _state.copyWith(clearSearchTerm: true)
        : _state.copyWith(searchTerm: value);
    refresh();
  }

  void refresh() {
    _state = _state.copyWith(refreshTimestamp: DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<({List<Mail> mails, int? nextLastId})> loadMails({int? lastId}) async {
    final page = await _mailRepository.loadMailPage(lastId: lastId, searchTerm: _state.searchTerm);

    final mails = page.mails
        .map(
          (entity) => MailModel(
            id: entity.id,
            participant: entity.participant,
            insertedAt: entity.insertedAt,
            isIncoming: entity.isIncoming,
            isUnread: entity.isUnread,
            isNew: entity.isNew,
            content: entity.content,
            activity: entity.activity,
          ).toLegacyMail(isCompact: MainRepository().settings.useCompactMode),
        )
        .where((mail) => !MainRepository().settings.isMailBlocked(mail.id))
        .where((mail) => !MainRepository().settings.isUserBlocked(mail.participant))
        .map((mail) {
          (mail.content as ContentRegular).parseEmailAddresses();
          (mail.content as ContentRegular).parsePhoneNumbers();
          return mail;
        })
        .toList(growable: false);

    return (mails: mails, nextLastId: page.nextLastId);
  }
}
