# Premium Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move premium gating into `lib/features/premium/` with a local cache honoured per ADR 0002 (grace period), a shared `SupabaseService`, and reactive consumers — startup never blocks on Supabase.

**Architecture:** Feature-first Clean Architecture without use-cases (ADR 0001): freezed domain entity with pure freshness logic, SharedPreferences local + Supabase remote datasources behind a repository, `ChangeNotifier` ViewModel with one immutable state watched via `watchIt`. Spec: `docs/superpowers/specs/2026-08-03-premium-feature-design.md`.

**Tech Stack:** Flutter 3.32 / Dart 3, freezed (+ build_runner), get_it + flutter_it (watch_it), shared_preferences, supabase_flutter, flutter_test.

## Global Constraints

- Follow ADR 0001 (dependency direction, no use-case layer, notify-outside-build) and ADR 0002 (TTLs: god 7 days, grace 7 days, negative 24 h).
- Code/comments/docs in English.
- Generated freezed files: run `fvm flutter pub run build_runner build --delete-conflicting-outputs`, commit `*.freezed.dart`. Never hand-write them.
- Tests run with `fvm flutter test <path>`.
- Commits: stage the task's files, then use the `/commit-staged` skill — the repo owner must approve each commit (never commit autonomously). Conventional Commits **with scope**, e.g. `feat(premium): …`.
- Nicknames are compared lowercase everywhere in this feature.

---

### Task 1: Shared SupabaseService

**Files:**
- Create: `lib/shared/services/supabase_service.dart`
- Modify: `lib/shared/services/service_locator.dart`

**Interfaces:**
- Produces: `class SupabaseService { Future<SupabaseClient> get client }` — lazy one-time `Supabase.initialize` from `.env`; a failed init resets so the next access retries. Registered as `registerLazySingleton<SupabaseService>`.

No unit test: the class is a thin memoization wrapper around the static `Supabase.initialize`/`Supabase.instance` singletons, which cannot be faked without an integration harness. Its consumers are tested through fakes of the remote datasource (Task 5).

- [ ] **Step 1: Write the service**

```dart
// lib/shared/services/supabase_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lazily initializes the shared Supabase client on first use.
///
/// Keeping the initialization here (instead of app startup) means the app
/// never pays for — or fails on — Supabase unless a feature actually needs it.
/// A failed initialization is forgotten so the next caller retries.
class SupabaseService {
  Future<SupabaseClient>? _client;

  Future<SupabaseClient> get client async {
    final pending = _client ??= _init();
    try {
      return await pending;
    } catch (_) {
      if (identical(_client, pending)) _client = null;
      rethrow;
    }
  }

  Future<SupabaseClient> _init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    return Supabase.instance.client;
  }
}
```

- [ ] **Step 2: Register in get_it**

In `lib/shared/services/service_locator.dart` add the import and, inside `setupServiceLocator()`:

```dart
// Shared infrastructure
getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
```

- [ ] **Step 3: Verify it compiles**

Run: `fvm flutter analyze lib/shared/services/`
Expected: no new errors.

- [ ] **Step 4: Stage + commit (with owner approval, `/commit-staged`)**

`git add lib/shared/services/supabase_service.dart lib/shared/services/service_locator.dart` → `feat(shared): add lazy SupabaseService`

---

### Task 2: Domain — PremiumFreshness + PremiumStatus with freshness logic

**Files:**
- Create: `lib/features/premium/domain/enums/premium_freshness.dart`
- Create: `lib/features/premium/domain/entities/premium_status.dart` (+ generated `premium_status.freezed.dart`)
- Test: `test/features/premium/premium_status_test.dart`

**Interfaces:**
- Produces:
  - `enum PremiumFreshness { fresh, stale, grace, expired, none }`
  - `PremiumStatus({required String nickname, required bool isGod, DateTime? validTo, required DateTime fetchedAt})` (freezed)
  - `bool get wasPremiumAtFetch` — `isGod || validTo after fetchedAt`
  - `PremiumFreshness freshnessAt(DateTime now)`
  - `bool isPremiumAt(DateTime now)` — `wasPremiumAtFetch && freshnessAt(now) != expired`
  - Constants on `PremiumStatus`: `godTtl` (7 days), `gracePeriod` (7 days), `negativeTtl` (24 h)

Note: the spec lists `isPremium` as a stored field; it is implemented as the derived `wasPremiumAtFetch`/`isPremiumAt` instead so the entity cannot hold contradictory values (spec is touched up in Task 8).

- [ ] **Step 1: Write the enum (trivial, no test)**

```dart
// lib/features/premium/domain/enums/premium_freshness.dart
/// How trustworthy the cached [PremiumStatus] currently is. See ADR 0002.
enum PremiumFreshness {
  /// No refresh needed.
  fresh,

  /// Refresh wanted; the (non-premium) answer keeps applying meanwhile.
  stale,

  /// Expired but still honoured while refreshes keep failing.
  grace,

  /// Grace ran out; premium is off until a refresh succeeds.
  expired,

  /// No usable cache for this user.
  none,
}
```

- [ ] **Step 2: Write the failing freshness-matrix test**

```dart
// test/features/premium/premium_status_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

void main() {
  final fetchedAt = DateTime(2026, 8, 1, 12);

  PremiumStatus subscriber({DateTime? validTo, bool isGod = false}) =>
      PremiumStatus(nickname: 'lucien144', isGod: isGod, validTo: validTo, fetchedAt: fetchedAt);

  group('premium with validTo', () {
    final status = subscriber(validTo: DateTime(2026, 9, 1));

    test('fresh until validTo', () {
      expect(status.freshnessAt(DateTime(2026, 8, 31, 23, 59)), PremiumFreshness.fresh);
      expect(status.isPremiumAt(DateTime(2026, 8, 31, 23, 59)), true);
    });

    test('grace from validTo for 7 days', () {
      expect(status.freshnessAt(DateTime(2026, 9, 1)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 9, 7, 23, 59)), PremiumFreshness.grace);
      expect(status.isPremiumAt(DateTime(2026, 9, 7, 23, 59)), true);
    });

    test('expired after grace; premium off', () {
      expect(status.freshnessAt(DateTime(2026, 9, 8)), PremiumFreshness.expired);
      expect(status.isPremiumAt(DateTime(2026, 9, 8)), false);
    });
  });

  group('god', () {
    final status = subscriber(isGod: true);

    test('fresh for 7 days from fetch', () {
      expect(status.freshnessAt(DateTime(2026, 8, 8, 11, 59)), PremiumFreshness.fresh);
      expect(status.isPremiumAt(DateTime(2026, 8, 8, 11, 59)), true);
    });

    test('grace for another 7 days, then expired', () {
      expect(status.freshnessAt(DateTime(2026, 8, 8, 12)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 8, 15, 11, 59)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 8, 15, 12)), PremiumFreshness.expired);
      expect(status.isPremiumAt(DateTime(2026, 8, 15, 12)), false);
    });

    test('god with a later validTo stays fresh until validTo', () {
      final godWithValidTo = subscriber(isGod: true, validTo: DateTime(2026, 10, 1));
      expect(godWithValidTo.freshnessAt(DateTime(2026, 9, 15)), PremiumFreshness.fresh);
    });
  });

  group('not premium', () {
    final status = subscriber(); // no validTo, not god

    test('fresh for 24 h, then stale; never premium', () {
      expect(status.freshnessAt(DateTime(2026, 8, 2, 11, 59)), PremiumFreshness.fresh);
      expect(status.freshnessAt(DateTime(2026, 8, 2, 12)), PremiumFreshness.stale);
      expect(status.isPremiumAt(DateTime(2026, 8, 1, 13)), false);
      expect(status.isPremiumAt(DateTime(2026, 8, 20)), false);
    });

    test('validTo already past at fetch counts as not premium', () {
      final lapsed = subscriber(validTo: DateTime(2026, 7, 1));
      expect(lapsed.wasPremiumAtFetch, false);
      expect(lapsed.freshnessAt(DateTime(2026, 8, 2)), PremiumFreshness.stale);
      expect(lapsed.isPremiumAt(DateTime(2026, 8, 1, 13)), false);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `fvm flutter test test/features/premium/premium_status_test.dart`
Expected: FAIL (entity does not exist yet).

- [ ] **Step 4: Write the entity**

```dart
// lib/features/premium/domain/entities/premium_status.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

part 'premium_status.freezed.dart';

/// The locally known answer to "does this user have premium?", together with
/// the evidence for it. Freshness/grace semantics are defined in ADR 0002.
@freezed
class PremiumStatus with _$PremiumStatus {
  const PremiumStatus._();

  const factory PremiumStatus({
    /// Whose status this is (lowercase).
    required String nickname,
    required bool isGod,
    DateTime? validTo,
    required DateTime fetchedAt,
  }) = _PremiumStatus;

  static const godTtl = Duration(days: 7);
  static const gracePeriod = Duration(days: 7);
  static const negativeTtl = Duration(hours: 24);

  /// Whether the remote said "premium" at the time of the fetch.
  bool get wasPremiumAtFetch => isGod || (validTo?.isAfter(fetchedAt) ?? false);

  PremiumFreshness freshnessAt(DateTime now) {
    DateTime? freshUntil;
    if (isGod) freshUntil = fetchedAt.add(godTtl);
    if (validTo != null && validTo!.isAfter(fetchedAt)) {
      if (freshUntil == null || validTo!.isAfter(freshUntil)) freshUntil = validTo;
    }
    if (freshUntil == null) {
      // Negative result: no grace, only a retry TTL.
      return now.isBefore(fetchedAt.add(negativeTtl)) ? PremiumFreshness.fresh : PremiumFreshness.stale;
    }
    if (now.isBefore(freshUntil)) return PremiumFreshness.fresh;
    if (now.isBefore(freshUntil.add(gracePeriod))) return PremiumFreshness.grace;
    return PremiumFreshness.expired;
  }

  /// Effective premium: only a successful "not premium" answer or the end of
  /// the grace period turns premium off.
  bool isPremiumAt(DateTime now) => wasPremiumAtFetch && freshnessAt(now) != PremiumFreshness.expired;
}
```

- [ ] **Step 5: Generate freezed code**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `premium_status.freezed.dart` generated.

- [ ] **Step 6: Run test to verify it passes**

Run: `fvm flutter test test/features/premium/premium_status_test.dart`
Expected: PASS.

- [ ] **Step 7: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): add PremiumStatus entity with freshness logic`

---

### Task 3: Domain repository interface + data model

**Files:**
- Create: `lib/features/premium/domain/repositories/premium_repository.dart`
- Create: `lib/features/premium/data/models/premium_status_model.dart` (+ generated `premium_status_model.freezed.dart`)
- Test: `test/features/premium/premium_status_model_test.dart`

**Interfaces:**
- Consumes: `PremiumStatus` (Task 2).
- Produces:
  - `abstract class PremiumRepository { Future<PremiumStatus?> getCached(String nickname); Future<PremiumStatus> refresh(String nickname); }`
  - `PremiumStatusModel({required String nickname, required bool isGod, DateTime? validTo, required DateTime fetchedAt})` with `factory PremiumStatusModel.fromRow(Map<String, dynamic>? row, {required String nickname, required DateTime fetchedAt})`, `factory PremiumStatusModel.fromJson(Map<String, dynamic> json)`, `Map<String, dynamic> toJson()`, `PremiumStatus toEntity()`

- [ ] **Step 1: Write the repository interface**

```dart
// lib/features/premium/domain/repositories/premium_repository.dart
import 'package:fyx/features/premium/domain/entities/premium_status.dart';

abstract class PremiumRepository {
  /// Cached status for [nickname] (lowercase); null when there is no cache or
  /// the cache belongs to a different nickname.
  Future<PremiumStatus?> getCached(String nickname);

  /// Fetches the subscriber from Supabase, persists and returns the new
  /// status. Throws on network/Supabase failure — the caller keeps whatever
  /// it already has.
  Future<PremiumStatus> refresh(String nickname);
}
```

- [ ] **Step 2: Write the failing model test**

```dart
// test/features/premium/premium_status_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';

void main() {
  final fetchedAt = DateTime(2026, 8, 1, 12);

  test('fromRow maps a subscriber row', () {
    final model = PremiumStatusModel.fromRow(
      {'nickname': 'lucien144', 'valid_to': '2026-09-01T00:00:00', 'is_god': false},
      nickname: 'lucien144',
      fetchedAt: fetchedAt,
    );
    expect(model.nickname, 'lucien144');
    expect(model.isGod, false);
    expect(model.validTo, DateTime.parse('2026-09-01T00:00:00'));
    expect(model.toEntity().wasPremiumAtFetch, true);
  });

  test('fromRow maps a missing row to a negative status', () {
    final model = PremiumStatusModel.fromRow(null, nickname: 'lucien144', fetchedAt: fetchedAt);
    expect(model.isGod, false);
    expect(model.validTo, isNull);
    expect(model.toEntity().wasPremiumAtFetch, false);
  });

  test('fromRow tolerates null valid_to and true is_god', () {
    final model = PremiumStatusModel.fromRow(
      {'nickname': 'lucien144', 'valid_to': null, 'is_god': true},
      nickname: 'lucien144',
      fetchedAt: fetchedAt,
    );
    expect(model.isGod, true);
    expect(model.validTo, isNull);
    expect(model.toEntity().wasPremiumAtFetch, true);
  });

  test('toJson/fromJson round-trips', () {
    final model = PremiumStatusModel(
      nickname: 'lucien144',
      isGod: true,
      validTo: DateTime(2026, 9, 1),
      fetchedAt: fetchedAt,
    );
    final restored = PremiumStatusModel.fromJson(model.toJson());
    expect(restored, model);
  });

  test('toEntity carries all fields', () {
    final entity = PremiumStatusModel(
      nickname: 'lucien144',
      isGod: false,
      validTo: DateTime(2026, 9, 1),
      fetchedAt: fetchedAt,
    ).toEntity();
    expect(entity.nickname, 'lucien144');
    expect(entity.validTo, DateTime(2026, 9, 1));
    expect(entity.fetchedAt, fetchedAt);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `fvm flutter test test/features/premium/premium_status_model_test.dart`
Expected: FAIL (model does not exist yet).

- [ ] **Step 4: Write the model**

```dart
// lib/features/premium/data/models/premium_status_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';

part 'premium_status_model.freezed.dart';

/// Data model for [PremiumStatus]: maps the Supabase `subscribers` row and
/// the SharedPreferences cache JSON.
@freezed
class PremiumStatusModel with _$PremiumStatusModel {
  const PremiumStatusModel._();

  const factory PremiumStatusModel({
    required String nickname,
    required bool isGod,
    DateTime? validTo,
    required DateTime fetchedAt,
  }) = _PremiumStatusModel;

  /// Maps a `subscribers` row; a null [row] means the user is not a
  /// subscriber and yields a negative status.
  factory PremiumStatusModel.fromRow(Map<String, dynamic>? row, {required String nickname, required DateTime fetchedAt}) {
    return PremiumStatusModel(
      nickname: nickname,
      isGod: row?['is_god'] == true,
      validTo: row?['valid_to'] != null ? DateTime.tryParse(row!['valid_to'].toString()) : null,
      fetchedAt: fetchedAt,
    );
  }

  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) {
    return PremiumStatusModel(
      nickname: json['nickname'] as String,
      isGod: json['isGod'] == true,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo'] as String) : null,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'isGod': isGod,
        'validTo': validTo?.toIso8601String(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  PremiumStatus toEntity() => PremiumStatus(nickname: nickname, isGod: isGod, validTo: validTo, fetchedAt: fetchedAt);
}
```

- [ ] **Step 5: Generate freezed code**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run test to verify it passes**

Run: `fvm flutter test test/features/premium/premium_status_model_test.dart`
Expected: PASS.

- [ ] **Step 7: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): add repository interface and data model`

---

### Task 4: Local datasource (SharedPreferences)

**Files:**
- Create: `lib/features/premium/data/datasources/premium_local_datasource.dart`
- Test: `test/features/premium/premium_local_datasource_test.dart`

**Interfaces:**
- Consumes: `PremiumStatusModel` (Task 3).
- Produces: `class PremiumLocalDatasource { Future<PremiumStatusModel?> read(); Future<void> write(PremiumStatusModel model); Future<void> delete(); }` under the SharedPreferences key `premium_status`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/premium/premium_local_datasource_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final model = PremiumStatusModel(
    nickname: 'lucien144',
    isGod: false,
    validTo: DateTime(2026, 9, 1),
    fetchedAt: DateTime(2026, 8, 1, 12),
  );

  test('write/read round-trips', () async {
    SharedPreferences.setMockInitialValues({});
    final datasource = PremiumLocalDatasource();
    await datasource.write(model);
    expect(await datasource.read(), model);
  });

  test('read returns null when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PremiumLocalDatasource().read(), isNull);
  });

  test('corrupt JSON reads as null and is removed', () async {
    SharedPreferences.setMockInitialValues({'premium_status': 'not-json{'});
    final datasource = PremiumLocalDatasource();
    expect(await datasource.read(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('premium_status'), isNull);
  });

  test('delete removes the record', () async {
    SharedPreferences.setMockInitialValues({'premium_status': jsonEncode(model.toJson())});
    final datasource = PremiumLocalDatasource();
    await datasource.delete();
    expect(await datasource.read(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/premium/premium_local_datasource_test.dart`
Expected: FAIL (datasource does not exist yet).

- [ ] **Step 3: Write the datasource**

```dart
// lib/features/premium/data/datasources/premium_local_datasource.dart
import 'dart:convert';

import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the single cached [PremiumStatusModel] as JSON in
/// SharedPreferences. Corrupt content reads as "no cache", never a crash.
class PremiumLocalDatasource {
  static const _key = 'premium_status';

  Future<PremiumStatusModel?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return PremiumStatusModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> write(PremiumStatusModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(model.toJson()));
  }

  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/premium/premium_local_datasource_test.dart`
Expected: PASS.

- [ ] **Step 5: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): add SharedPreferences local datasource`

---

### Task 5: Remote datasource + repository implementation

**Files:**
- Create: `lib/features/premium/data/datasources/premium_remote_datasource.dart`
- Create: `lib/features/premium/data/repositories/premium_repository_impl.dart`
- Modify: `lib/shared/services/service_locator.dart`
- Test: `test/features/premium/premium_repository_test.dart`

**Interfaces:**
- Consumes: `SupabaseService` (Task 1), `PremiumStatusModel` (Task 3), `PremiumLocalDatasource` (Task 4), `PremiumRepository` (Task 3).
- Produces:
  - `class PremiumRemoteDatasource { Future<Map<String, dynamic>?> fetchSubscriber(String nickname) }`
  - `class PremiumRepositoryImpl implements PremiumRepository` with constructor `PremiumRepositoryImpl(PremiumLocalDatasource local, PremiumRemoteDatasource remote, {DateTime Function()? clock})`

- [ ] **Step 1: Write the remote datasource (thin, tested via fakes)**

```dart
// lib/features/premium/data/datasources/premium_remote_datasource.dart
import 'package:fyx/shared/services/supabase_service.dart';

/// Fetches the raw subscriber row. No server-side `valid_to`/`is_god` filter:
/// evaluation happens locally so `valid_to` can be cached (ADR 0002).
class PremiumRemoteDatasource {
  final SupabaseService _supabase;

  PremiumRemoteDatasource(this._supabase);

  /// Returns the row for [nickname] (lowercase), or null when not a subscriber.
  Future<Map<String, dynamic>?> fetchSubscriber(String nickname) async {
    final client = await _supabase.client;
    return client.from('subscribers').select('nickname, valid_to, is_god').eq('nickname', nickname).maybeSingle();
  }
}
```

- [ ] **Step 2: Write the failing repository test**

```dart
// test/features/premium/premium_repository_test.dart
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
```

- [ ] **Step 3: Run test to verify it fails**

Run: `fvm flutter test test/features/premium/premium_repository_test.dart`
Expected: FAIL (implementation does not exist yet).

- [ ] **Step 4: Write the repository implementation**

```dart
// lib/features/premium/data/repositories/premium_repository_impl.dart
import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumLocalDatasource _local;
  final PremiumRemoteDatasource _remote;
  final DateTime Function() _clock;

  PremiumRepositoryImpl(this._local, this._remote, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  @override
  Future<PremiumStatus?> getCached(String nickname) async {
    final model = await _local.read();
    if (model == null) return null;
    if (model.nickname != nickname) {
      await _local.delete();
      return null;
    }
    return model.toEntity();
  }

  @override
  Future<PremiumStatus> refresh(String nickname) async {
    final row = await _remote.fetchSubscriber(nickname);
    final model = PremiumStatusModel.fromRow(row, nickname: nickname, fetchedAt: _clock());
    await _local.write(model);
    return model.toEntity();
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `fvm flutter test test/features/premium/premium_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Register in get_it**

In `setupServiceLocator()` (with imports):

```dart
// Premium
getIt.registerLazySingleton<PremiumLocalDatasource>(() => PremiumLocalDatasource());
getIt.registerLazySingleton<PremiumRemoteDatasource>(() => PremiumRemoteDatasource(getIt<SupabaseService>()));
getIt.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(getIt<PremiumLocalDatasource>(), getIt<PremiumRemoteDatasource>()));
```

- [ ] **Step 7: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): add remote datasource and repository implementation`

---

### Task 6: PremiumState + PremiumViewModel

**Files:**
- Create: `lib/features/premium/presentation/viewmodel/premium_state.dart`
- Create: `lib/features/premium/presentation/viewmodel/premium_viewmodel.dart`
- Modify: `lib/shared/services/service_locator.dart`
- Test: `test/features/premium/premium_viewmodel_test.dart`

**Interfaces:**
- Consumes: `PremiumRepository`, `PremiumStatus`, `PremiumFreshness`.
- Produces:
  - `PremiumState({PremiumStatus? status, PremiumFreshness freshness = none, bool isPremium = false, bool isRefreshing = false, bool lastRefreshFailed = false})` (plain `@immutable`, `MailState` style)
  - `PremiumViewModel(PremiumRepository repository, {String? Function()? getNickname, DateTime Function()? clock, void Function(Object error, StackTrace stack)? logError})` with `Future<void> init()`, `Future<void> refreshIfStale()`, `Future<void> refresh()`, `void clear()`, `PremiumState get state`. `logError` defaults to `LogService.captureError`; tests inject a no-op (the default provider throws when uninitialized).
  - Default `getNickname` reads `MainRepository().credentials?.nickname` lowercased; null when logged out.

- [ ] **Step 1: Write the state**

```dart
// lib/features/premium/presentation/viewmodel/premium_state.dart
import 'package:flutter/foundation.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

/// State of the premium gate: the last known status plus the evaluation
/// derived from it ([freshness], [isPremium]) and refresh bookkeeping —
/// everything the future settings section needs to render.
@immutable
class PremiumState {
  final PremiumStatus? status;

  /// Freshness computed at the last evaluation (init/resume/refresh).
  final PremiumFreshness freshness;

  /// Effective premium at the last evaluation (fresh or grace, see ADR 0002).
  final bool isPremium;

  final bool isRefreshing;

  /// The most recent refresh attempt threw. Cleared by a successful refresh.
  final bool lastRefreshFailed;

  const PremiumState({
    this.status,
    this.freshness = PremiumFreshness.none,
    this.isPremium = false,
    this.isRefreshing = false,
    this.lastRefreshFailed = false,
  });

  PremiumState copyWith({
    PremiumStatus? status,
    bool clearStatus = false,
    PremiumFreshness? freshness,
    bool? isPremium,
    bool? isRefreshing,
    bool? lastRefreshFailed,
  }) {
    return PremiumState(
      status: clearStatus ? null : (status ?? this.status),
      freshness: freshness ?? this.freshness,
      isPremium: isPremium ?? this.isPremium,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefreshFailed: lastRefreshFailed ?? this.lastRefreshFailed,
    );
  }
}
```

- [ ] **Step 2: Write the failing ViewModel test**

```dart
// test/features/premium/premium_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_viewmodel.dart';

class _FakeRepository implements PremiumRepository {
  PremiumStatus? cached;
  PremiumStatus? remote;
  bool throwOnRefresh = false;
  int refreshCalls = 0;

  @override
  Future<PremiumStatus?> getCached(String nickname) async => cached;

  @override
  Future<PremiumStatus> refresh(String nickname) async {
    refreshCalls++;
    if (throwOnRefresh) throw Exception('supabase down');
    return remote!;
  }
}

void main() {
  final now = DateTime(2026, 8, 10, 12);
  late _FakeRepository repo;

  PremiumViewModel vm({String? nickname = 'lucien144'}) =>
      PremiumViewModel(repo, getNickname: () => nickname, clock: () => now, logError: (_, __) {});

  PremiumStatus status({DateTime? validTo, bool isGod = false, DateTime? fetchedAt}) =>
      PremiumStatus(nickname: 'lucien144', isGod: isGod, validTo: validTo, fetchedAt: fetchedAt ?? now);

  setUp(() => repo = _FakeRepository());

  test('init with a fresh cache does not refresh', () async {
    repo.cached = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    expect(viewModel.state.isPremium, true);
    expect(viewModel.state.freshness, PremiumFreshness.fresh);
    expect(repo.refreshCalls, 0);
  });

  test('init with a stale cache triggers a background refresh', () async {
    repo.cached = status(fetchedAt: now.subtract(const Duration(days: 2))); // negative, past 24h TTL
    repo.remote = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(repo.refreshCalls, 1);
    expect(viewModel.state.isPremium, true);
  });

  test('failed refresh keeps premium on during grace', () async {
    repo.cached = status(validTo: DateTime(2026, 8, 5)); // validTo passed 5 days ago -> grace
    repo.throwOnRefresh = true;
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, true);
    expect(viewModel.state.freshness, PremiumFreshness.grace);
    expect(viewModel.state.lastRefreshFailed, true);
    expect(viewModel.state.isRefreshing, false);
  });

  test('successful "not premium" answer turns premium off', () async {
    repo.cached = status(validTo: DateTime(2026, 8, 5));
    repo.remote = status(); // negative
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, false);
    expect(viewModel.state.lastRefreshFailed, false);
  });

  test('expired grace turns premium off even without a successful refresh', () async {
    repo.cached = status(validTo: DateTime(2026, 7, 1), fetchedAt: DateTime(2026, 6, 1)); // grace long over
    repo.throwOnRefresh = true;
    final viewModel = vm();
    await viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.isPremium, false);
    expect(viewModel.state.freshness, PremiumFreshness.expired);
  });

  test('refreshIfStale does nothing when fresh', () async {
    repo.cached = status(validTo: DateTime(2026, 9, 1));
    final viewModel = vm();
    await viewModel.init();
    await viewModel.refreshIfStale();
    expect(repo.refreshCalls, 0);
  });

  test('init without a nickname yields the empty state', () async {
    final viewModel = vm(nickname: null);
    await viewModel.init();
    expect(viewModel.state.freshness, PremiumFreshness.none);
    expect(viewModel.state.isPremium, false);
    expect(repo.refreshCalls, 0);
  });

  test('clear resets the state', () async {
    repo.cached = status(isGod: true);
    final viewModel = vm();
    await viewModel.init();
    viewModel.clear();
    expect(viewModel.state.status, isNull);
    expect(viewModel.state.isPremium, false);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `fvm flutter test test/features/premium/premium_viewmodel_test.dart`
Expected: FAIL (ViewModel does not exist yet).

- [ ] **Step 4: Write the ViewModel**

```dart
// lib/features/premium/presentation/viewmodel/premium_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_state.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/model/MainRepository.dart';

/// Owns the premium gate. Loads the cached status on [init], refreshes in the
/// background when the cache is not fresh, and re-evaluates freshness on
/// every entry point. Only a successful "not premium" refresh or the end of
/// the grace period turns premium off (ADR 0002).
class PremiumViewModel extends ChangeNotifier {
  final PremiumRepository _repository;
  final String? Function() _getNickname;
  final DateTime Function() _clock;
  final void Function(Object error, StackTrace stack) _logError;

  PremiumViewModel(
    this._repository, {
    String? Function()? getNickname,
    DateTime Function()? clock,
    void Function(Object error, StackTrace stack)? logError,
  })  : _getNickname = getNickname ?? _credentialsNickname,
        _clock = clock ?? DateTime.now,
        _logError = logError ?? _captureError;

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  static String? _credentialsNickname() => MainRepository().credentials?.nickname.toLowerCase();

  PremiumState _state = const PremiumState();

  PremiumState get state => _state;

  /// Loads the cache and kicks off a background refresh when it is not
  /// fresh. Never blocks on the network — callers must not await the refresh.
  Future<void> init() async {
    final nickname = _getNickname();
    if (nickname == null) {
      clear();
      return;
    }
    _apply(await _repository.getCached(nickname));
    if (_state.freshness != PremiumFreshness.fresh) {
      refresh(); // deliberately not awaited
    }
  }

  /// Re-evaluates freshness against the current clock and refreshes unless
  /// the cache is still fresh. Called on app resume.
  Future<void> refreshIfStale() async {
    if (_state.status != null) _apply(_state.status);
    if (_state.freshness == PremiumFreshness.fresh || _state.isRefreshing) return;
    await refresh();
  }

  /// Fetches from Supabase. On failure the previous status stays in effect
  /// and [PremiumState.lastRefreshFailed] is set.
  Future<void> refresh() async {
    final nickname = _getNickname();
    if (nickname == null || _state.isRefreshing) return;
    _state = _state.copyWith(isRefreshing: true);
    notifyListeners();
    try {
      _apply(await _repository.refresh(nickname), refreshFailed: false);
    } catch (e, stack) {
      _logError(e, stack);
      _apply(_state.status, refreshFailed: true);
    }
  }

  /// Resets to the empty state (logout).
  void clear() {
    _state = const PremiumState();
    notifyListeners();
  }

  void _apply(PremiumStatus? status, {bool? refreshFailed}) {
    final now = _clock();
    _state = PremiumState(
      status: status,
      freshness: status?.freshnessAt(now) ?? PremiumFreshness.none,
      isPremium: status?.isPremiumAt(now) ?? false,
      isRefreshing: false,
      lastRefreshFailed: refreshFailed ?? _state.lastRefreshFailed,
    );
    notifyListeners();
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `fvm flutter test test/features/premium/premium_viewmodel_test.dart`
Expected: PASS.

- [ ] **Step 6: Register in get_it**

In `setupServiceLocator()`:

```dart
getIt.registerSingleton<PremiumViewModel>(PremiumViewModel(getIt<PremiumRepository>()));
```

- [ ] **Step 7: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): add PremiumViewModel with immutable state`

---

### Task 7: App integration (FyxApp, LoginPage, logout)

**Files:**
- Modify: `lib/FyxApp.dart:160-179` (remove the Supabase block), `lib/FyxApp.dart:312-317` (resume hook)
- Modify: `lib/pages/LoginPage.dart:199` (refresh after login)
- Modify: `lib/controllers/ApiController.dart:336-341` (clear on logout)

**Interfaces:**
- Consumes: `PremiumViewModel` via `DI.getIt<PremiumViewModel>()` (FyxApp imports `service_locator.dart as DI`; LoginPage/ApiController import `getIt` directly).

- [ ] **Step 1: Replace the Supabase block in `FyxApp.init()`**

Delete lines 160–179 (the `try { … Supabase.initialize … } catch …` block) and the now-unused `supabase_flutter` import. In its place (before the `AnalyticsProvider.provider = analytics;` line):

```dart
DI.getIt<PremiumViewModel>().init(); // loads cache; refreshes in background when stale
```

Not awaited — startup must not wait for SharedPreferences+network. Add the import `package:fyx/features/premium/presentation/viewmodel/premium_viewmodel.dart`.

- [ ] **Step 2: Resume hook**

In `_FyxAppState.didChangeAppLifecycleState`, inside the `resumed` branch (next to the userstats tracking):

```dart
DI.getIt<PremiumViewModel>().refreshIfStale();
```

- [ ] **Step 3: Refresh after login**

In `lib/pages/LoginPage.dart:199`, inside the `.then((LoginResponse response) { … })` success handler (after credentials are set), add:

```dart
DI.getIt<PremiumViewModel>().refresh();
```

(using whatever import alias LoginPage has for `service_locator.dart`; add `import 'package:fyx/shared/services/service_locator.dart';` and call `getIt<PremiumViewModel>().refresh();` if none).

- [ ] **Step 4: Clear on logout**

In `ApiController.logout` (line 336) add, alongside the prefs clear (`prefs.clear()` already wipes the cached record):

```dart
getIt<PremiumViewModel>().clear();
```

Guard for tests where the locator may be empty:

```dart
if (getIt.isRegistered<PremiumViewModel>()) {
  getIt<PremiumViewModel>().clear();
}
```

- [ ] **Step 5: Verify**

Run: `fvm flutter analyze lib/FyxApp.dart lib/pages/LoginPage.dart lib/controllers/ApiController.dart`
Expected: no new errors.
Run: `fvm flutter test`
Expected: full suite PASS.

- [ ] **Step 6: Stage + commit (with owner approval, `/commit-staged`)**

`feat(premium): wire PremiumViewModel into app lifecycle`

---

### Task 8: Call-site migration + delete Credentials.isPremiumUser

**Files:**
- Modify: `lib/FyxApp.dart:286`, `lib/components/premium_feature.dart:25`, `lib/components/bottom_tab_bar.dart:63`, `lib/components/pull_to_refresh_list.dart:262`, `lib/components/post/post_list_item.dart:126`, `lib/pages/DiscussionPage.dart:362`, `lib/pages/DiscussionPage.dart:573`
- Modify: `lib/model/Credentials.dart:6` (delete the field)
- Modify: `docs/superpowers/specs/2026-08-03-premium-feature-design.md` (note `isPremium` is derived, not stored)
- Modify: `CLAUDE.md` (premium feature note in Architecture/Gotchas)

**Interfaces:**
- Consumes: `PremiumViewModel.state.isPremium` — reactive via `watchIt<PremiumViewModel>()` (flutter_it) or `ListenableBuilder`; plain `getIt<PremiumViewModel>()` reads in callbacks.

Reactive vs plain read per site: skin gating and the premium-lock widgets must repaint when a background refresh flips premium; reads inside tap callbacks or data-load paths always evaluate at call time and need no listener. `PostListItem`/`DiscussionPage` are Riverpod `ConsumerStatefulWidget`s — do NOT mix `WatchItStatefulWidgetMixin` into them (both override `createElement`); they get plain reads, which is acceptable because both rebuild frequently on data changes.

- [ ] **Step 1: FyxApp skin gating (reactive)**

At `lib/FyxApp.dart:279-293`, wrap the existing `Skin(...)` widget in a `ListenableBuilder` and swap the condition:

```dart
child: ListenableBuilder(
  listenable: DI.getIt<PremiumViewModel>(),
  builder: (context, _) => Skin(
    skins: [
      FyxSkin.create(fontSize: ctx.watch<ThemeModel>().fontSize),
      ForestSkin.create(fontSize: ctx.watch<ThemeModel>().fontSize),
      GreyMatterSkin.create(fontSize: ctx.watch<ThemeModel>().fontSize),
      DarkSkin.create(fontSize: ctx.watch<ThemeModel>().fontSize),
    ],
    skin: DI.getIt<PremiumViewModel>().state.isPremium ? ctx.watch<ThemeModel>().skin : SkinEnum.fyx,
    brightness: /* unchanged */,
    child: SkinnedApp(),
  ),
),
```

- [ ] **Step 2: PremiumFeature widget (reactive)**

`../../../lib/features/premium/presentation/widgets/premium_feature.dart` — make it watching:

```dart
class PremiumFeature extends StatelessWidget with WatchItMixin {
```

and replace line 25:

```dart
if (watchIt<PremiumViewModel>().state.isPremium) {
```

Imports: `package:flutter_it/flutter_it.dart`, the ViewModel; drop the now-unused `MainRepository` import.

- [ ] **Step 3: BottomTabBar star icon (reactive)**

`lib/components/bottom_tab_bar.dart` — `class BottomTabBar extends StatefulWidget with WatchItStatefulWidgetMixin`, and at line 63 (inside the state's build):

```dart
if (watchIt<PremiumViewModel>().state.isPremium)
```

Note: `watchIt` inside a `State` whose widget mixes in `WatchItStatefulWidgetMixin` is the flutter_it-supported pattern.

- [ ] **Step 4: Plain reads (callbacks / riverpod widgets)**

Replace `MainRepository().credentials!.isPremiumUser` with `getIt<PremiumViewModel>().state.isPremium` (import `service_locator.dart` + the ViewModel; keep any existing import alias):

- `lib/components/pull_to_refresh_list.dart:262` (tap callback)
- `lib/components/post/post_list_item.dart:126` (riverpod build — plain read by design, see above)
- `lib/pages/DiscussionPage.dart:362` (callback)
- `lib/pages/DiscussionPage.dart:573` (data-load render path)

- [ ] **Step 5: Delete the flag**

Remove `bool isPremiumUser = false;` from `lib/model/Credentials.dart:6`.

Run: `grep -rn "isPremiumUser" lib/`
Expected: no matches.

- [ ] **Step 6: Docs touch-up**

- Spec: in the `PremiumStatus` table replace the `isPremium` row with a note that premium-ness is derived (`wasPremiumAtFetch` / `isPremiumAt(now)`), not stored.
- `CLAUDE.md`: under Common Gotchas replace the "Premium Features: Checked via Supabase" line with a pointer to `lib/features/premium/` + ADR 0002, and mention `SupabaseService` in the DI section.

- [ ] **Step 7: Verify everything**

Run: `fvm flutter analyze`
Expected: no new issues vs. baseline.
Run: `fvm flutter test`
Expected: full suite PASS.

- [ ] **Step 8: Stage + commit (with owner approval, `/commit-staged`)**

`refactor(premium): migrate consumers to PremiumViewModel and drop Credentials.isPremiumUser`
