import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../search/domain/models/book.dart';
import '../../domain/repositories/favourites_repository.dart';

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

  Future<String?> toggle(Book book) async {
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
      return null;
    } on CacheException catch (error) {
      if (wasFavourite) {
        _favourites[book.key] = book;
      } else {
        _favourites.remove(book.key);
      }
      notifyListeners();
      return messageForFailure(mapErrorToFailure(error));
    }
  }
}
