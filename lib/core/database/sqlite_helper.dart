import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gem_jobs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE users (
      id $idType,
      name $textType,
      role $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE jobs (
      id $idType,
      title $textType,
      description $textType,
      posted_by $intType,
      status $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE applications (
      id $idType,
      job_id $intType,
      applicant_id $intType,
      status $textType
    )
    ''');

    await db.rawInsert(
      'INSERT INTO users(name, role) VALUES("Admin Tester", "admin")',
    );
    await db.rawInsert(
      'INSERT INTO users(name, role) VALUES("Normal Miner", "user")',
    );
  }

  Future<int> insertJob(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('jobs', row);
  }

  Future<List<Map<String, dynamic>>> getOpenJobs() async {
    final db = await instance.database;
    return await db.query('jobs', where: 'status = ?', whereArgs: ['Open']);
  }

  Future<int> applyForJob(int jobId, int applicantId) async {
    final db = await instance.database;
    return await db.insert('applications', {
      'job_id': jobId,
      'applicant_id': applicantId,
      'status': 'Pending',
    });
  }

  Future<int> updateApplicationStatus(
    int applicationId,
    String newStatus,
  ) async {
    final db = await instance.database;
    return await db.update(
      'applications',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [applicationId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
