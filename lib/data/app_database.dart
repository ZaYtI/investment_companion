import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _fileName = 'investment_companion.db';
  static const _version = 2;

  static Future<Database>? _database;

  static Future<Database> open() => _database ??= _openDatabase();

  static Future<Database> _openDatabase() async {
    final folder = await getDatabasesPath();
    return openDatabase(
      join(folder, _fileName),
      version: _version,
      onCreate: (database, version) async {
        await _createSimulationsTable(database);
        await _createPriceTables(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createPriceTables(database);
        }
      },
    );
  }

  static Future<void> _createSimulationsTable(Database database) async {
    await database.execute('''
      CREATE TABLE simulations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start TEXT NOT NULL,
        mode TEXT NOT NULL,
        amount REAL NOT NULL,
        weights TEXT NOT NULL,
        invested REAL NOT NULL,
        final_value REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createPriceTables(Database database) async {
    await database.execute('''
      CREATE TABLE price_cache (
        series_id TEXT NOT NULL,
        date TEXT NOT NULL,
        close REAL NOT NULL,
        PRIMARY KEY (series_id, date)
      )
    ''');
    await database.execute('''
      CREATE TABLE price_meta (
        series_id TEXT PRIMARY KEY,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}
