class Post {
  final int? id;
  final int userId;
  final String imagePath; // local path or asset placeholder
  final String description;
  final int createdAt; // epoch ms
  int likes;

  Post({this.id, required this.userId, required this.imagePath, required this.description, required this.createdAt, this.likes = 0});

  factory Post.fromMap(Map<String, dynamic> m) => Post(
        id: m['id'] as int?,
        userId: m['userId'] as int,
        imagePath: m['imagePath'] as String,
        description: m['description'] as String,
        createdAt: m['createdAt'] as int,
        likes: m['likes'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'userId': userId,
        'imagePath': imagePath,
        'description': description,
        'createdAt': createdAt,
        'likes': likes,
      };
}
