# The Bookkeeper

## About

The app lets users search, view and favourite books using the [Open Library](https://openlibrary.org) API.

It has debounced search with pagination, a book detail screen, favourites saved on the device, offline caching with an offline indicator, and a dark mode toggle.


## Tech Stack

**Core Framework**
- Flutter 3.47.4
- Dart 3.13.3

**State Management & Architecture**
- provider
- equatable

**Data & Storage**
- http: HTTP client for the Open Library API
- sqflite: local storage for favourites and offline cache
- sqflite_common_ffi_web: sqlite on the web
- cached_network_image: image caching for book covers
- connectivity_plus: network state for offline detection

**Testing**
- flutter_test
- mocktail
- sqflite_common_ffi
- fake_async

## 1. How to run

**Prerequisites**
- Flutter (stable) with Dart 3.13.3 or higher. Check with `flutter --version`.

**Installation steps**

Clone the repo:
```bash
git clone <repo-url>
cd The-Bookkeeper
```

Install dependencies:
```bash
flutter pub get
```

Run the app:
```bash
flutter run                 # Android or iOS device / emulator
flutter run -d chrome       # web
```

Runs on Android, iOS and web. On web the required `web/sqflite_sw.js` and `web/sqlite3.wasm` files are already in the repo, so a fresh clone builds with no extra setup.

## 2. Architecture

I structured it as MVVM in three layers, so the presentation, domain and data code stay separate and easy to test.

- **Presentation:** screens and widgets. They show state and pass user actions up. No logic.
- **Business logic (view models):** debounce, pagination, and favourite toggling. They only talk to repository interfaces.
- **Domain:** repository interfaces and immutable models. This is where the offline fallback and error handling decisions live.
- **Data:** data sources behind interfaces. Remote uses `http`, local and cache use `sqflite`. They just do I/O.

Folder layout (`lib/`):
```
core/        error, network, database, theme, di
features/
  search/     data, domain, presentation
  favourites/ data, domain, presentation
shared/       shared widgets
```

Why I made these choices:
- Every data source sits behind an interface, so tests run the real repository against a mocked `http.Client` or an in-memory database.
- Dependencies are wired up in one place, the composition root at [`lib/core/di/app_providers.dart`](lib/core/di/app_providers.dart).
- Models are immutable and use `equatable` for value equality.
- The data layer throws typed exceptions and a single mapper turns them into a `Failure`. Repositories return a `Result`, so callers always handle both the success and failure case. No empty catch blocks.
- The mapping layer handles Open Library's messy responses (for example `author_name` can be a list, a plain string, or missing), and this is the most heavily tested part.

## 3. State management

I chose **Provider** with `ChangeNotifier` view models.

It maps cleanly onto MVVM, gives me constructor-level dependency injection, and lets me swap in fake repositories in tests without the widgets knowing. It is the simplest thing that meets the requirements (layered separation, a swappable data source, no business logic in widgets) without adding code generation or a new mental model for whoever reads this next.

The favourites view model is provided once at the app root, so favouriting from the results list, the detail screen or the favourites screen all read and write the same source of truth.

### Why I'm confident in this choice

Working on Porcupine's DigitalApp,I have seen this patterns pros and cons.

Pros:A small API surface, no build step, and repositories behind abstract interfaces that take an optional constructor dependency.

Cons: nothing checks at compile time that a provider is registered above you in the tree, it is easy to notify too broadly and rebuild more than you meant to, and disposal is manual, so async work that outlives a widget will happily call back into a disposed notifier. 


## 4. Testing

I wrote tests alongside the code, feature branch by feature branch.

**Coverage: 89.3% of `lib/`** (550 of 616 lines). `coverage/lcov.info` is in the repo.

What is tested (148 tests):
- Repositories against a mocked `http.Client`: success, HTTP errors, bad JSON, and empty results.
- Mapping: every messy field case from the API, plus the display fallbacks on the models.
- Favourites: add, remove, and surviving a restart with a real database.
- Offline: serving the cache with an offline flag when offline, and a network failure when there is no cache.
- View models: debounce, pagination, state changes, and favourite toggle with rollback on failure.
- Widget tests: the loading, results, empty and error states, the offline banner, the favourite toggle, the detail screen and the favourites screen.

How to run:
```bash
flutter test --coverage
```

## 5. AI usage

I used **Claude (Anthropic), through Claude Code**, for:
- Planning the work.
- Scaffolding the layers and boilerplate (DTOs, mappers, DI wiring).
- Writing and improving the tests.
- Drafting this README.

I reviewed and ran everything. It is all code I can explain and extend.

## 6. Limitations

What I would do with more time, and what I know is weak:

- **Desktop is not set up.** Only Android, iOS and web are wired up. A desktop build would need `sqflite_common_ffi` set up in `main`.
- **Web storage lives in the browser.** Favourites and cache are per browser and get cleared if the user clears site data.
- **Offline detection is simple.** A failed request plus a connectivity check triggers the cache fallback. It does not cover every network case, and there is no background refresh of stale cache.
- **Detail author and year** are passed in from the search result, because the works endpoint only returns author keys, not names. Resolving those would need extra requests.

## 7. Time spent

Roughly **10 hours** over four days, covering planning, building, tests and this README.
</content>
