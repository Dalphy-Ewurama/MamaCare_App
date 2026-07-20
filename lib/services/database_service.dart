import 'dart:io';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/antenatal_visit.dart';
import '../models/pregnant_woman.dart';
import '../models/vaccination_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const _sessionEmailKey = 'auth_session_email';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mamacare.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createSchema(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        gestational_age_weeks INTEGER NOT NULL,
        expected_delivery_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pregnant_women (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        gestational_age_weeks INTEGER NOT NULL,
        expected_delivery_date TEXT NOT NULL,
        registered_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS antenatal_visits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccinations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        due_date TEXT NOT NULL,
        completed INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int gestationalAgeWeeks,
    required String expectedDeliveryDate,
  }) async {
    final db = await database;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return false;
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('users', {
      'id': userId,
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'gestational_age_weeks': gestationalAgeWeeks,
      'expected_delivery_date': expectedDeliveryDate,
    });

    await _setSessionEmail(email);
    return true;
  }

  Future<bool> loginUser({required String email, required String password}) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    await _setSessionEmail(email);
    return true;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final email = await _getSessionEmail();
    if (email == null || email.isEmpty) {
      return null;
    }

    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return {
      'id': row['id'],
      'fullName': row['full_name'],
      'email': row['email'],
      'phoneNumber': row['phone_number'],
      'gestationalAgeWeeks': row['gestational_age_weeks'],
      'expectedDeliveryDate': row['expected_delivery_date'],
    };
  }

  Future<void> savePregnantWomanRecord(PregnantWoman record) async {
    final db = await database;
    await db.insert(
      'pregnant_women',
      {
        'id': record.id,
        'full_name': record.fullName,
        'email': record.email,
        'phone_number': record.phoneNumber,
        'gestational_age_weeks': record.gestationalAgeWeeks,
        'expected_delivery_date': record.expectedDeliveryDate,
        'registered_at': record.registeredAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PregnantWoman>> loadPregnantWomanRecords() async {
    final db = await database;
    final rows = await db.query('pregnant_women', orderBy: 'registered_at DESC');
    return rows
        .map(
          (row) => PregnantWoman(
            id: row['id'].toString(),
            fullName: row['full_name'].toString(),
            email: row['email'].toString(),
            phoneNumber: row['phone_number'].toString(),
            gestationalAgeWeeks: int.parse(row['gestational_age_weeks'].toString()),
            expectedDeliveryDate: row['expected_delivery_date'].toString(),
            registeredAt: DateTime.parse(row['registered_at'].toString()),
          ),
        )
        .toList();
  }

  Future<void> saveAntenatalVisit(AntenatalVisit visit) async {
    final db = await database;
    await db.insert('antenatal_visits', {
      'id': visit.id,
      'title': visit.title,
      'date': visit.date,
      'notes': visit.notes,
      'created_at': visit.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AntenatalVisit>> loadAntenatalVisits() async {
    final db = await database;
    final rows = await db.query('antenatal_visits', orderBy: 'date ASC');
    return rows
        .map(
          (row) => AntenatalVisit(
            id: row['id'].toString(),
            title: row['title'].toString(),
            date: row['date'].toString(),
            notes: row['notes'].toString(),
            createdAt: DateTime.parse(row['created_at'].toString()),
          ),
        )
        .toList();
  }

  Future<void> saveVaccinationRecord(VaccinationRecord record) async {
    final db = await database;
    await db.insert('vaccinations', {
      'id': record.id,
      'name': record.name,
      'due_date': record.dueDate,
      'completed': record.completed ? 1 : 0,
      'created_at': record.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VaccinationRecord>> loadVaccinationRecords() async {
    final db = await database;
    final rows = await db.query('vaccinations', orderBy: 'created_at DESC');
    return rows
        .map(
          (row) => VaccinationRecord(
            id: row['id'].toString(),
            name: row['name'].toString(),
            dueDate: row['due_date'].toString(),
            completed: (row['completed'] as int) == 1,
            createdAt: DateTime.parse(row['created_at'].toString()),
          ),
        )
        .toList();
  }

  Future<void> toggleVaccinationCompletion(String id) async {
    final db = await database;
    final rows = await db.query('vaccinations', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return;

    final record = rows.first;
    final completed = (record['completed'] as int) == 1;
    await db.update(
      'vaccinations',
      {'completed': completed ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('pregnant_women');
    await db.delete('users');
    await db.delete('antenatal_visits');
    await db.delete('vaccinations');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionEmailKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionEmailKey);
  }

  Future<void> _setSessionEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionEmailKey, email);
  }

  Future<String?> _getSessionEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionEmailKey);
  }
}
