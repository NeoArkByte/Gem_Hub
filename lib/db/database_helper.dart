import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Changed to v3 to force a fresh database creation without needing to uninstall
    String path = join(await getDatabasesPath(), 'gemcost_jobs_v3.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Aluth 'createdAt' column eka add kala
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        companyInfo TEXT,
        salary TEXT,
        tags TEXT,
        logoColor INTEGER,
        status TEXT,
        createdAt TEXT 
      )
    ''');

    await _insertDemoData(db);
  }

  Future<void> _insertDemoData(Database db) async {
    final now = DateTime.now();

    List<Map<String, dynamic>> demoJobs = [
      {
        'title': 'Inventory Manager',
        'companyInfo': 'Infinite Mines • London, UK',
        'salary': '\$75k - \$110k',
        'tags': 'FULL-TIME,REMOTE FRIENDLY',
        'logoColor': 0xFF143029,
        'status': 'approved',
        // Created 2 hours ago (Will show in Featured & Recent)
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': 'B2B Sales Executive',
        'companyInfo': 'Rare Stone Co • Dubai, UAE',
        'salary': '\$60k + Comm.',
        'tags': 'CONTRACT,ON-SITE',
        'logoColor': 0xFFE2CFA7,
        'status': 'approved',
        // Created 26 hours ago (Will NOT show in Featured, only in Recent)
        'createdAt': now.subtract(const Duration(hours: 26)).toIso8601String(),
      },
      {
        'title': 'Custom Gem Polisher',
        'companyInfo': 'Emerald Precision • Jaipur, India',
        'salary': '\$45 - \$60 /hr',
        'tags': 'PART-TIME',
        'logoColor': 0xFF335C48,
        'status': 'approved',
        // Created 5 hours ago (Will show in Featured & Recent)
        'createdAt': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    for (var job in demoJobs) {
      await db.insert('jobs', job);
    }
  }

  // --- INSERT NEW JOB (User daddi wada karana eka) ---
  Future<int> insertJob(Map<String, dynamic> job) async {
    final db = await database;

    // User dapu map eke 'createdAt' nathnam, auto dan welawa add karanawa
    if (!job.containsKey('createdAt')) {
      job['createdAt'] = DateTime.now().toIso8601String();
    }

    return await db.insert('jobs', job);
  }

  // --- UPDATE JOB STATUS (Admin side eke Accept/Reject karaddi) ---
  Future<int> updateJobStatus(int id, String status) async {
    final db = await database;

    // Status eka update karaddi createdAt time ekath ewelema apahu aluth karanawa,
    // ethakota admin accept karapu wele idan paya 24k count wenne!
    return await db.update(
      'jobs',
      {'status': status, 'createdAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- FETCH RECENT APPROVED JOBS (User ge main screen pallen penna) ---
  Future<List<Map<String, dynamic>>> getApprovedJobs() async {
    final db = await database;
    return await db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: ['approved'],
      orderBy: 'id DESC',
    );
  }

  // --- FETCH PENDING JOBS (Admin side eke penna) ---
  Future<List<Map<String, dynamic>>> getPendingJobs() async {
    final db = await database;
    return await db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id DESC',
    );
  }

  // --- FETCH FEATURED JOBS (User ge main screen eke udin penna - Paya 24 logic) ---
  Future<List<Map<String, dynamic>>> getFeaturedJobs() async {
    final db = await database;

    // Dan welawen paya 24kata kalin welawa hadagannawa
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
}
