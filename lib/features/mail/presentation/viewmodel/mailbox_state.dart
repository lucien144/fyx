class MailboxState {
  const MailboxState({
    this.searchTerm,
    this.refreshTimestamp = 0,
  });

  final String? searchTerm;
  final int refreshTimestamp;

  MailboxState copyWith({
    String? searchTerm,
    bool clearSearchTerm = false,
    int? refreshTimestamp,
  }) {
    return MailboxState(
      searchTerm: clearSearchTerm ? null : (searchTerm ?? this.searchTerm),
      refreshTimestamp: refreshTimestamp ?? this.refreshTimestamp,
    );
  }
}
