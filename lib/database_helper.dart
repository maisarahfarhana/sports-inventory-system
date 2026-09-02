import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory factory;

    // Tetapkan factory mengikut platform (Web atau Mobile/Desktop)
    if (kIsWeb) {
      factory = databaseFactoryFfiWeb;
    } else {
      factory = databaseFactory;
    }

    String path = join(await factory.getDatabasesPath(), 'kpm_sports_v7.db');

    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Table Users
          await db.execute('''
            CREATE TABLE users(
              username TEXT PRIMARY KEY, 
              password TEXT, 
              role TEXT,
              email TEXT,
              staffId TEXT,
              studentId TEXT,
              course TEXT
            )
          ''');

          // Table Inventory
          await db.execute('''
            CREATE TABLE inventory(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              equipment_name TEXT,
              sport_type TEXT,
              quantity INTEGER,
              image_path TEXT
            )
          ''');

          // Table Bookings
          await db.execute('''
            CREATE TABLE bookings(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              sport TEXT,
              equipment_name TEXT,
              student_name TEXT,
              class_name TEXT,
              date TEXT,
              duration TEXT,
              status TEXT
            )
          ''');
        },
      ),
    );
  }

  // --- FUNGSI USER ---
  Future<void> registerUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> addEquipment(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('inventory', data);
  }

  Future<int> updateBooking(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'bookings',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil semua alatan untuk dipaparkan dalam senarai
  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    final db = await database;
    return await db.query('inventory', orderBy: 'equipment_name ASC');
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return maps.isNotEmpty;
  }

  // --- FUNGSI BOOKING (STUDENT & STAFF) ---

  // Simpan booking baru
  Future<int> addBooking(Map<String, dynamic> bookingData) async {
    final db = await database;
    return await db.insert('bookings', bookingData);
  }

  // Ambil booking untuk student tertentu sahaja
  Future<List<Map<String, dynamic>>> getStudentBookings(String username) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
  }

  // Staff: Ambil SEMUA booking dari semua student
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'id DESC');
  }

  // Staff/Student: Padam booking
  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }
}