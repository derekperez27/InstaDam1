import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/storage_service.dart';
import '../services/db_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  User? _currentUser;
  User? get currentUser => _currentUser;
  
  String _language = 'en';
  String get language => _language;

  String? _profileName;
  String? get profileName => _profileName;
  
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  final StorageService _storage = StorageService();
  final DbService _db = DbService();

  List<Post> _posts = [];
  List<Post> get posts => _posts;
  Map<int, List<Comment>> _comments = {};
  List<Comment> commentsForPost(int postId) => _comments[postId] ?? [];
  Map<int, bool> _likedByMe = {};
  bool isLikedByMe(int postId) => _likedByMe[postId] ?? false;

  AppProvider() {
    // initialize from preferences
    _isDarkMode = _storage.getDarkMode();
    final name = _storage.getRememberedUser();
    if (name != null) {
      // resolve full user from DB if present
      () async {
        final u = await _db.getUserByUsername(name);
        if (u != null) {
          _currentUser = u;
        } else {
          _currentUser = User(id: null, username: name, password: '');
        }
        // after setting user, load posts so like states are loaded
        await loadPosts();
        notifyListeners();
      }();
    }
    // load language and profile
    _language = _storage.getLanguage();
    _profileName = _storage.getProfileName();
    _notificationsEnabled = _storage.getNotificationsEnabled();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _storage.setDarkMode(value);
      notifyListeners();
    }
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> rememberUser(bool remember) async {
    if (remember && _currentUser != null) {
      await _storage.setRememberedUser(_currentUser!.username);
    } else {
      await _storage.clearRememberedUser();
    }
  }

  Future<void> setLanguage(String code) async {
    _language = code;
    await _storage.setLanguage(code);
    notifyListeners();
  }

  Future<void> setProfileName(String name) async {
    _profileName = name;
    await _storage.setProfileName(name);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storage.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> loadPosts() async {
    try {
      _posts = await _db.getAllPosts();
      // load like state for current user
      if (_currentUser?.id != null) {
        for (final p in _posts) {
          final liked = await _db.isLikedBy(_currentUser!.id!, p.id ?? 0);
          _likedByMe[p.id ?? 0] = liked;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addPost(Post p) async {
    try {
      await _db.insertPost(p);
      await loadPosts();
    } catch (_) {}
  }

  Future<void> updatePostLikes(int postId, int likes) async {
    try {
      await _db.updatePostLikes(postId, likes);
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx].likes = likes;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleLike(Post post) async {
    if (_currentUser?.id == null) return;
    final userId = _currentUser!.id!;
    final postId = post.id ?? 0;
    final liked = await _db.isLikedBy(userId, postId);
    if (liked) {
      await _db.removeLike(userId, postId);
    } else {
      await _db.addLike(userId, postId);
    }
    final newCount = await _db.getLikesCount(postId);
    // update local post
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) _posts[idx].likes = newCount;
    _likedByMe[postId] = !liked;
    notifyListeners();
  }

  Future<void> loadComments(int postId) async {
    try {
      final dbComments = await _db.getCommentsByPost(postId);
      _comments[postId] = dbComments;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addComment(Comment c) async {
    try {
      await _db.insertComment(c);
      await loadComments(c.postId);
    } catch (_) {}
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.clearRememberedUser();
    notifyListeners();
  }
}
