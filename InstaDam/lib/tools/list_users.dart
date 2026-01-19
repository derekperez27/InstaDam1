import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:path_provider/path_provider.dart';

import '../services/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DbService();
  final outFile = File('insta_users.txt');
  try {
    final dir = await getApplicationDocumentsDirectory();
    final conn = await db.database;
    final rows = await conn.query('users');
    final sink = outFile.openWrite();
    sink.writeln('DB dir: ${dir.path}');
    if (rows.isEmpty) {
      sink.writeln('No users found');
    } else {
      for (final r in rows) {
        sink.writeln('user: ${r['username']} password: ${r['password']} id: ${r['id']}');
      }
    }
    await sink.flush();
    await sink.close();
  } catch (e) {
    await outFile.writeAsString('Error reading users: $e');
  } finally {
    await db.close();
  }
}
