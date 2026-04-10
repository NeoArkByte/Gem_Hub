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
    // Aluth version ekak (v6) - Users table eka nisa
    String path = join(await getDatabasesPath(), 'gemcost_jobs_v6.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Jobs Table
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
        createdAt TEXT 
      )
    ''');

    // 2. Applications Table
    await db.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER,
        applicant_name TEXT,
        phone TEXT,
        expected_salary TEXT,
        cv_path TEXT, 
        status TEXT,
        appliedAt TEXT
      )
    ''');

    // 👇 3. ALUTH USERS TABLE EKA
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Notifications Table එක හදන කැබැල්ල
    await db.execute('''
  CREATE TABLE notifications(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,        -- කාටද මේක පෙන්වන්න ඕනි (Employer/User ID)
    title TEXT,
    message TEXT,
    time TEXT,
    is_read INTEGER DEFAULT 0 -- බැලුවද නැද්ද කියලා දැනගන්න (0=No, 1=Yes)
  )
''');

    await _insertDemoData(db);
  }

  Future<void> _insertDemoData(Database db) async {
    final now = DateTime.now();
    List<Map<String, dynamic>> demoJobs = [
      {
        'employer_id': 'EMP_001',
        'title': 'Inventory Manager',
        'companyInfo': 'Infinite Mines • London, UK',
        'salary': '\$75k - \$110k',
        'tags': 'FULL-TIME,REMOTE',
        'logoColor': 0xFF143029,
        'status': 'approved',
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];
    for (var job in demoJobs) {
      await db.insert('jobs', job);
    }
  }

  // 1. Notification එකක් Insert කරන Function එක
Future<int> addNotification(String userId, String title, String message) async {
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
  return await db.query('notifications', 
    where: 'user_id = ?', 
    whereArgs: [userId], 
    orderBy: 'id DESC');
}

  // --- JOB & APPLICATION FUNCTIONS ---
  Future<int> insertJob(Map<String, dynamic> job) async {
    final db = await database;
    if (!job.containsKey('createdAt'))
      job['createdAt'] = DateTime.now().toIso8601String();
    return await db.insert('jobs', job);
  }

  Future<int> submitApplication(Map<String, dynamic> application) async {
    final db = await database;
    if (!application.containsKey('appliedAt'))
      application['appliedAt'] = DateTime.now().toIso8601String();
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
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
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

  // 👇 ALUTH FUNCTION EKA: Search & Category Filter
  Future<List<Map<String, dynamic>>> searchAndFilterJobs(
    String keyword,
    String category,
  ) async {
    final db = await database;
    String query = "SELECT * FROM jobs WHERE status = 'approved'";
    List<dynamic> args = [];

    // 1. Keyword ekak thiyenawanam Title ekenui Company ekenui hoyanawa
    if (keyword.isNotEmpty) {
      query += " AND (title LIKE ? OR companyInfo LIKE ?)";
      args.addAll(['%$keyword%', '%$keyword%']);
    }

    // 2. Category ekak select karala nam eka tags walin hoyanawa
    if (category != 'All Jobs') {
      query += " AND tags LIKE ?";
      args.add('%$category%');
    }

    query += " ORDER BY id DESC";
    return await db.rawQuery(query, args);
  }
}
