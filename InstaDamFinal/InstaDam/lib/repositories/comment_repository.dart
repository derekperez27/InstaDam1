import '../models/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getByPost(int postId);
  Future<int> insert(Comment c);
}

class InMemoryCommentRepository implements CommentRepository {
  final List<Comment> _comments = [];
  int _auto = 1;

  @override
  Future<int> insert(Comment c) async {
    final newC = Comment(id: _auto++, postId: c.postId, username: c.username, text: c.text, createdAt: c.createdAt);
    _comments.add(newC);
    return newC.id!;
  }

  @override
  Future<List<Comment>> getByPost(int postId) async => _comments.where((c) => c.postId == postId).toList();
}
