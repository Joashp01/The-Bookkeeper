import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../dtos/favourite_dto.dart';

abstract interface class FavouritesLocalDataSource {
  Future<List<FavouriteDto>> getAll();
  Future<void> upsert(FavouriteDto favourite);
  Future<void> delete(String key);
}

class FavouritesLocalDataSourceImpl implements FavouritesLocalDataSource {
  FavouritesLocalDataSourceImpl({required this.database});

  final Database database;

  @override
  Future<List<FavouriteDto>> getAll() async {
    final rows = await database.query(
      favouritesTable,
      orderBy: '$columnTitle COLLATE NOCASE',
    );
    return rows.map(FavouriteDto.fromMap).toList(growable: false);
  }

  @override
  Future<void> upsert(FavouriteDto favourite) async {
    await database.insert(
      favouritesTable,
      favourite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String key) async {
    await database.delete(
      favouritesTable,
      where: '$columnKey = ?',
      whereArgs: [key],
    );
  }
}
