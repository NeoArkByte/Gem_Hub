import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_market/core/enums/gem_type.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

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
    String path = join(await getDatabasesPath(), 'gemcost_inventory_v12_secure.db');
    final password = await _getEncryptionKey();

    return await openDatabase(
      path,
      password: password,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Gem Varieties Table
    await db.execute('''
      CREATE TABLE gem_varieties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL
      )
    ''');

    // 2. Main Inventory Table
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

    // 3. Seed Varieties
    for (var type in GemType.values) {
      await db.insert('gem_varieties', {
        'name': type.name,
        'display_name': type.displayName,
      });
    }
  }

  // --- VARIETY FUNCTIONS ---
  Future<List<String>> getGemVarieties() async {
  final db = await database;
  
  final List<Map<String, dynamic>> maps = await db.query(
    'gem_varieties', 
    columns: ['display_name'],
    orderBy: 'id ASC'
  );

  return maps.map((row) => row['display_name'] as String).toList();
}

  // --- INVENTORY FUNCTIONS ---
  Future<int> insertGemstone(Map<String, dynamic> gemstone) async {
    final db = await database;
    return await db.insert('gemstones', gemstone);
  }

  Future<List<Map<String, dynamic>>> getAllGemstones() async {
    final db = await database;
    return await db.query('gemstones', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getUnsoldGemstones() async {
    final db = await database;
    return await db.query('gemstones', where: 'is_sold = 0', orderBy: 'id DESC');
  }


  // --- SECURITY UTILITY ---
  Future<void> hexDumpHeader() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gemcost_inventory_v12_secure.db');
    final file = File(path);

    if (await file.exists()) {
      final bytes = await file.openRead(0, 16).first;
      final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      print("🛡️ FILE HEADER (HEX): $hexString");
    }
  }
}