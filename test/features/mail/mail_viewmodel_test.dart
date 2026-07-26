import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/domain/entities/mail.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mail_viewmodel.dart';

Mail _mail(int id) => MailModel.fromJson({
      'id': id,
      'username': 'user$id',
      'inserted_at': '2015-03-08T22:36:07',
      'incoming': true,
      'unread': true,
      'new': false,
      'content': 'body $id',
    }).toEntity();

/// Repository stub returning queued pages, recording the requested cursors and
/// search terms.
class _StubMailRepository implements MailRepository {
  final List<MailPage> pages;
  final bool throwError;
  final List<int?> requestedCursors = [];
  final List<String?> requestedSearches = [];

  _StubMailRepository(this.pages, {this.throwError = false});

  @override
  Future<MailPage> getMails({int? lastId, String? search, bool isCompact = false}) async {
    requestedCursors.add(lastId);
    requestedSearches.add(search);
    if (throwError) throw Exception('boom');
    return pages.removeAt(0);
  }
}

void main() {
  test('loadInitial fills the state and toggles loading off', () async {
    final repo = _StubMailRepository([
      MailPage(mails: [_mail(1), _mail(2)], lastId: 2),
    ]);
    final vm = MailViewModel(repo);

    final page = await vm.loadInitial();

    expect(page.map((m) => m.id), [1, 2]);
    expect(vm.state.mails.map((m) => m.id), [1, 2]);
    expect(vm.state.lastId, 2);
    expect(vm.state.isLoading, false);
    expect(vm.state.error, isNull);
  });

  test('loadMore appends the next page and paginates from the last id', () async {
    final repo = _StubMailRepository([
      MailPage(mails: [_mail(1), _mail(2)], lastId: 2),
      MailPage(mails: [_mail(3)], lastId: 3),
    ]);
    final vm = MailViewModel(repo);

    await vm.loadInitial();
    await vm.loadMore();

    expect(vm.state.mails.map((m) => m.id), [1, 2, 3]);
    expect(vm.state.lastId, 3);
    expect(repo.requestedCursors, [null, 2]);
  });

  test('setSearchTerm updates state, bumps refresh and is passed to the repository', () async {
    final repo = _StubMailRepository([
      MailPage(mails: [_mail(1)], lastId: 1),
      MailPage(mails: [_mail(1)], lastId: 1),
    ]);
    final vm = MailViewModel(repo);

    vm.setSearchTerm('foo');
    expect(vm.state.searchTerm, 'foo');
    expect(vm.state.refreshTimestamp, greaterThan(0));

    await vm.loadInitial();
    await vm.loadMore();

    expect(repo.requestedSearches, ['foo', 'foo'], reason: 'the stored term is reused across pages');

    vm.setSearchTerm(null);
    expect(vm.state.searchTerm, isNull);
  });

  test('loadInitial replaces the list on refresh', () async {
    final repo = _StubMailRepository([
      MailPage(mails: [_mail(1), _mail(2)], lastId: 2),
      MailPage(mails: [_mail(9)], lastId: 9),
    ]);
    final vm = MailViewModel(repo);

    await vm.loadInitial();
    await vm.loadInitial();

    expect(vm.state.mails.map((m) => m.id), [9]);
    expect(vm.state.lastId, 9);
  });

  test('a failing load records the error and clears loading', () async {
    final vm = MailViewModel(_StubMailRepository([], throwError: true));

    await vm.loadInitial();

    expect(vm.state.error, isNotNull);
    expect(vm.state.isLoading, false);
    expect(vm.state.mails, isEmpty);
  });
}
