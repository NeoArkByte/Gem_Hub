import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Database eka open karana function eka
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'gem_jobs.db'),
      onCreate: (db, version) {
        // Table eka hadanakota status ekata 'pending' kiyala default value ekak dunna
        return db.execute(
          'CREATE TABLE jobs(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, location TEXT, description TEXT, status TEXT DEFAULT "pending")',
        );
      },
      version: 1,
    );
  }

  // 1. Aluth Job ekak SQLite ekata insert kireema
  static Future<void> insertJob(Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    await db.insert('jobs', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. Status eka anuwa Jobs fetch kireema (Pending hari Approved hari)
  static Future<List<Map<String, dynamic>>> getJobs(String status) async {
    final db = await DBHelper.database();
    return db.query(
      'jobs',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC', // Aluthma jobs udaata ena widiyata
    );
  }

  // 3. Admin ta job ekak approve kireema (Status update)
  static Future<void> approveJob(int id) async {
    final db = await DBHelper.database();
    await db.update(
      'jobs',
      {'status': 'approved'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 4. Demo data insert kireema (Test karanna lesi wenna)
  static Future<void> insertDemoData() async {
    final db = await DBHelper.database();

    // Table eka check karala data natham witarak insert karamu
    final List<Map<String, dynamic>> count = await db.rawQuery(
      'SELECT COUNT(*) as total FROM jobs',
    );

    if (count[0]['total'] == 0) {
      List<Map<String, dynamic>> demoJobs = [
        {
          'title': 'Professional Gem Cutter',
          'location': 'Ratnapura',
          'description': 'Looking for an expert with 5 years experience.',
          'status': 'pending',
        },
        {
          'title': 'Certified Gem Valuer',
          'location': 'Colombo 03',
          'description': 'High salary for the right candidate.',
          'status': 'approved',
        },
        {
          'title': 'Lapidary Assistant',
          'location': 'Beruwala',
          'description': 'Immediate vacancy for a trainee.',
          'status': 'pending',
        },
      ];

      for (var job in demoJobs) {
        await db.insert('jobs', job);
      }
      print("Demo data successfully added to SQLite!");
    }
  }
}
