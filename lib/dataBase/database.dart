import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBhelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'gem_inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          Create Table gems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          weight REAL,
          price REAL,
          category TEXT 
          )
        ''');

        List<String> defaultGems = [
          "Blue Sapphire",
          "Ruby",
          "Cat's Eye",
          "Topaz",
          "Amethyst",
          "Zircon",
          "Moonstone",
          "Garnet",
          "Tourmaline",
          "Alexandrite",
        ];

        for (var name in defaultGems) {
          await db.insert('gems', {
            'name': name,
            'weight': 1.5,
            'price': 25000.0,
            'category': 'Natural',
          });
        }
        print("Database created and 10 items added!");
      },
    );
  }

  static Future<List<Map<String, dynamic>>> queryAllGems() async {
    Database db = await database;
    return await db.query('gems');
  }

  static Future<int> insertGem(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('gems', row);
  }
}
