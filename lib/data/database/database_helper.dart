import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fluentpath.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(filePath, version: 1, onCreate: _createDB);
    } else {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE user_profile (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      name            TEXT NOT NULL,
      avatar_index    INTEGER DEFAULT 0,
      level           TEXT DEFAULT 'Beginner',
      total_xp        INTEGER DEFAULT 0,
      daily_goal_mins INTEGER DEFAULT 15,
      selected_tutor  TEXT DEFAULT 'Friendly Buddy',
      created_at      TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE sessions (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      scenario      TEXT NOT NULL,
      tutor_persona TEXT NOT NULL,
      chat_history  TEXT NOT NULL,
      duration_mins INTEGER DEFAULT 0,
      date          TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE vocabulary (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      word       TEXT NOT NULL,
      phonetic   TEXT,
      meaning    TEXT NOT NULL,
      example    TEXT,
      usage_tip  TEXT,
      category   TEXT DEFAULT 'General',
      status     TEXT DEFAULT 'learning',
      date_added TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE quiz_scores (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      quiz_type       TEXT NOT NULL,
      topic           TEXT NOT NULL,
      score           INTEGER NOT NULL,
      total_questions INTEGER NOT NULL,
      xp_earned       INTEGER DEFAULT 0,
      wrong_answers   TEXT,
      date            TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      title      TEXT NOT NULL,
      body       TEXT NOT NULL,
      category   TEXT DEFAULT 'General',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE streaks (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      date           TEXT NOT NULL UNIQUE,
      practiced      INTEGER DEFAULT 0,
      words_learned  INTEGER DEFAULT 0,
      quiz_completed INTEGER DEFAULT 0,
      xp_earned      INTEGER DEFAULT 0
    )''');
  }

  // ── USER ──────────────────────────────────────────────
  Future<int> insertUser(Map<String, dynamic> user) async =>
    (await database).insert('user_profile', user);

  Future<Map<String, dynamic>?> getUser() async {
    final r = await (await database).query('user_profile', limit: 1);
    return r.isNotEmpty ? r.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> values) async =>
    (await database).update('user_profile', values, where: 'id = ?', whereArgs: [1]);

  // ── SESSIONS ──────────────────────────────────────────
  Future<int> insertSession(Map<String, dynamic> s) async =>
    (await database).insert('sessions', s);

  Future<List<Map<String, dynamic>>> getSessions() async =>
    (await database).query('sessions', orderBy: 'date DESC');

  Future<int> getTodaySessionMins() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COALESCE(SUM(duration_mins),0) as t FROM sessions WHERE date=?', [today]);
    return r.first['t'] as int;
  }

  // ── VOCABULARY ────────────────────────────────────────
  Future<int> insertWord(Map<String, dynamic> w) async =>
    (await database).insert('vocabulary', w);

  Future<List<Map<String, dynamic>>> getWords({String? status}) async {
    final db = await database;
    if (status != null && status != 'all') {
      return db.query('vocabulary', where: 'status=?', whereArgs: [status], orderBy: 'date_added DESC');
    }
    return db.query('vocabulary', orderBy: 'date_added DESC');
  }

  Future<int> getWordCount() async {
    final r = await (await database).rawQuery('SELECT COUNT(*) as c FROM vocabulary');
    return r.first['c'] as int;
  }

  Future<int> getTodayWordCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COUNT(*) as c FROM vocabulary WHERE date_added=?', [today]);
    return r.first['c'] as int;
  }

  Future<int> updateWordStatus(int id, String status) async =>
    (await database).update('vocabulary', {'status': status}, where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> searchWords(String q) async =>
    (await database).query('vocabulary', where: 'word LIKE ?', whereArgs: ['%$q%']);

  Future<int> deleteWord(int id) async =>
    (await database).delete('vocabulary', where: 'id=?', whereArgs: [id]);

  // ── QUIZ SCORES ───────────────────────────────────────
  Future<int> insertQuizScore(Map<String, dynamic> s) async =>
    (await database).insert('quiz_scores', s);

  Future<List<Map<String, dynamic>>> getLastQuizScores(int limit) async =>
    (await database).query('quiz_scores', orderBy: 'date DESC', limit: limit);

  Future<double> getAverageQuizScore() async {
    final r = await (await database).rawQuery(
      'SELECT AVG(CAST(score AS FLOAT)/total_questions*100) as avg FROM quiz_scores');
    return (r.first['avg'] as double?) ?? 0.0;
  }

  Future<bool> quizDoneToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COUNT(*) as c FROM quiz_scores WHERE date=?', [today]);
    return (r.first['c'] as int) > 0;
  }

  // ── NOTES ─────────────────────────────────────────────
  Future<int> insertNote(Map<String, dynamic> n) async =>
    (await database).insert('notes', n);

  Future<List<Map<String, dynamic>>> getNotes() async =>
    (await database).query('notes', orderBy: 'updated_at DESC');

  Future<int> updateNote(int id, Map<String, dynamic> v) async =>
    (await database).update('notes', v, where: 'id=?', whereArgs: [id]);

  Future<int> deleteNote(int id) async =>
    (await database).delete('notes', where: 'id=?', whereArgs: [id]);

  // ── STREAKS ───────────────────────────────────────────
  Future<void> upsertTodayStreak(Map<String, dynamic> data) async =>
    (await database).insert('streaks', data, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<Map<String, dynamic>?> getTodayStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).query('streaks', where: 'date=?', whereArgs: [today]);
    return r.isNotEmpty ? r.first : null;
  }

  Future<List<Map<String, dynamic>>> getLast7DaysStreaks() async {
    final ago = DateTime.now().subtract(const Duration(days: 6)).toIso8601String().split('T')[0];
    return (await database).query('streaks', where: 'date>=?', whereArgs: [ago], orderBy: 'date ASC');
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final days = await db.query('streaks', where: 'xp_earned>0', orderBy: 'date DESC');
    if (days.isEmpty) return 0;
    int streak = 0;
    DateTime expected = DateTime.now();
    for (var day in days) {
      final d = DateTime.parse(day['date'] as String);
      if (expected.difference(d).inDays <= 1) {
        streak++;
        expected = d;
      } else {
        break;
      }
    }
    return streak;
  }

  // ── SYSTEM RESET ──────────────────────────────────────
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('user_profile');
    await db.delete('sessions');
    await db.delete('vocabulary');
    await db.delete('quiz_scores');
    await db.delete('notes');
    await db.delete('streaks');
  }
}
