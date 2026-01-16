import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);

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
}
