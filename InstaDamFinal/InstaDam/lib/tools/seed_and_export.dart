import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/user.dart';
import '../services/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DbService();
  try {
    // insert users if missing
    final u1 = await db.getUserByUsername('derek');
    if (u1 == null) await db.insertUser(User(username: 'derek', password: 'admin'));
    final u2 = await db.getUserByUsername('pau');
    if (u2 == null) await db.insertUser(User(username: 'pau', password: 'admin'));

    // export to JSON in project root
    final outPath = 'insta_export.json';
    final json = await db.exportDatabaseToJson(outputFilePath: outPath, pretty: true);
    debugPrint('Exported DB to $outPath (${json.length} bytes)');
    // also print users for quick check
    final users = await (await db.database).query('users');
    for (final r in users) debugPrint('user: ${r['username']}');
  } catch (e) {
    debugPrint('Error: $e');
  } finally {
    await db.close();
  }
}
