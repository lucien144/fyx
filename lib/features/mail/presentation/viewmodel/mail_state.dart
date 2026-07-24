import 'package:flutter/foundation.dart';
import 'package:fyx/features/mail/domain/entities/mail.dart';

/// State for the mailbox: the accumulated list of mails plus loading,
/// pagination, search and refresh bookkeeping.
@immutable
class MailState {
  /// All mails loaded so far (across pages). Source of truth for the list.
  final List<Mail> mails;

  final bool isLoading;

  /// Cursor for the next page. Null before the first load.
  final int? lastId;

  /// Active search term, if any.
  final String? searchTerm;

  /// Bumped to trigger a reload of the list from the top.
  final int refreshTimestamp;

  /// Set when the last load failed. Transient — cleared on the next load.
  final Object? error;

  const MailState({
    this.mails = const [],
    this.isLoading = false,
    this.lastId,
    this.searchTerm,
    this.refreshTimestamp = 0,
    this.error,
  });

  MailState copyWith({
    List<Mail>? mails,
    bool? isLoading,
    int? lastId,
    bool clearLastId = false,
    String? searchTerm,
    bool clearSearchTerm = false,
    int? refreshTimestamp,
    Object? error,
    bool clearError = false,
  }) {
    return MailState(
      mails: mails ?? this.mails,
      isLoading: isLoading ?? this.isLoading,
      lastId: clearLastId ? null : (lastId ?? this.lastId),
      searchTerm: clearSearchTerm ? null : (searchTerm ?? this.searchTerm),
      refreshTimestamp: refreshTimestamp ?? this.refreshTimestamp,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
