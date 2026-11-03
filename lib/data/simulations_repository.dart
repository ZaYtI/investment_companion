import 'package:sqflite/sqflite.dart';

import '../models/saved_simulation.dart';
import 'app_database.dart';

class SimulationsRepository {
  static const _table = 'simulations';

  Database? _database;

  Future<Database> get _openedDatabase async =>
      _database ??= await AppDatabase.open();

  Future<List<SavedSimulation>> getAll() async {
    final database = await _openedDatabase;
    final rows = await database.query(_table, orderBy: 'created_at DESC');
    return rows.map(SavedSimulation.fromMap).toList();
  }

  Future<int> insert(SavedSimulation simulation) async {
    final database = await _openedDatabase;
    return database.insert(_table, simulation.toMap());
  }

  Future<void> delete(int id) async {
    final database = await _openedDatabase;
    await database.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
