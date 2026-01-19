import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, 'instadam.db');
  debugPrint('Opening DB at $dbPath');

  final db = await databaseFactoryFfi.openDatabase(dbPath);
  try {
    // ensure table exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        avatarPath TEXT
      )
    ''');

    Future<void> ensureUser(String username, String password) async {
      final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
      if (maps.isEmpty) {
        await db.insert('users', {'username': username, 'password': password});
        debugPrint('Inserted $username');
      } else {
        debugPrint('$username already exists');
      }
    }

    await ensureUser('derek', 'admin');
    await ensureUser('pau', 'admin');

    final rows = await db.query('users');
    debugPrint('Users in DB:');
    for (final r in rows) {
      debugPrint(' - ${r['username']} (id=${r['id']})');
    }
  } catch (e) {
    debugPrint('Error: $e');
  } finally {
    await db.close();
  }
}
