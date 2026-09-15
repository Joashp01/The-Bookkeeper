# The Bookkeeper

A Flutter app for searching and saving books, built on the [Open Library](https://openlibrary.org) API.

> Named **The Bookkeeper** (the assessment brief calls it "Bookshelf" — the rename is intentional; the Dart package is still `bookshelf`).

It covers search with debounce + pagination, a work detail screen, locally-persisted favourites, offline caching with an offline indicator, and a defensive mapping layer for Open Library's inconsistent responses.

---

## 1. How to run

Assumes a clean machine.

**Prerequisites:** Flutter (stable) with **Dart ≥ 3.13.3**. Verify with `flutter --version`.

```bash
git clone <repo-url>
cd The-Bookkeeper
flutter pub get
flutter run          # select an Android or iOS device/emulator
```

**Supported platforms:** Android and iOS. Web/desktop are not wired up yet — see [Limitations](#6-limitations).

**Run the tests:**
```bash
flutter test                 # all tests
flutter test --coverage      # writes coverage/lcov.info
flutter analyze              # zero issues
```

---

## 2. Architecture

The app uses **MVVM expressed as a layered architecture**, which satisfies the brief's presentation / domain / data separation and its "data source behind an interface" requirement.

```
┌───────────────────────────────────────────────────────────────┐
│ PRESENTATION (View)                                            │
│   Screens & widgets — render state, forward intents, no logic. │
├───────────────────────────────────────────────────────────────┤
│ BUSINESS LOGIC (ViewModel — ChangeNotifier)                    │
│   Debounce, pagination, state machine, favourite toggling.     │
│   Depends only on repository abstractions.                     │
├───────────────────────────────────────────────────────────────┤
│ DOMAIN / SERVICE (Repository interfaces + immutable models)    │
│   Owns mapping (F5), the offline-fallback decision, and the    │
│   exception → typed-Failure policy. Depends on data abstractions.│
├───────────────────────────────────────────────────────────────┤
│ DATA (Data sources behind interfaces)                          │
│   RemoteDataSource (http) · Local/Cache data sources (sqflite).│
│   Pure I/O returning DTOs; no domain decisions.                │
└───────────────────────────────────────────────────────────────┘
```

**Folder layout** (`lib/`):
```
core/        error (Failure, Result, exceptions, mapper), network (connectivity), database, theme, di
features/
  search/    data (datasources, dtos, mappers, repositories) · domain (models, repositories) · presentation (viewmodels, screens, widgets)
  favourites/ same three-layer shape
shared/      cross-feature widgets (cover image)
```

**Key decisions:**
- **The data source sits behind an interface** (`SearchRemoteDataSource`, `FavouritesLocalDataSource`, `SearchCacheDataSource`, `BookDetailRemoteDataSource`, `ConnectivityChecker`). Repositories depend on the abstraction, so tests drive the real repository against a **mocked `http.Client`** or an in-memory sqflite database at the same seam.
- **Dependency injection** happens only at the composition root ([`lib/core/di/app_providers.dart`](lib/core/di/app_providers.dart)). Nothing constructs its own dependencies. The database is opened once in `main` and injected.
- **Immutable models** — `final` fields, `const` constructors, value equality via `equatable`.
- **Explicit error handling** — the data layer throws typed exceptions; a single shared [`mapErrorToFailure`](lib/core/error/failure_mapper.dart) translates them into a sealed `Failure`, and repositories return a `Result<T>` (`Success` / `FailureResult`) so every caller handles both branches. There are no empty catch blocks.
- **Defensive mapping (F5)** lives in the DTOs/mappers and is the most heavily unit-tested part: `author_name` as list / bare string / absent, `cover_i` and `first_publish_year` absent, and `description` as a string / `{value}` object / absent. "What the UI shows" for each missing field is centralised on the immutable models as display getters and tested once.

---

## 3. State management

**Choice: `provider` + `ChangeNotifier` view models.**

MVVM's ViewModel maps one-to-one onto a `ChangeNotifier`, and `provider` supplies exactly the dependency-injection seam the architecture needs — repositories and view models are provided from the composition root and swapped for fakes in tests. It is the smallest tool that satisfies *DI + a testable seam + no business logic in widgets*, and every line is easy to explain and defend.

`FavouritesViewModel` is provided **once, app-wide**, so it is a single source of truth: favouriting from the results list, the detail screen, or the favourites screen all mutate the same set and stay consistent.

Alternatives considered: **Riverpod** (stronger compile-time DI and testability — the choice at larger scale) and **Bloc** (great event traceability, but more ceremony than this scope needs). The view models are framework-agnostic, so switching later would be cheap.

---

## 4. Testing

Testing drove the implementation; the git history shows tests landing before/alongside the code they cover, feature branch by feature branch.

**Coverage: 89.1% of `lib/`** (549 / 616 lines). `coverage/lcov.info` is committed.

**What's tested (112 tests):**
- **Repository unit tests against a mocked `http.Client`** — success, HTTP error, malformed/unexpected JSON, and an empty result set (search and detail repositories).
- **Mapping (F5)** — every messy-field case for the search and works endpoints, plus the display-fallback decisions on the models.
- **Favourites persistence** — add, remove, and **survive a restart** (a real file-backed database is closed and re-opened) using `sqflite_common_ffi`.
- **Offline (F4)** — cache round-trip via ffi; repository serves cache with an offline flag when the device is offline, returns a `NetworkFailure` when there's no cache, and does *not* serve cache for a transient failure while online.
- **View models** — debounce (via `fake_async`), pagination append, state transitions, the offline flag, and favourite toggle with rollback on failure.
- **Widget tests** — the loading / results / empty / error search states, the offline banner, the favourite toggle, the detail screen, and the favourites screen.

**How to run:**
```bash
flutter test --coverage
```
Test doubles: `mocktail` for the HTTP client and repositories; `sqflite_common_ffi` for real database behaviour; hand-written fakes for view-model seams.

---

## 5. AI usage

I used **Claude (Anthropic), via Claude Code**, throughout:
- Drafting the implementation plan and breaking the work into feature branches.
- Scaffolding the layered structure and boilerplate (DTOs, mappers, DI wiring).
- Writing and iterating on the test suite.
- Drafting this README.

Every line was reviewed, run, and is code I can explain and extend. AI was a pair-programmer, not an autopilot.

---

## 6. Limitations

What I'd do with more time, and what I know is weak:

- **No web/desktop build yet.** `sqflite` doesn't run on web; supporting it means adding `sqflite_common_ffi_web` and initialising the web database factory in `main` (and `sqflite_common_ffi` for desktop). Mobile is the working target.
- **No CI pipeline.** A GitHub Actions workflow running `flutter analyze` + `flutter test` on every push is the natural next step (a listed bonus).
- **Offline detection is heuristic.** A transport-level failure plus a connectivity check triggers the cache fallback; it does not distinguish every possible network condition, and there is no background revalidation of stale cache.
- **Pagination** assumes Open Library's default page size and uses `numFound` vs. accumulated results to decide `hasMore`; it doesn't guard against the API reporting an inconsistent `numFound`.
- **Detail author/year** are threaded from the originating search result because the works endpoint returns author *keys*, not names; resolving author records would need extra requests.
- **Theming/accessibility** are functional ("clean and legible") but not polished — semantic labels and large-text-scale hardening are listed bonuses I didn't reach.
- `main.dart`'s startup (opening the on-device database) isn't unit-tested, as it depends on the platform sqflite plugin.

---

## 7. Time spent

Roughly **10–12 hours** across planning, implementation, tests, and documentation.

*(Replace with your honest figure before submitting.)*
