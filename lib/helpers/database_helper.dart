// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:time_bunny/models/meeting.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meetings.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meetings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        participants TEXT NOT NULL,
        timezone TEXT NOT NULL,
        utcDateTime TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertMeeting(Meeting meeting) async {
    final db = await instance.database;
    await db.insert(
      'meetings',
      meeting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meeting>> getAllMeetings() async {
    final db = await instance.database;
    final result = await db.query('meetings', orderBy: 'date ASC');
    return result.map((map) => Meeting.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<Meeting>> getMeetingsForDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'meetings',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'startTime ASC',
    );
    return result.map((map) => Meeting.fromMap(map)).toList();
  }
}
