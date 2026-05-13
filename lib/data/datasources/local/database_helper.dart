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
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT,
        title TEXT,
        items_count INTEGER,
        rating REAL,
        sales_count TEXT,
        member_since TEXT
      )
    ''');

    // 2. Jobs Table
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employer_id TEXT, 
        title TEXT,
        companyInfo TEXT,
        salary TEXT,
        tags TEXT,
        logoColor INTEGER,
        status TEXT,
        createdAt TEXT,
        FOREIGN KEY (employer_id) REFERENCES users (username) ON DELETE CASCADE
      )
    ''');

    // 3. Applications Table
    await db.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER,
        applicant_name TEXT,
        phone TEXT,
        expected_salary TEXT,
        cv_path TEXT, 
        status TEXT,
        appliedAt TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');

    // 4. Notifications Table
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        title TEXT,
        message TEXT,
        time TEXT,
        is_read INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (username) ON DELETE CASCADE
      )
    ''');

    // 5. Gemstone Inventory Table
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

    // await _insertDemoData(db);
  

  // Future<void> _insertDemoData(Database db) async {
  //   await db.insert('users', {
  //     'name': 'David Sterling',
  //     'username': 'aka',
  //     'password': 'aka',
  //     'title': 'SENIOR GEMOLOGIST',
  //     'items_count': 142,
  //     'rating': 4.9,
  //     'sales_count': '12k',
  //     'member_since': 'August 2021',
  //   });
  // }
}

  // Future<void> _insertDemoData(Database db) async {
  //   final now = DateTime.now();

  //   // Demo Jobs
  //   List<Map<String, dynamic>> demoJobs = [
  //     {
  //       'employer_id': 'USER_001',
  //       'title': 'Inventory Manager',
  //       'companyInfo': 'Infinite Mines • London, UK',
  //       'salary': '\$75k - \$110k',
  //       'tags': 'FULL-TIME,REMOTE',
  //       'logoColor': 0xFF143029,
  //       'status': 'approved',
  //       'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
  //     },
  //   ];
  //   for (var job in demoJobs) {
  //     await db.insert('jobs', job);
  //   }

  //   // Demo Gems
  //   List<Map<String, dynamic>> demoGems = [
  //     {
  //       'owner_id': 'USER_001',
  //       'name': 'Royal Blue Sapphire',
  //       'type': 'Sapphire',
  //       'carat': 4.5,
  //       'price': 12500.0,
  //       'description': 'Beautiful sapphire with high clarity',
  //       'color': 'Blue',
  //       'origin': 'Ceylon',
  //       'location': 'Mayfair, London, UK',
  //       'image_url':
  //           'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000',
  //       'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  //       'seller_phone': '+94771234567',
  //       'status': 'active',
  //       'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
  //     },
  //     {
  //       'owner_id': 'USER_002',
  //       'name': 'Pigeon Blood Ruby',
  //       'type': 'Ruby',
  //       'carat': 2.1,
  //       'price': 8900.0,
  //       'description': 'Beautiful ruby with high clarity',
  //       'color': 'Red',
  //       'origin': 'Burma',
  //       'image_url':
  //           'https://images.unsplash.com/photo-1615111784767-4d7c307dc2bc?q=80&w=1000',
  //       'seller_phone': '+94779876543',
  //       'status': 'active',
  //       'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
  //     },
  //   ];
  //   for (var gem in demoGems) {
  //     await db.insert('gems', gem);
  //   }
  // }

  Future<Map<String, dynamic>?> getUserData(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isNotEmpty) {
      return results.first; // Returns the specific user found
    }
    return null;
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

  // 1. Notification එකක් Insert කරන Function එක
  Future<int> addNotification(
    String userId,
    String title,
    String message,
  ) async {
    final db = await database;
    return await db.insert('notifications', {
      'user_id': userId,
      'title': title,
      'message': message,
      'time': DateTime.now().toString(),
    });
  }

  // 2. ඒ ඒ User ට අදාළ Notifications ටික විතරක් ගන්න Function එක
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // --- JOB & APPLICATION FUNCTIONS ---
  Future<int> insertJob(Map<String, dynamic> job) async {
    final db = await database;
    if (!job.containsKey('createdAt')) {
      job['createdAt'] = DateTime.now().toIso8601String();
    }
    return await db.insert('jobs', job);
  }

  Future<int> submitApplication(Map<String, dynamic> application) async {
    final db = await database;
    if (!application.containsKey('appliedAt')) {
      application['appliedAt'] = DateTime.now().toIso8601String();
    }
    return await db.insert('applications', application);
  }

  Future<List<Map<String, dynamic>>> getApprovedJobs() async {
    final db = await database;
    return await db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: ['approved'],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingJobs() async {
    final db = await database;
    return await db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateJobStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getReceivedApplications(
    String employerId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT a.*, j.title as job_title 
      FROM applications a 
      INNER JOIN jobs j ON a.job_id = j.id
      WHERE j.employer_id = ?
      ORDER BY a.id DESC
    ''',
      [employerId],
    );
  }

  // 👇 --- ALUTH USER (LOGIN/SIGN UP) FUNCTIONS --- 👇
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // 👇 MEKA THAMAI MISSING WELA THIBBE
  Future<List<Map<String, dynamic>>> getFeaturedJobs() async {
    final db = await database;
    // Pahu giya paya 24 athulatha dapu 'approved' jobs witharak gannawa
    final twentyFourHoursAgo = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toIso8601String();
    return await db.query(
      'jobs',
      where: 'status = ? AND createdAt >= ?',
      whereArgs: ['approved', twentyFourHoursAgo],
      orderBy: 'id DESC',
    );
  }

  /// 👇 ALUTH FUNCTION EKA: Search & Category Filter (100% Case-Insensitive)
  Future<List<Map<String, dynamic>>> searchAndFilterJobs(
    String keyword,
    String category,
  ) async {
    final db = await database;
    String query = "SELECT * FROM jobs WHERE status = 'approved'";
    List<dynamic> args = [];

    // 1. Keyword eka thiyenawanam (LOWER dala case-insensitive kara)
    if (keyword.isNotEmpty) {
      query += " AND (LOWER(title) LIKE ? OR LOWER(companyInfo) LIKE ?)";
      // User type karapu ekath simple letters karanawa
      String searchLower = '%${keyword.toLowerCase()}%';
      args.addAll([searchLower, searchLower]);
    }

    // 2. Category eka thiyenawanam (LOWER dala case-insensitive kara)
    if (category != 'All Jobs') {
      query += " AND LOWER(tags) LIKE ?";
      // Category ekath simple letters karanawa
      args.add('%${category.toLowerCase()}%');
    }

    query += " ORDER BY id DESC";
    return await db.rawQuery(query, args);
  }

  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return users.isNotEmpty ? users.first : null;
  }
}
