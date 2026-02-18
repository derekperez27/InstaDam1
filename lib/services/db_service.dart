import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  Database? _db;

  DbService._internal();
  factory DbService() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('instadam.db');
    // ensure likes table exists for toggling per-user likes
    await _db!.execute('''
      CREATE TABLE IF NOT EXISTS likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        userId INTEGER,
        UNIQUE(postId, userId)
      )
    ''');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    // On desktop (Windows, Linux, macOS) initialize sqflite ffi and use
    // the ffi database factory. On mobile, use the default openDatabase.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      return await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        avatarPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        imagePath TEXT,
        description TEXT,
        createdAt INTEGER,
        likes INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        username TEXT,
        text TEXT,
        createdAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        userId INTEGER,
        UNIQUE(postId, userId)
      )
    ''');
  }

  // Users
  Future<int> insertUser(User u) async {
    final db = await database;
    return await db.insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Posts
  Future<int> insertPost(Post p) async {
    final db = await database;
    return await db.insert('posts', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final maps = await db.query('posts', orderBy: 'createdAt DESC');
    return maps.map((m) => Post.fromMap(m)).toList();
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final db = await database;
    final maps = await db.query('posts', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return maps.map((m) => Post.fromMap(m)).toList();
  }

  Future<int> updatePostLikes(int postId, int likes) async {
    final db = await database;
    return await db.update('posts', {'likes': likes}, where: 'id = ?', whereArgs: [postId]);
  }

  // Likes table operations
  Future<void> addLike(int userId, int postId) async {
    final db = await database;
    try {
      await db.insert('likes', {'postId': postId, 'userId': userId}, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {}
    // update aggregate
    final count = await getLikesCount(postId);
    await updatePostLikes(postId, count);
  }

  Future<void> removeLike(int userId, int postId) async {
    final db = await database;
    await db.delete('likes', where: 'postId = ? AND userId = ?', whereArgs: [postId, userId]);
    final count = await getLikesCount(postId);
    await updatePostLikes(postId, count);
  }

  Future<int> deletePost(int postId) async {
    final db = await database;
    // remove likes and comments referencing the post, then remove post
    await db.delete('likes', where: 'postId = ?', whereArgs: [postId]);
    await db.delete('comments', where: 'postId = ?', whereArgs: [postId]);
    return await db.delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  Future<int> getLikesCount(int postId) async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM likes WHERE postId = ?', [postId]);
    return (res.first['c'] as int?) ?? 0;
  }

  Future<bool> isLikedBy(int userId, int postId) async {
    final db = await database;
    final maps = await db.query('likes', where: 'postId = ? AND userId = ?', whereArgs: [postId, userId]);
    return maps.isNotEmpty;
  }

  // Comments
  Future<int> insertComment(Comment c) async {
    final db = await database;
    return await db.insert('comments', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Comment>> getCommentsByPost(int postId) async {
    final db = await database;
    final maps = await db.query('comments', where: 'postId = ?', whereArgs: [postId], orderBy: 'createdAt ASC');
    return maps.map((m) => Comment.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  /// Ensure default users exist in the database.
  Future<void> seedDefaultUsers() async {
    final existingDerek = await getUserByUsername('derek');
    if (existingDerek == null) {
      await insertUser(User(username: 'derek', password: 'admin'));
    }

    final existingPau = await getUserByUsername('pau');
    if (existingPau == null) {
      await insertUser(User(username: 'pau', password: 'admin'));
    }
  }

  /// Export the whole database (users, posts, comments) to a JSON string.
  /// If [outputFilePath] is provided, the JSON will be written to that path.
  Future<String> exportDatabaseToJson({String? outputFilePath, bool pretty = true}) async {
    final db = await database;
    final users = await db.query('users');
    final posts = await db.query('posts');
    final comments = await db.query('comments');

    final data = {
      'users': users,
      'posts': posts,
      'comments': comments,
      'likes': await db.query('likes'),
    };

    final encoder = pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    final jsonStr = encoder.convert(data);

    if (outputFilePath != null) {
      final f = File(outputFilePath);
      await f.writeAsString(jsonStr);
    }

    return jsonStr;
  }

  /// Import database content from a JSON string. If [replaceExisting] is true,
  /// existing tables will be cleared before inserting.
  Future<void> importDatabaseFromJson(String json, {bool replaceExisting = true}) async {
    final db = await database;
    final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;

    final users = (data['users'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final posts = (data['posts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final comments = (data['comments'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    await db.transaction((txn) async {
      if (replaceExisting) {
        await txn.delete('comments');
        await txn.delete('posts');
        await txn.delete('users');
      }

      for (final u in users) {
        final map = Map<String, Object?>.from(u);
        // remove id to let autoincrement assign or preserve if present
        await txn.insert('users', map, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final p in posts) {
        final map = Map<String, Object?>.from(p);
        await txn.insert('posts', map, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final c in comments) {
        final map = Map<String, Object?>.from(c);
        await txn.insert('comments', map, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
