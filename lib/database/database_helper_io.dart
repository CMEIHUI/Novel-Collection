import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/novel.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('novel_collection.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    // Use version 2 to allow adding new columns in an upgrade path
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final info = await db.rawQuery("PRAGMA table_info(novels);");
          final hasColumn = info.any(
            (row) => row['name'] == 'lastOpenedChapter',
          );
          if (!hasColumn) {
            await db.execute(
              'ALTER TABLE novels ADD COLUMN lastOpenedChapter TEXT',
            );
          }
        }
        if (oldVersion < 3) {
          final info = await db.rawQuery("PRAGMA table_info(novels);");
          final hasContent = info.any((row) => row['name'] == 'content');
          if (!hasContent) {
            await db.execute('ALTER TABLE novels ADD COLUMN content TEXT');
          }
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE novels(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      author TEXT NOT NULL,
      genre TEXT NOT NULL,
      rating REAL NOT NULL,
      review TEXT NOT NULL,
      coverImage TEXT,
      content TEXT,
      isFavorite INTEGER NOT NULL DEFAULT 0,
      totalPages INTEGER NOT NULL DEFAULT 0,
      pagesRead INTEGER NOT NULL DEFAULT 0,
      lastOpenedChapter TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
    ''');
  }

  // Create
  Future<int> insertNovel(Novel novel) async {
    final db = await instance.database;

    return await db.insert('novels', novel.toMap());
  }

  // Read All
  Future<List<Novel>> getNovels() async {
    final db = await instance.database;

    final result = await db.query('novels', orderBy: 'title ASC');

    return result.map((e) => Novel.fromMap(e)).toList();
  }

  // Update
  Future<int> updateNovel(Novel novel) async {
    final db = await instance.database;

    return await db.update(
      'novels',
      novel.toMap(),
      where: 'id=?',
      whereArgs: [novel.id],
    );
  }

  // Delete
  Future<int> deleteNovel(int id) async {
    final db = await instance.database;

    return await db.delete('novels', where: 'id=?', whereArgs: [id]);
  }

  Future<int> insertUser(AppUser user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<List<AppUser>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users', orderBy: 'id ASC');
    return result.map((e) => AppUser.fromMap(e)).toList();
  }

  Future<int> updateUser(AppUser user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id=?',
      whereArgs: [user.id],
    );
  }

  Future<int> clearUsers() async {
    final db = await instance.database;
    return await db.delete('users');
  }

  Future<String> exportDatabase() async {
    final db = await instance.database;
    final rows = await db.query('novels');
    return jsonEncode(rows);
  }

  Future<int> importDatabase(String payload) async {
    final db = await instance.database;
    final decoded = jsonDecode(payload) as List<dynamic>;
    final rows = decoded.cast<Map<String, dynamic>>();

    await db.delete('novels');
    for (final row in rows) {
      await db.insert('novels', row);
    }
    return rows.length;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
