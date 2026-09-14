import '../../../search/domain/models/book.dart';

/// Domain contract for favourites. Works in [Book]s; the SQL representation is
/// hidden behind the data layer.
abstract interface class FavouritesRepository {
  Future<List<Book>> getFavourites();
  Future<void> addFavourite(Book book);
  Future<void> removeFavourite(String key);
}
