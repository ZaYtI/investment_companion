import 'app_database.dart';

class FavoritesRepository {
  static const _table = 'favorites';

  Future<List<String>> getAll() async {
    final database = await AppDatabase.open();
    final rows = await database.query(_table, orderBy: 'added_at');
    return [for (final row in rows) row['asset_id'] as String];
  }

  Future<void> add(String assetId) async {
    final database = await AppDatabase.open();
    await database.insert(_table, {
      'asset_id': assetId,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> remove(String assetId) async {
    final database = await AppDatabase.open();
    await database.delete(_table, where: 'asset_id = ?', whereArgs: [assetId]);
  }
}
