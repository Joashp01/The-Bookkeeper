import '../../../search/domain/models/book.dart';

abstract interface class FavouritesRepository {
  Future<List<Book>> getFavourites();
  Future<void> addFavourite(Book book);
  Future<void> removeFavourite(String key);
}
