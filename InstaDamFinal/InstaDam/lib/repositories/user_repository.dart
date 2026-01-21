import '../models/user.dart';

abstract class UserRepository {
  Future<User?> getById(int id);
  Future<User?> getByUsername(String username);
  Future<int> insert(User user);
}

/// Simple in-memory implementation for development.
class InMemoryUserRepository implements UserRepository {
  final List<User> _users = [];
  int _auto = 1;

  @override
  Future<User?> getById(int id) async {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> getByUsername(String username) async {
    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insert(User user) async {
    final newUser = User(id: _auto++, username: user.username, password: user.password, avatarPath: user.avatarPath);
    _users.add(newUser);
    return newUser.id!;
  }
}
