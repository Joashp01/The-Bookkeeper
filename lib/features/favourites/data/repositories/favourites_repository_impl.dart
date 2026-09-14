import '../../../search/domain/models/book.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../datasources/favourites_local_data_source.dart';
import '../mappers/favourite_mapper.dart';

/// Default [FavouritesRepository] backed by local SQL storage. Maps between the
/// domain [Book] and the persisted [FavouriteDto].
class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl({required this.localDataSource});

  final FavouritesLocalDataSource localDataSource;

  @override
  Future<List<Book>> getFavourites() async {
    final dtos = await localDataSource.getAll();
    return dtos.map((dto) => dto.toBook()).toList(growable: false);
  }

  @override
  Future<void> addFavourite(Book book) =>
      localDataSource.upsert(book.toFavouriteDto());

  @override
  Future<void> removeFavourite(String key) => localDataSource.delete(key);
}
