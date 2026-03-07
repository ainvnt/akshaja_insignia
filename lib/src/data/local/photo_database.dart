import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class PhotoDatabase {
  PhotoDatabase();

  static const String _databaseName = 'photo_records.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'photos';

  Database? _database;

  Future<void> init() async {
    await _db;
  }

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _databaseName);
    return openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            file_path TEXT NOT NULL,
            captured_at TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            upload_status TEXT NOT NULL,
            uploaded_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> insert(PhotoRecord record) async {
    final db = await _db;
    await db.insert(
      _tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUploadState({
    required String photoId,
    required UploadStatus status,
    DateTime? uploadedAt,
  }) async {
    final db = await _db;
    await db.update(
      _tableName,
      <String, Object?>{
        'upload_status': status.value,
        'uploaded_at': uploadedAt?.toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[photoId],
    );
  }

  Future<List<PhotoRecord>> fetchAll() async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      orderBy: 'captured_at DESC',
    );
    return rows.map(PhotoRecord.fromMap).toList();
  }

  Future<List<PhotoRecord>> fetchPending() async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      where: 'upload_status = ?',
      whereArgs: <Object?>[UploadStatus.pending.value],
      orderBy: 'captured_at ASC',
    );
    return rows.map(PhotoRecord.fromMap).toList();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
