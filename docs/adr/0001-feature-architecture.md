# ADR 0001 — Feature architecture: MVVM over a use-case-less Clean Architecture

- **Status:** Accepted
- **Date:** 2026-07-24
- **Supersedes:** the legacy Riverpod + `lib/model/` approach for new code (see Consequences)

## Context

The app historically kept domain models in `lib/model/` and reactive state in
Riverpod providers under `lib/state/`. New work is moving to self-contained
feature modules under `lib/features/`. We need one documented pattern so every
new feature looks the same and the boundaries are predictable.

We deliberately want a **minimal** Clean Architecture: the layering benefits
(testable domain, swappable data sources, UI that depends only on abstractions)
without the ceremony of a use-case/interactor layer that, at this app's size,
only forwards calls.

## Decision

New features are **feature-first** modules with a **use-case-less Clean
Architecture** core and an **MVVM presentation layer driven by immutable
state**.

### How we name it

> Feature-based Clean Architecture (no use-case layer) with an MVVM presentation
> layer built on immutable state + `watch_it`.

"State-driven" is fine as an informal adjective for the presentation layer, but
it is not the name of the whole architecture.

### Layout

```
lib/features/<feature>/
  domain/
    entities/        freezed entities (pure data; may implement a shared
                     interface such as IPost)
    enums/           feature enums
    repositories/    abstract repository interfaces
  data/
    models/          freezed data models: fromJson/fromMap + toEntity()
    datasources/     optional; wraps ApiController / a database
    repositories/    repository implementations
  presentation/
    viewmodel/       ChangeNotifier ViewModel + immutable State
    <feature>_screen.dart / widgets/
```

### Rules

1. **Dependency direction.** `domain` imports nothing from `data` or
   `presentation`. `presentation` depends only on `domain` (never on a `data`
   model). `data` depends on `domain`.
2. **No use-case layer.** ViewModels (or callers) talk to repository interfaces
   directly. `userstats` is the repository-only reference; `gallery`, `message`
   and `mail` add a ViewModel.
3. **Models with freezed.** Entities and data models use `@freezed`. Generate
   with the real `build_runner` (`fvm flutter pub run build_runner build
   --delete-conflicting-outputs`) and commit the generated `*.freezed.dart` —
   never hand-write "manual stub" `.freezed.dart` files.
4. **Mapping lives in data.** Data models own `fromJson`/`fromMap` and
   `toEntity()`. Repositories return domain entities (or a small domain page
   object), not raw JSON or data models.
5. **Presentation = MVVM with one immutable State.** A `ChangeNotifier`
   ViewModel holds a single immutable `State` value and mutates it via
   `copyWith`. Use explicit `clear*` flags in `copyWith` for nullable fields
   that must be reset. Widgets read it reactively with `watchIt<VM>()` from
   `watch_it` (the `flutter_it` package) and use `WatchingStatefulWidget` /
   `WatchingWidget`.
6. **Never notify during build.** A ViewModel method invoked synchronously from
   a widget's build (e.g. `PullToRefreshList.dataProvider`, or
   `didUpdateWidget`) must not call `notifyListeners()` before its first
   `await`. Notify after the async gap, or defer with
   `WidgetsBinding.instance.addPostFrameCallback`.
7. **Dependency injection via get_it.** Register in
   `lib/shared/services/service_locator.dart`: repositories as
   `registerLazySingleton`, ViewModels as `registerSingleton`. Inject
   collaborators through the constructor (e.g. `MailViewModel(getIt<MailRepository>())`)
   so they can be unit-tested with fakes.
8. **Riverpod is legacy.** Do not add new Riverpod providers. Existing ones stay
   until migrated.

## Consequences

**Positive**
- Consistent, predictable feature shape; easy to review and extend.
- Domain and ViewModels are unit-testable without the framework (constructor
  injection + pure mapping). See `test/features/mail/`.
- UI depends on abstractions, so data sources and rendering can change
  independently.

**Negative / trade-offs**
- Some boilerplate (entity + data model + mapper) even for simple features.
- During the transition, list-heavy screens still use `PullToRefreshList`, which
  owns its own display list. The ViewModel state is the source of truth and the
  list is rendered from `PullToRefreshList` until it is refactored to render
  straight from state. This is intentional and temporary.

## Reference implementations

- `lib/features/userstats/` — repository-only (no ViewModel), SQLite datasource.
- `lib/features/gallery/`, `lib/features/message/` — ViewModel + immutable State.
- `lib/features/mail/` — ViewModel + immutable State, a freezed domain entity
  that `implements IPost`, data-layer JSON mapping, consumed by `MailboxTab` via
  `watchIt`. Note the transitional `PullToRefreshList` coupling described above.
