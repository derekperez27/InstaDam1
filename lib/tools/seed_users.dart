import 'dart:io';
import 'package:flutter/widgets.dart';

import '../models/user.dart';
import '../services/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DbService();
  final out = File('insta_seed_log.txt');
  try {
    final sink = out.openWrite();
    // Insert users if they don't already exist
    final u1 = await db.getUserByUsername('derek');
    if (u1 == null) {
      await db.insertUser(User(username: 'derek', password: 'admin'));
      sink.writeln('Inserted user derek');
    } else {
      sink.writeln('User derek already exists');
    }

    final u2 = await db.getUserByUsername('pau');
    if (u2 == null) {
      await db.insertUser(User(username: 'pau', password: 'admin'));
      sink.writeln('Inserted user pau');
    } else {
      sink.writeln('User pau already exists');
    }
    await sink.flush();
    await sink.close();
  } catch (e, st) {
    await out.writeAsString('Error seeding users: $e\n$st');
  } finally {
    await db.close();
  }
}
