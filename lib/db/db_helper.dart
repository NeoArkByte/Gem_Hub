import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(
        dbPath,
        'gem_jobs_v12.db',
      ), // Database එක අලුතින්ම හැදෙන්න Version එක වෙනස් කළා
      onCreate: (db, version) async {
        // 1. Users Table
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, role TEXT)',
        );
        // 2. Jobs Table (Status එක Default විදිහටම 'request' වෙනවා)
        await db.execute(
          'CREATE TABLE jobs(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, location TEXT, salary TEXT, description TEXT, status TEXT DEFAULT "request", reason TEXT)',
        );
        // 3. Applications Table
        await db.execute(
          'CREATE TABLE applications(id INTEGER PRIMARY KEY AUTOINCREMENT, jobId INTEGER, userName TEXT, cvPath TEXT, status TEXT DEFAULT "pending")',
        );

        // Default Admin ලොගින් එක
        await db.insert('users', {
          'username': 'admin',
          'password': '123',
          'role': 'admin',
        });
      },
      version: 1,
    );
  }

  // --- Login එක චෙක් කරන්න ---
  static Future<Map<String, dynamic>?> checkLogin(
    String user,
    String pass,
  ) async {
    final db = await DBHelper.database();
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // --- අලුත් Job එකක් ඇතුළත් කරන්න ---
  static Future<void> insertJob(Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    await db.insert('jobs', data);
  }

  // --- වැදගත්ම කොටස: Status එක අනුව Jobs ටික Filter කරලා ගන්න එක ---
  static Future<List<Map<String, dynamic>>> getJobsByStatus(
    String status,
  ) async {
    final db = await DBHelper.database();
    return db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
  }

  // --- Job එකක Status එක (Request -> Approved) මාරු කරන්න ---
  static Future<void> updateJobStatus(int id, String status) async {
    final db = await DBHelper.database();
    await db.update(
      'jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Job එකක් Delete කරන්න ---
  static Future<void> deleteJob(int id) async {
    final db = await DBHelper.database();
    await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  // --- Demo Data (Testing වලට) ---
  static Future<void> insertDemoData() async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> users = await db.query('users');
    if (users.isEmpty) {
      await db.insert('users', {
        'username': 'admin',
        'password': '123',
        'role': 'admin',
      });
      print("Admin User Added!");
    }
  }

  static Future<List<Map<String, dynamic>>> searchJobs(
    String title,
    String loc,
  ) async {
    final db = await DBHelper.database();
    String whereClause = "status = 'approved'";
    List<dynamic> args = [];

    // ජොබ් එකේ නම අනුව (Title)
    if (title.isNotEmpty) {
      whereClause += " AND title LIKE ?";
      args.add('%$title%');
    }

    // ලොකේෂන් එක අනුව (Location)
    if (loc.isNotEmpty && loc != "All Sri Lanka") {
      whereClause += " AND location LIKE ?";
      args.add('%$loc%');
    }

    return db.query('jobs', where: whereClause, whereArgs: args);
  }
}
