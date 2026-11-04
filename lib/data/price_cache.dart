import 'package:sqflite/sqflite.dart';

import '../models/price_point.dart';
import 'app_database.dart';

class PriceCache {
  static const _pricesTable = 'price_cache';
  static const _metaTable = 'price_meta';

  Future<List<PricePoint>> pointsOf(String seriesId) async {
    final database = await AppDatabase.open();
    final rows = await database.query(
      _pricesTable,
      where: 'series_id = ?',
      whereArgs: [seriesId],
      orderBy: 'date',
    );
    return [
      for (final row in rows)
        PricePoint(
          date: DateTime.parse(row['date'] as String),
          close: (row['close'] as num).toDouble(),
        ),
    ];
  }

  Future<void> save(String seriesId, List<PricePoint> points) async {
    final database = await AppDatabase.open();
    final batch = database.batch();
    for (final point in points) {
      batch.insert(_pricesTable, {
        'series_id': seriesId,
        'date': point.date.toIso8601String(),
        'close': point.close,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    batch.insert(_metaTable, {
      'series_id': seriesId,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await batch.commit(noResult: true);
  }

  Future<DateTime?> lastUpdateOfAll() async {
    final database = await AppDatabase.open();
    final rows = await database.rawQuery(
      'SELECT MAX(updated_at) AS last_update FROM $_metaTable',
    );
    final lastUpdate = rows.first['last_update'] as String?;
    return lastUpdate == null ? null : DateTime.parse(lastUpdate);
  }

  Future<DateTime?> lastUpdateOf(String seriesId) async {
    final database = await AppDatabase.open();
    final rows = await database.query(
      _metaTable,
      where: 'series_id = ?',
      whereArgs: [seriesId],
    );
    if (rows.isEmpty) return null;
    return DateTime.parse(rows.first['updated_at'] as String);
  }
}
