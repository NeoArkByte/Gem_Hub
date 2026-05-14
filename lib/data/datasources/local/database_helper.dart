import 'dart:convert';
import 'dart:math';
import 'dart:io'; // <--- This defines 'File'
import 'dart:typed_data';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  // Secure storage for the hardware-backed encryption key
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _keyName = 'gemcost_vault_key_v12';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Fetches the existing key or generates a cryptographically strong 256-bit key
  Future<String> _getEncryptionKey() async {
    String? key = await _storage.read(key: _keyName);
    if (key == null) {
      final randomBytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
      key = base64Url.encode(randomBytes);
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gemcost_jobs_v12_secure.db');
    final password = await _getEncryptionKey();

    return await openDatabase(
      path,
      password: password, // This activates SQLCipher AES-256 encryption
      version: 1,
      onConfigure: (db) async {
        // Essential: Enables foreign key constraints (Cascade Delete, etc.)
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // Gemstone Inventory Table
    await db.execute('''
      CREATE TABLE gemstones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT, 
        variety TEXT, 
        is_sold INTEGER DEFAULT 0,
        color TEXT,
        is_rough INTEGER, 
        is_cut INTEGER,
        buying_weight REAL, 
        buying_price REAL,
        treatment_cost REAL, 
        recut_cost REAL,
        other_processing_cost REAL, 
        other_processing_desc TEXT,
        final_weight REAL, 
        transport_cost REAL,
        other_cost REAL, 
        other_cost_reason TEXT,
        target_price REAL, 
        selling_price REAL,
        first_image_path TEXT, 
        final_image_path TEXT
      )
    ''');


}

Future<void> hexDumpHeader() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'gemcost_jobs_v12_secure.db');
  final file = File(path);

  if (await file.exists()) {
    final bytes = await file.openRead(0, 16).first;
    final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    final plainText = String.fromCharCodes(bytes.where((b) => b >= 32 && b <= 126));

    print("🛠️ FILE HEADER (HEX): $hexString");
    print("🛠️ FILE HEADER (TEXT): '$plainText'");

    if (plainText.contains("SQLite format 3")) {
      print("🚨 NOT ENCRYPTED: I can see the SQLite header!");
    } else {
      print("🛡️ VERIFIED ENCRYPTED: The header is scrambled gibberish.");
    }
  }
}

  // --- DASHBOARD ANALYTICS ---

  // Calculates Total Portfolio Value (Sum of all gem prices)
  Future<double> getTotalPortfolioValue(String userId) async {
    final db = await database;
    var result = await db.rawQuery(
      'SELECT SUM(price) as total FROM gems WHERE owner_id = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Calculates Monthly Profit (Dummy logic for now, using recent additions)
  Future<double> getMonthlyProfit(String userId) async {
    final db = await database;
    final firstDayOfMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      1,
    ).toIso8601String();

    var result = await db.rawQuery(
      'SELECT SUM(price) as monthly_total FROM gems WHERE owner_id = ? AND created_at >= ?',
      [userId, firstDayOfMonth],
    );
    return (result.first['monthly_total'] as num?)?.toDouble() ?? 0.0;
  }

  // --- GEM FUNCTIONS ---
  Future<int> insertGem(Map<String, dynamic> gem) async {
    final db = await database;
    if (!gem.containsKey('created_at')) {
      gem['created_at'] = DateTime.now().toIso8601String();
    }
    return await db.insert('gems', gem);
  }

  Future<List<Map<String, dynamic>>> getActiveGems() async {
    final db = await database;
    return await db.query(
      'gems',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchAndFilterGems(
    String keyword,
    String type,
  ) async {
    final db = await database;
    String query = "SELECT * FROM gems WHERE status = 'active'";
    List<dynamic> args = [];

    if (keyword.isNotEmpty) {
      query += " AND (LOWER(name) LIKE ? OR LOWER(origin) LIKE ?)";
      String searchLower = '%${keyword.toLowerCase()}%';
      args.addAll([searchLower, searchLower]);
    }

    if (type != 'All Gems') {
      query += " AND LOWER(type) = ?";
      args.add(type.toLowerCase());
    }

    query += " ORDER BY id DESC";
    return await db.rawQuery(query, args);
  }

}
