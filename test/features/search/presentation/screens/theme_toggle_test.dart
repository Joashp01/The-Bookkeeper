import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/core/theme/theme_preference_store.dart';
import 'package:bookshelf/core/theme/theme_view_model.dart';
import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/features/favourites/presentation/viewmodels/favourites_view_model.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:bookshelf/features/search/presentation/screens/search_screen.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _NoopSearchRepository implements SearchRepository {
  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) async => const Success(SearchResult(books: [], numFound: 0, page: 1));
}

class _NoopFavouritesRepository implements FavouritesRepository {
  @override
  Future<List<Book>> getFavourites() async => const [];

  @override
  Future<void> addFavourite(Book book) async {}

  @override
  Future<void> removeFavourite(String key) async {}
}

class _InMemoryThemeStore implements ThemePreferenceStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

Widget _wrap(ThemeViewModel themeViewModel) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SearchViewModel>(
        create: (_) => SearchViewModel(repository: _NoopSearchRepository()),
      ),
      ChangeNotifierProvider<FavouritesViewModel>(
        create: (_) =>
            FavouritesViewModel(repository: _NoopFavouritesRepository()),
      ),
      ChangeNotifierProvider<ThemeViewModel>.value(value: themeViewModel),
    ],
    child: Consumer<ThemeViewModel>(
      builder: (context, vm, _) => MaterialApp(
        themeMode: vm.themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const SearchScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('starts on the system icon', (tester) async {
    await tester.pumpWidget(
      _wrap(ThemeViewModel(store: _InMemoryThemeStore())),
    );

    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
  });

  testWidgets('tapping the toggle cycles the icon and the app theme mode', (
    tester,
  ) async {
    final store = _InMemoryThemeStore();
    final vm = ThemeViewModel(store: store);
    await tester.pumpWidget(_wrap(vm));

    await tester.tap(find.byIcon(Icons.brightness_auto));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(vm.themeMode, ThemeMode.light);
    expect(store.value, 'light');

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(vm.themeMode, ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    expect(vm.themeMode, ThemeMode.system);
  });

  testWidgets('the toggle exposes a tooltip label for accessibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ThemeViewModel(store: _InMemoryThemeStore())),
    );

    expect(find.byTooltip('Theme: follow system'), findsOneWidget);
  });
}
