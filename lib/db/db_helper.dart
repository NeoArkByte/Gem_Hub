import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'gem_jobs.db'),
      onCreate: (db, version) {
        // Table eka hadanakota 'reason' kiyala aluth column ekak damma
        return db.execute(
          'CREATE TABLE jobs(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, location TEXT, description TEXT, status TEXT DEFAULT "pending", reason TEXT)',
        );
      },
      version: 1,
    );
  }

  // 1. Job ekak insert kireema
  static Future<void> insertJob(Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    await db.insert('jobs', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. Status eka anuwa jobs fetch kireema
  static Future<List<Map<String, dynamic>>> getJobs(String status) async {
    final db = await DBHelper.database();
    return db.query(
      'jobs', 
      where: 'status = ?', 
      whereArgs: [status],
      orderBy: 'id DESC'
    );
  }

  // 3. Job ekak Approve kireema
  static Future<void> approveJob(int id) async {
    final db = await DBHelper.database();
    await db.update(
      'jobs', 
      {'status': 'approved', 'reason': ''}, // Approve weddi reason eka empty karanawa
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // 4. Job ekak Reject kireema (Reason ekath ekka)
  static Future<void> rejectJob(int id, String reason) async {
    final db = await DBHelper.database();
    await db.update(
      'jobs', 
      {'status': 'rejected', 'reason': reason}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // 5. Test karanna Demo Data tikak (Update kala)
  static Future<void> insertDemoData() async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> count = await db.rawQuery('SELECT COUNT(*) as total FROM jobs');
    
    if (count[0]['total'] == 0) {
      List<Map<String, dynamic>> demoJobs = [
        {
          'title': 'Blue Sapphire Cutter',
          'location': 'Ratnapura',
          'description': 'Needs to have experience with heat-treated stones.',
          'status': 'pending',
          'reason': ''
        },
        {
          'title': 'Gem Auction Manager',
          'location': 'Colombo 07',
          'description': 'Managing high-value auctions.',
          'status': 'approved',
          'reason': ''
        },
        {
          'title': 'Invalid Listing Test',
          'location': 'Kandy',
          'description': 'This is a test for rejected status.',
          'status': 'rejected',
          'reason': 'Incorrect contact number provided.'
        },
      ];

      for (var job in demoJobs) {
        await db.insert('jobs', job);
      }
    }
  }
}