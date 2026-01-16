class Comment {
  final int? id;
  final int postId;
  final String username;
  final String text;
  final int createdAt;

  Comment({this.id, required this.postId, required this.username, required this.text, required this.createdAt});

  factory Comment.fromMap(Map<String, dynamic> m) => Comment(
        id: m['id'] as int?,
        postId: m['postId'] as int,
        username: m['username'] as String,
        text: m['text'] as String,
        createdAt: m['createdAt'] as int,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'postId': postId,
        'username': username,
        'text': text,
        'createdAt': createdAt,
      };
}
