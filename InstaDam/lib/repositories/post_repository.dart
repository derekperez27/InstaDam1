import '../models/post.dart';

abstract class PostRepository {
  Future<List<Post>> getAll();
  Future<List<Post>> getByUser(int userId);
  Future<int> insert(Post post);
  Future<int> update(Post post);
  Future<int> delete(int id);
}

class InMemoryPostRepository implements PostRepository {
  final List<Post> _posts = [];
  int _auto = 1;

  @override
  Future<int> delete(int id) async {
    _posts.removeWhere((p) => p.id == id);
    return 1;
  }

  @override
  Future<List<Post>> getAll() async => List.unmodifiable(_posts);

  @override
  Future<List<Post>> getByUser(int userId) async => _posts.where((p) => p.userId == userId).toList();

  @override
  Future<int> insert(Post post) async {
    final newPost = Post(id: _auto++, userId: post.userId, imagePath: post.imagePath, description: post.description, createdAt: post.createdAt, likes: post.likes);
    _posts.insert(0, newPost);
    return newPost.id!;
  }

  @override
  Future<int> update(Post post) async {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx != -1) {
      _posts[idx] = post;
      return 1;
    }
    return 0;
  }
}
