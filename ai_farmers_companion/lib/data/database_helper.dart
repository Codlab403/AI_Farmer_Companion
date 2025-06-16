import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'farmers_companion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE crop_tips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        region TEXT,
        content TEXT,
        syncStatus INTEGER DEFAULT 0 -- Add syncStatus column (0: synced, 1: added, 2: modified, 3: deleted)
      )
    ''');
    // TODO: Add other table creation logic here if needed
  }

  // TODO: Add methods for CRUD operations (insert, query, update, delete)
}
