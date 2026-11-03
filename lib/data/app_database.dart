import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _fileName = 'investment_companion.db';
  static const _version = 1;

  static Future<Database> open() async {
    final folder = await getDatabasesPath();
    return openDatabase(
      join(folder, _fileName),
      version: _version,
      onCreate: (database, version) async {
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
      },
    );
  }
}
