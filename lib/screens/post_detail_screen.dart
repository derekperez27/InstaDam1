import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
    if (!mounted) return;
    final message = tr(context, 'comment_added');
    final direction = Directionality.of(context);
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, message, direction);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final comments = prov.commentsForPost(widget.post.id ?? 0);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'post'))),
      body: _loading
          ? Semantics(
              liveRegion: true,
              label: tr(context, 'loading_comments'),
              child: const Center(child: CircularProgressIndicator()),
            )
          : Column(
              children: [
                // post content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Semantics(
                    container: true,
                    label: tr(
                      context,
                      'post_detail_summary',
                      {
                        'description': widget.post.description,
                        'likes': '${widget.post.likes}',
                        'comments': '${comments.length}',
                      },
                    ),
                    child: ExcludeSemantics(
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
                  ),
                ),
                const Divider(),
                Expanded(
                  child: comments.isEmpty
                      ? Semantics(
                          liveRegion: true,
                          label: tr(context, 'no_comments'),
                          child: Center(child: Text(tr(context, 'no_comments'))),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (_, i) => Semantics(
                                label: tr(
                                  context,
                                  'comment_item_semantics',
                                  {
                                    'user': comments[i].username,
                                    'text': comments[i].text,
                                  },
                                ),
                                child: ExcludeSemantics(
                                  child: ListTile(
                                    title: Text(comments[i].username),
                                    subtitle: Text(comments[i].text),
                                  ),
                                ),
                              ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(
                      child: Semantics(
                        textField: true,
                        label: tr(context, 'comment_field_label'),
                        child: TextField(
                          controller: _ctrl,
                          decoration: InputDecoration(
                            hintText: tr(context, 'add_comment_hint'),
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: tr(context, 'send_comment_button'),
                      child: ExcludeSemantics(
                        child: IconButton(onPressed: _addComment, icon: const Icon(Icons.send)),
                      ),
                    )
                  ]),
                )
              ],
            ),
    );
  }
}
