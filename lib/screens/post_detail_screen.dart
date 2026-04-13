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

  String _formatRelativeTime(BuildContext context, int createdAtMs) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
    if (diff.inMinutes < 1) return tr(context, 'time_now');
    if (diff.inHours < 1) {
      return tr(context, 'time_minutes_ago', {'n': '${diff.inMinutes}'});
    }
    if (diff.inDays < 1) {
      return tr(context, 'time_hours_ago', {'n': '${diff.inHours}'});
    }
    return tr(context, 'time_days_ago', {'n': '${diff.inDays}'});
  }

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
    final comment = Comment(
      postId: widget.post.id ?? 0,
      username: username,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await prov.addComment(comment);
    _ctrl.clear();
    if (!mounted) return;
    final total = prov.commentsForPost(widget.post.id ?? 0).length;
    final message = tr(context, 'comment_added_with_count', {'n': '$total'});
    final direction = Directionality.of(context);
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, message, direction);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
    );
  }

  Future<void> _toggleLikeWithFeedback(bool isLiked) async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    if (prov.currentUser == null) {
      final message = tr(context, 'like_requires_login');
      final direction = Directionality.of(context);
      final view = View.of(context);
      SemanticsService.sendAnnouncement(view, message, direction);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
      );
      return;
    }

    await prov.toggleLike(widget.post);
    if (!mounted) return;
    final message = tr(
      context,
      isLiked ? 'unliked_announcement' : 'liked_announcement',
      {'n': '${widget.post.likes}'},
    );
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
    final isLiked = prov.isLikedByMe(widget.post.id ?? 0);
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
                    label: tr(context, 'post_detail_summary', {
                      'description': widget.post.description,
                      'likes': '${widget.post.likes}',
                      'comments': '${comments.length}',
                    }),
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.description),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                tr(context, 'likes', {
                                  'n': '${widget.post.likes}',
                                }),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Semantics(
                                button: true,
                                enabled: prov.currentUser != null,
                                toggled: isLiked,
                                label: isLiked
                                    ? tr(context, 'unlike_action')
                                    : tr(context, 'like_action'),
                                value: tr(context, 'likes', {
                                  'n': '${widget.post.likes}',
                                }),
                                hint: tr(context, 'like_hint'),
                                onTap: () => _toggleLikeWithFeedback(isLiked),
                                child: ExcludeSemantics(
                                  child: IconButton(
                                    onPressed: () =>
                                        _toggleLikeWithFeedback(isLiked),
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    color: isLiked ? Colors.redAccent : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: comments.isEmpty
                      ? Semantics(
                          liveRegion: true,
                          label: tr(context, 'no_comments'),
                          child: Center(
                            child: Text(tr(context, 'no_comments')),
                          ),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (_, i) {
                            final comment = comments[i];
                            final timeText = _formatRelativeTime(
                              context,
                              comment.createdAt,
                            );
                            return MergeSemantics(
                              child: Semantics(
                                container: true,
                                label: tr(context, 'comment_item_semantics', {
                                  'user': comment.username,
                                  'text': comment.text,
                                  'time': timeText,
                                }),
                                child: ListTile(
                                  leading: ExcludeSemantics(
                                    child: CircleAvatar(
                                      child: Text(
                                        comment.username.isNotEmpty
                                            ? comment.username[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                  ),
                                  title: ExcludeSemantics(
                                    child: Text(comment.username),
                                  ),
                                  subtitle: ExcludeSemantics(
                                    child: Text(comment.text),
                                  ),
                                  trailing: ExcludeSemantics(
                                    child: Text(
                                      timeText,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Row(
                      children: [
                        Expanded(
                          child: FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ExcludeSemantics(
                                  child: Text(
                                    tr(context, 'comment_field_visible_label'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Semantics(
                                  textField: true,
                                  label: tr(context, 'comment_field_label'),
                                  hint: tr(context, 'add_comment_hint'),
                                  child: TextField(
                                    controller: _ctrl,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _addComment(),
                                    decoration: InputDecoration(
                                      hintText: tr(context, 'add_comment_hint'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(2),
                          child: Semantics(
                            button: true,
                            label: tr(context, 'send_comment_button'),
                            hint: tr(context, 'send_comment_hint'),
                            child: ExcludeSemantics(
                              child: IconButton(
                                onPressed: _addComment,
                                icon: const Icon(Icons.send),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
