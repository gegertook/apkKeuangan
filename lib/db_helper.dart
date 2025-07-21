import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'keuanganku.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE transaksi(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            category TEXT,
            name TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  static Future<void> insertTransaksi(Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    await db.insert('transaksi', data);
  }

  static Future<List<Map<String, dynamic>>> getTransaksi() async {
    final db = await DBHelper.database();
    return db.query('transaksi', orderBy: 'date DESC');
  }
}
