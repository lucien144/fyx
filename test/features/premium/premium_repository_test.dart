import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:fyx/features/premium/data/repositories/premium_repository_impl.dart';

class _FakeLocal implements PremiumLocalDatasource {
  PremiumStatusModel? stored;
  @override
  Future<PremiumStatusModel?> read() async => stored;
  @override
  Future<void> write(PremiumStatusModel model) async => stored = model;
  @override
  Future<void> delete() async => stored = null;
}

class _FakeRemote implements PremiumRemoteDatasource {
  Map<String, dynamic>? row;
  bool throwError = false;
  @override
  Future<Map<String, dynamic>?> fetchSubscriber(String nickname) async {
    if (throwError) throw Exception('supabase down');
    return row;
  }
}

void main() {
  final now = DateTime(2026, 8, 1, 12);
  late _FakeLocal local;
  late _FakeRemote remote;
  late PremiumRepositoryImpl repository;

  setUp(() {
    local = _FakeLocal();
    remote = _FakeRemote();
    repository = PremiumRepositoryImpl(local, remote, clock: () => now);
  });

  test('getCached returns the stored status', () async {
    local.stored = PremiumStatusModel(nickname: 'lucien144', isGod: true, fetchedAt: now);
    final status = await repository.getCached('lucien144');
    expect(status!.isGod, true);
  });

  test('getCached with a different nickname clears the record and returns null', () async {
    local.stored = PremiumStatusModel(nickname: 'someone_else', isGod: true, fetchedAt: now);
    expect(await repository.getCached('lucien144'), isNull);
    expect(local.stored, isNull);
  });

  test('refresh persists and returns the fetched status', () async {
    remote.row = {'nickname': 'lucien144', 'valid_to': '2026-09-01T00:00:00', 'is_god': false};
    final status = await repository.refresh('lucien144');
    expect(status.wasPremiumAtFetch, true);
    expect(local.stored!.validTo, DateTime.parse('2026-09-01T00:00:00'));
    expect(local.stored!.fetchedAt, now);
  });

  test('refresh with no subscriber row persists a negative status', () async {
    remote.row = null;
    final status = await repository.refresh('lucien144');
    expect(status.wasPremiumAtFetch, false);
    expect(local.stored, isNotNull);
  });

  test('refresh failure throws and leaves the cache untouched', () async {
    local.stored = PremiumStatusModel(nickname: 'lucien144', isGod: true, fetchedAt: now);
    remote.throwError = true;
    await expectLater(repository.refresh('lucien144'), throwsException);
    expect(local.stored!.isGod, true);
  });
}
