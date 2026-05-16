// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/batch_model.dart';
import '../models/booking_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'janki_agro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async {
        await _seedData(db);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Batches table
    await db.execute('''
      CREATE TABLE batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        capacity INTEGER DEFAULT 50,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        booking_date TEXT NOT NULL,
        batch_id INTEGER NOT NULL,
        batch_name TEXT NOT NULL,
        manager_id INTEGER NOT NULL,
        manager_name TEXT NOT NULL,
        guest_count INTEGER DEFAULT 1,
        notes TEXT,
        status TEXT DEFAULT 'confirmed',
        created_at TEXT NOT NULL,
        FOREIGN KEY (batch_id) REFERENCES batches (id),
        FOREIGN KEY (manager_id) REFERENCES users (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Check if admin exists
    var existing = await db.query('users', where: 'username = ?', whereArgs: ['admin']);
    if (existing.isEmpty) {
      // Insert default admin
      await db.insert('users', {
        'name': 'Admin',
        'username': 'admin',
        'password_hash': _hashPassword('admin123'),
        'role': 'admin',
        'phone': '',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Check if batches exist
    var batches = await db.query('batches');
    if (batches.isEmpty) {
      await db.insert('batches', {'name': 'Morning Batch', 'start_time': '9:00 AM', 'end_time': '2:00 PM', 'capacity': 50, 'is_active': 1});
      await db.insert('batches', {'name': 'Afternoon Batch', 'start_time': '3:00 PM', 'end_time': '8:00 PM', 'capacity': 50, 'is_active': 1});
      await db.insert('batches', {'name': 'Full Day Batch', 'start_time': '10:00 AM', 'end_time': '5:00 PM', 'capacity': 30, 'is_active': 1});
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ===================== AUTH =====================

  Future<UserModel?> login(String username, String password) async {
    final db = await database;
    String hash = _hashPassword(password);
    var results = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hash],
    );
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  // ===================== USERS =====================

  Future<List<UserModel>> getManagers() async {
    final db = await database;
    var results = await db.query('users', where: 'role = ?', whereArgs: ['manager'], orderBy: 'name ASC');
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    var results = await db.query('users', orderBy: 'role DESC, name ASC');
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<int> addUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap()..remove('id'));
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> usernameExists(String username, {int? excludeId}) async {
    final db = await database;
    var q = excludeId != null
        ? await db.query('users', where: 'username = ? AND id != ?', whereArgs: [username, excludeId])
        : await db.query('users', where: 'username = ?', whereArgs: [username]);
    return q.isNotEmpty;
  }

  String hashPassword(String password) => _hashPassword(password);

  // ===================== BATCHES =====================

  Future<List<BatchModel>> getBatches({bool activeOnly = false}) async {
    final db = await database;
    var results = activeOnly
        ? await db.query('batches', where: 'is_active = 1', orderBy: 'id ASC')
        : await db.query('batches', orderBy: 'id ASC');
    return results.map((m) => BatchModel.fromMap(m)).toList();
  }

  Future<int> addBatch(BatchModel batch) async {
    final db = await database;
    return await db.insert('batches', batch.toMap()..remove('id'));
  }

  Future<int> updateBatch(BatchModel batch) async {
    final db = await database;
    return await db.update('batches', batch.toMap(), where: 'id = ?', whereArgs: [batch.id]);
  }

  Future<int> deleteBatch(int id) async {
    final db = await database;
    return await db.delete('batches', where: 'id = ?', whereArgs: [id]);
  }

  // ===================== BOOKINGS =====================

  Future<List<BookingModel>> getBookingsByDate(DateTime date) async {
    final db = await database;
    String dateStr = date.toIso8601String().split('T')[0];
    var results = await db.query(
      'bookings',
      where: 'booking_date = ?',
      whereArgs: [dateStr],
      orderBy: 'batch_id ASC, created_at ASC',
    );
    return results.map((m) => BookingModel.fromMap(m)).toList();
  }

  Future<List<BookingModel>> getBookingsByDateAndManager(DateTime date, int managerId) async {
    final db = await database;
    String dateStr = date.toIso8601String().split('T')[0];
    var results = await db.query(
      'bookings',
      where: 'booking_date = ? AND manager_id = ?',
      whereArgs: [dateStr, managerId],
      orderBy: 'batch_id ASC, created_at ASC',
    );
    return results.map((m) => BookingModel.fromMap(m)).toList();
  }

  Future<Map<int, int>> getBookingCountByBatch(DateTime date) async {
    final db = await database;
    String dateStr = date.toIso8601String().split('T')[0];
    var results = await db.rawQuery(
      'SELECT batch_id, COUNT(*) as count FROM bookings WHERE booking_date = ? AND status != "cancelled" GROUP BY batch_id',
      [dateStr],
    );
    Map<int, int> counts = {};
    for (var r in results) {
      counts[r['batch_id'] as int] = r['count'] as int;
    }
    return counts;
  }

  Future<Map<int, int>> getBookingCountByBatchAndManager(DateTime date, int managerId) async {
    final db = await database;
    String dateStr = date.toIso8601String().split('T')[0];
    var results = await db.rawQuery(
      'SELECT batch_id, COUNT(*) as count FROM bookings WHERE booking_date = ? AND manager_id = ? AND status != "cancelled" GROUP BY batch_id',
      [dateStr, managerId],
    );
    Map<int, int> counts = {};
    for (var r in results) {
      counts[r['batch_id'] as int] = r['count'] as int;
    }
    return counts;
  }

  Future<int> addBooking(BookingModel booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap()..remove('id'));
  }

  Future<int> updateBooking(BookingModel booking) async {
    final db = await database;
    return await db.update('bookings', booking.toMap(), where: 'id = ?', whereArgs: [booking.id]);
  }

  Future<int> cancelBooking(int id) async {
    final db = await database;
    return await db.update('bookings', {'status': 'cancelled'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BookingModel>> getAllBookings() async {
    final db = await database;
    var results = await db.query('bookings', orderBy: 'booking_date DESC, created_at DESC');
    return results.map((m) => BookingModel.fromMap(m)).toList();
  }

  // Stats
  Future<Map<String, int>> getDashboardStats() async {
    final db = await database;
    String today = DateTime.now().toIso8601String().split('T')[0];
    var todayCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM bookings WHERE booking_date = ? AND status != "cancelled"', [today])) ?? 0;
    var totalCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM bookings WHERE status != "cancelled"')) ?? 0;
    var managerCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM users WHERE role = "manager"')) ?? 0;
    return {
      'today': todayCount,
      'total': totalCount,
      'managers': managerCount,
    };
  }
}
