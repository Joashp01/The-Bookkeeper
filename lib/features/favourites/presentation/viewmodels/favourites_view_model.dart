import 'package:flutter/foundation.dart';

import '../../../search/domain/models/book.dart';
import '../../domain/repositories/favourites_repository.dart';

/// Single source of truth for favourite state across the whole app.
///
/// Because one instance is provided app-wide, the results list, the detail
/// screen and the favourites screen all read and mutate the same set, so a
/// toggle in one place is immediately reflected everywhere.
class FavouritesViewModel extends ChangeNotifier {
  FavouritesViewModel({required FavouritesRepository repository})
      : _repository = repository; // ignore: prefer_initializing_formals

  final FavouritesRepository _repository;

  final Map<String, Book> _favourites = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Book> get favourites => List.unmodifiable(_favourites.values);
  bool isFavourite(String key) => _favourites.containsKey(key);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final books = await _repository.getFavourites();
    _favourites
      ..clear()
      ..addEntries(books.map((book) => MapEntry(book.key, book)));

    _isLoading = false;
    notifyListeners();
  }

  /// Adds or removes [book] optimistically, then persists. If persistence fails
  /// the optimistic change is rolled back so the UI never disagrees with storage.
  Future<void> toggle(Book book) async {
    final wasFavourite = isFavourite(book.key);

    if (wasFavourite) {
      _favourites.remove(book.key);
    } else {
      _favourites[book.key] = book;
    }
    notifyListeners();

    try {
      if (wasFavourite) {
        await _repository.removeFavourite(book.key);
      } else {
        await _repository.addFavourite(book);
      }
    } catch (_) {
      if (wasFavourite) {
        _favourites[book.key] = book;
      } else {
        _favourites.remove(book.key);
      }
      notifyListeners();
    }
  }
}
