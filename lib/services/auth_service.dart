import '../models/user.dart';
import 'db_service.dart';
import 'storage_service.dart';

class AuthService {
  final DbService _db = DbService();
  final StorageService _storage = StorageService();

  Future<User?> login(String username, String password, {bool remember = false}) async {
    final user = await _db.getUserByUsername(username);
    if (user != null && user.password == password) {
      if (remember) await _storage.setRememberedUser(username);
      return user;
    }
    return null;
  }

  Future<User?> register(String username, String password, {bool remember = false}) async {
    final existing = await _db.getUserByUsername(username);
    if (existing != null) return null; // already exists

    final id = await _db.insertUser(User(username: username, password: password));
    final newUser = User(id: id, username: username, password: password);
    if (remember) await _storage.setRememberedUser(username);
    return newUser;
  }

  Future<void> logout() async {
    await _storage.clearRememberedUser();
  }
}
