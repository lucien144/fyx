import 'package:flutter/foundation.dart';
import 'package:fyx/features/mail/domain/entities/mail.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mail_state.dart';

/// ViewModel driving the mailbox. Holds the whole loaded list plus the search
/// and refresh state in [MailState] so the presentation can watch and render
/// straight from state.
class MailViewModel extends ChangeNotifier {
  final MailRepository _repository;

  MailViewModel(this._repository);

  MailState _state = const MailState();

  MailState get state => _state;

  /// Update the active search term and reload the list from the top.
  void setSearchTerm(String? term) {
    _state = term == null ? _state.copyWith(clearSearchTerm: true) : _state.copyWith(searchTerm: term);
    refresh();
  }

  /// Bump the refresh timestamp so the list reloads from the top.
  void refresh() {
    _state = _state.copyWith(refreshTimestamp: DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  /// Load the first page, replacing any existing mails. [fromId] seeds the
  /// cursor (used for mail deeplinks). Returns the loaded page.
  ///
  /// No listeners are notified before the first `await`: this is invoked from
  /// `PullToRefreshList` during its build, so a synchronous notify would mark a
  /// watching widget dirty mid-build. The completion notify in [_load] runs
  /// after the async gap and is safe.
  Future<List<Mail>> loadInitial({int? fromId, bool isCompact = false}) {
    _state = _state.copyWith(mails: const [], isLoading: true, clearLastId: true, clearError: true);
    return _load(fromId: fromId, isCompact: isCompact, append: false);
  }

  /// Load the next page and append it to the current list.
  Future<List<Mail>> loadMore({bool isCompact = false}) {
    _state = _state.copyWith(isLoading: true, clearError: true);
    return _load(fromId: _state.lastId, isCompact: isCompact, append: true);
  }

  Future<List<Mail>> _load({int? fromId, required bool isCompact, required bool append}) async {
    try {
      final page = await _repository.getMails(lastId: fromId, search: _state.searchTerm, isCompact: isCompact);
      final mails = append ? [..._state.mails, ...page.mails] : page.mails;
      _state = _state.copyWith(
        mails: mails,
        isLoading: false,
        lastId: page.lastId,
        clearLastId: page.lastId == null,
        clearError: true,
      );
      notifyListeners();
      return page.mails;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e);
      notifyListeners();
      return [];
    }
  }

  /// Reset back to the empty state.
  void clear() {
    _state = const MailState();
    notifyListeners();
  }
}
