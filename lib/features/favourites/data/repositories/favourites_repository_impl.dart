import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../search/domain/models/book.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../datasources/favourites_local_data_source.dart';
import '../mappers/favourite_mapper.dart';

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

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error) {
      throw CacheException(error.toString());
    }
  }
}
