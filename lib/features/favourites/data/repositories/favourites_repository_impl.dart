import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../search/domain/models/book.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../datasources/favourites_local_data_source.dart';
import '../mappers/favourite_mapper.dart';

/// Default [FavouritesRepository] backed by local SQL storage. Maps between the
/// domain [Book] and the persisted [FavouriteDto], and translates a low-level
/// [DatabaseException] into a typed [CacheException] so the layers above never
/// see sqflite (nor swallow the error).
class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl({required this.localDataSource});

  final FavouritesLocalDataSource localDataSource;

  @override
  Future<List<Book>> getFavourites() => _guard(() async {
        final dtos = await localDataSource.getAll();
        return dtos.map((dto) => dto.toBook()).toList(growable: false);
      });

  @override
  Future<void> addFavourite(Book book) =>
      _guard(() => localDataSource.upsert(book.toFavouriteDto()));

  @override
  Future<void> removeFavourite(String key) =>
      _guard(() => localDataSource.delete(key));

  /// Runs [action], re-throwing any [DatabaseException] as a typed
  /// [CacheException]. Other errors propagate unchanged.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error) {
      throw CacheException(error.toString());
    }
  }
}
