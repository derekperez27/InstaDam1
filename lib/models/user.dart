class User {
  final int? id;
  final String username;
  final String password; // simple for demo
  final String? avatarPath;

  User({this.id, required this.username, required this.password, this.avatarPath});

  factory User.fromMap(Map<String, dynamic> m) => User(
        id: m['id'] as int?,
        username: m['username'] as String,
        password: m['password'] as String,
        avatarPath: m['avatarPath'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'password': password,
        'avatarPath': avatarPath,
      };
}
