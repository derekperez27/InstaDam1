import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/comment.dart';
import '../providers/app_provider.dart';
import '../utils/loc.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _ctrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    await prov.loadComments(widget.post.id ?? 0);
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final prov = Provider.of<AppProvider>(context, listen: false);
    final username = prov.currentUser?.username ?? 'anon';
    final comment = Comment(postId: widget.post.id ?? 0, username: username, text: text, createdAt: DateTime.now().millisecondsSinceEpoch);
    await prov.addComment(comment);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final comments = prov.commentsForPost(widget.post.id ?? 0);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'post'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // post content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.post.description),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(tr(context, 'likes', {'n': '${widget.post.likes}'}), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      IconButton(
                          onPressed: prov.currentUser == null
                              ? null
                              : () async {
                                  await prov.toggleLike(widget.post);
                                },
                          icon: Icon(prov.isLikedByMe(widget.post.id ?? 0) ? Icons.thumb_up : Icons.thumb_up_alt_outlined)),
                    ]),
                  ]),
                ),
                const Divider(),
                Expanded(
                  child: comments.isEmpty
                      ? Center(child: Text(tr(context, 'no_comments')))
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (_, i) => ListTile(
                                title: Text(comments[i].username),
                                subtitle: Text(comments[i].text),
                              ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Añadir comentario'))),
                    IconButton(onPressed: _addComment, icon: const Icon(Icons.send))
                  ]),
                )
              ],
            ),
    );
  }
}
