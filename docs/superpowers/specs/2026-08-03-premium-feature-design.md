# Premium feature — design

- **Date:** 2026-08-03
- **Related:** [ADR 0001](../../adr/0001-feature-architecture.md) (feature
  architecture), [ADR 0002](../../adr/0002-premium-status-caching.md) (caching
  policy), `CONTEXT.md` (Premium terms)

## Problem

Premium gating queries Supabase on every cold start, awaited inside
`FyxApp.init()`. A Supabase/network outage turns premium features off until the
next successful start, and the query delays startup. The premium flag is a
mutable bool on `Credentials` (`isPremiumUser`) written from `FyxApp` — no
caching, no reactivity, no single owner.

## Goals

1. Premium survives Supabase outages: cache locally, honour the cached status
   per the freshness policy in ADR 0002.
2. Move the logic into `lib/features/premium/` following ADR 0001.
3. Extract a shared Supabase service so future features can reuse the client.
4. Never block startup on the network.
5. Expose enough state for a future settings section (built separately):
   status details, freshness, refresh-in-progress, refresh failure, and a
   manual `refresh()`.

## Non-goals

- The settings UI itself (the owner builds it later on top of `PremiumState`).
- Any change to the Supabase schema or to premium purchase flows.
- Migrating other Supabase usages (there are none today besides premium).

## Structure

```
lib/features/premium/
  domain/
    entities/premium_status.dart          # freezed: nickname, isPremium, isGod, validTo?, fetchedAt
    enums/premium_freshness.dart          # fresh | stale | grace | expired | none
    repositories/premium_repository.dart  # abstract interface
  data/
    models/premium_status_model.dart      # fromMap (Supabase row), fromJson/toJson (cache), toEntity()
    datasources/premium_local_datasource.dart   # SharedPreferences, single JSON key
    datasources/premium_remote_datasource.dart  # `subscribers` query via SupabaseService
    repositories/premium_repository_impl.dart
  presentation/
    viewmodel/premium_viewmodel.dart      # PremiumViewModel + immutable PremiumState

lib/shared/services/supabase_service.dart # lazy Supabase.initialize from .env
```

All new classes are registered in `lib/shared/services/service_locator.dart`
(repository and `SupabaseService` as `registerLazySingleton`,
`PremiumViewModel` as `registerSingleton`, constructor injection throughout).

## Domain

### `PremiumStatus` (freezed entity)

| Field | Type | Meaning |
|---|---|---|
| `nickname` | `String` | Whose status this is (lowercase). |
| `isGod` | `bool` | `is_god` flag from the subscriber row. |
| `validTo` | `DateTime?` | `valid_to` from the row; null when absent. |
| `fetchedAt` | `DateTime` | When the row was fetched. |

Premium-ness is derived, not stored, so the entity cannot hold contradictory
values: `wasPremiumAtFetch` (`isGod || validTo > fetchedAt`) and
`isPremiumAt(now)` (the effective-premium rule below).

### Freshness (pure function over `PremiumStatus` + clock)

Implemented as an extension/method taking `DateTime now` so it is testable
with a fake clock. Constants: god TTL 7 days, grace period 7 days, negative
TTL 24 hours.

| Cached state | fresh | then | then |
|---|---|---|---|
| premium with `validTo` | until `validTo` | **grace** for 7 days | **expired** |
| god | 7 days from `fetchedAt` | **grace** for 7 days | **expired** |
| not premium | 24 h from `fetchedAt` | **stale** (indefinitely) | — |
| no cache / nickname mismatch | **none** | — | — |

Effective premium = `isPremium && freshness ∈ {fresh, grace}`. See ADR 0002
for the rationale (grace period over fail-open/fail-closed).

### `PremiumRepository` (interface)

```dart
abstract class PremiumRepository {
  /// Cached status for [nickname]; null when none/mismatched.
  Future<PremiumStatus?> getCached(String nickname);

  /// Fetches from Supabase, persists and returns the new status.
  /// Throws on network/Supabase failure (caller keeps the cached value).
  Future<PremiumStatus> refresh(String nickname);
}
```

## Data

- **Local datasource:** one SharedPreferences key (e.g. `premium_status`)
  holding the model as JSON. A nickname mismatch on read deletes the record.
- **Remote datasource:** `from('subscribers').select('nickname, valid_to,
  is_god').eq('nickname', nickname).maybeSingle()` — no server-side
  `valid_to`/`is_god` filter; evaluation happens locally so `valid_to` can be
  cached. A missing row maps to a non-premium `PremiumStatus`.
- **`SupabaseService`:** owns lazy `Supabase.initialize` using
  `SUPABASE_URL`/`SUPABASE_ANON_KEY` from `.env` (first use only, guarded
  against double init) and exposes the client. `FyxApp.init()` no longer
  initializes Supabase. Future features build their own datasources on top of
  this service.

## Presentation

### `PremiumState` (immutable, freezed)

| Field | Meaning |
|---|---|
| `status` | `PremiumStatus?` — last known status (cache or fresh fetch). |
| `freshness` | `PremiumFreshness` — computed at last evaluation. |
| `isRefreshing` | A refresh is in flight. |
| `lastRefreshFailed` | The most recent refresh attempt threw. |

Convenience getter `isPremium` implements the effective-premium rule above.

### `PremiumViewModel` (ChangeNotifier, get_it singleton)

- `init()` — loads the cache for the current nickname, computes freshness,
  then fires `refreshIfStale()` without awaiting it.
- `refreshIfStale()` — re-computes freshness; when not `fresh`, runs
  `refresh()`.
- `refresh()` — sets `isRefreshing`, calls the repository; on success replaces
  `status`, on failure keeps the cached status and sets `lastRefreshFailed`.
  Notifies only outside build (ADR 0001 rule 6).
- `clear()` — drops state on logout.

### Triggers

- `FyxApp.init()` → `init()` (replaces the current awaited Supabase block;
  non-blocking).
- `didChangeAppLifecycleState(resumed)` → `refreshIfStale()`.
- Successful login → `refresh()`.
- Settings (future) → `refresh()` + renders `status`/`freshness`/
  `isRefreshing`/`lastRefreshFailed`.

## Call-site migration

`Credentials.isPremiumUser` is deleted. Consumers move to
`watchIt<PremiumViewModel>()` in widgets, `getIt<PremiumViewModel>()`
elsewhere:

| Site | Note |
|---|---|
| `FyxApp.dart:286` (skin gating) | must rebuild when premium flips on after a background refresh |
| `components/bottom_tab_bar.dart:63` | widget |
| `components/premium_feature.dart:25` | widget |
| `components/pull_to_refresh_list.dart:262` | widget |
| `components/post/post_list_item.dart:126` | widget |
| `pages/DiscussionPage.dart:362` | widget |
| `pages/DiscussionPage.dart:573` | non-build call path |

## Error handling

- Remote failures are caught in the ViewModel (`lastRefreshFailed`), logged via
  the existing log service/Crashlytics, and never surface as user-facing errors
  outside the future settings screen.
- Corrupt cache JSON reads as "no cache" (freshness `none`), not a crash.

## Testing

Unit tests following `test/features/mail/` conventions:

- **Freshness matrix** — every row of the table above with a fake clock,
  including boundary instants (exactly `validTo`, exactly end of grace).
- **Repository** — fake local + remote datasources: refresh success persists;
  refresh failure throws and leaves the cache untouched; nickname mismatch
  yields null and clears the record; missing subscriber row persists a
  negative status.
- **ViewModel** — fake repository: init loads cache and triggers background
  refresh only when stale; failed refresh keeps premium on during grace;
  successful "not premium" answer turns it off; logout clears state.
