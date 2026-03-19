import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../screens/post_detail_screen.dart';
import '../services/db_service.dart';
import '../utils/loc.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

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
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    Future<void> openDetails() async {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
      );
    }

    Future<void> toggleLikeWithFeedback(bool isLiked) async {
      if (prov.currentUser == null) {
        final message = tr(context, 'like_requires_login');
        final direction = Directionality.of(context);
        final view = View.of(context);
        SemanticsService.sendAnnouncement(view, message, direction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Semantics(liveRegion: true, child: Text(message)),
          ),
        );
        return;
      }

      await prov.toggleLike(post);
      if (!context.mounted) return;
      final message = tr(
        context,
        isLiked ? 'unliked_announcement' : 'liked_announcement',
        {'n': '${post.likes}'},
      );
      final direction = Directionality.of(context);
      final view = View.of(context);
      SemanticsService.sendAnnouncement(view, message, direction);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(liveRegion: true, child: Text(message)),
        ),
      );
    }

    return FutureBuilder<User?>(
      future: DbService().getUserById(post.userId),
      builder: (context, snap) {
        final user = snap.data;
        final name = (user != null && user.username.isNotEmpty)
            ? user.username
            : tr(context, 'unknown_user');
        final timeText = _formatRelativeTime(context, post.createdAt);
        final commentsCount = prov.commentsForPost(post.id ?? 0).length;
        final isLiked = prov.isLikedByMe(post.id ?? 0);
        final imageLabel = post.description.trim().isEmpty
            ? tr(context, 'post_image_no_description')
            : tr(context, 'post_image_description', {'desc': post.description});
        final summary = tr(
          context,
          'post_summary',
          {
            'author': name,
            'time': timeText,
            'description': post.description.trim().isEmpty
                ? tr(context, 'no_description')
                : post.description,
            'likes': '${post.likes}',
            'comments': '$commentsCount',
          },
        );

        return MergeSemantics(
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: summary,
            hint: tr(context, 'open_post_details'),
            onTap: openDetails,
            child: GestureDetector(
              onTap: openDetails,
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0B0D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.45 * 255).round()),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Container(
                              color: const Color(0xFF111214),
                              child: Semantics(
                                image: true,
                                label: imageLabel,
                                child: post.imagePath.isNotEmpty &&
                                        File(post.imagePath).existsSync()
                                    ? ExcludeSemantics(
                                        child: Image.file(
                                          File(post.imagePath),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      )
                                    : ExcludeSemantics(
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 56,
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ExcludeSemantics(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.black45,
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            timeText,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: tr(context, 'post_options'),
                                  child: ExcludeSemantics(
                                    child: PopupMenuButton<String>(
                                      color: const Color(0xFF1A1A1C),
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      onSelected: (v) async {
                                        if (v == 'delete') {
                                          if (post.id == null) return;
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title:
                                                  Text(tr(ctx, 'delete_post')),
                                              content: Text(
                                                tr(ctx, 'delete_post_confirm'),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: Text(
                                                    tr(ctx, 'cancel'),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(true),
                                                  child:
                                                      Text(tr(ctx, 'delete')),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await prov.deletePost(post.id!);
                                            if (!context.mounted) return;
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Semantics(
                                                  liveRegion: true,
                                                  child: Text(
                                                    tr(context, 'post_deleted'),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        if (prov.currentUser?.id == post.userId)
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(tr(ctx, 'delete')),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha((0.6 * 255).round()),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ExcludeSemantics(
                                    child: Text(
                                      post.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Semantics(
                                            button: true,
                                            enabled: prov.currentUser != null,
                                            toggled: isLiked,
                                            label: isLiked
                                                ? tr(context, 'unlike_action')
                                                : tr(context, 'like_action'),
                                            value: tr(
                                              context,
                                              'likes',
                                              {'n': '${post.likes}'},
                                            ),
                                            hint: tr(context, 'like_hint'),
                                            onTap: () =>
                                                toggleLikeWithFeedback(isLiked),
                                            child: ExcludeSemantics(
                                              child: IconButton(
                                                onPressed: () =>
                                                    toggleLikeWithFeedback(
                                                  isLiked,
                                                ),
                                                icon: Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isLiked
                                                      ? Colors.redAccent
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          ExcludeSemantics(
                                            child: Text(
                                              '${post.likes}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Semantics(
                                            button: true,
                                            label: tr(
                                              context,
                                              'comments_count_button',
                                              {'n': '$commentsCount'},
                                            ),
                                            hint: tr(context, 'open_comments'),
                                            onTap: openDetails,
                                            child: ExcludeSemantics(
                                              child: IconButton(
                                                onPressed: openDetails,
                                                icon: const Icon(
                                                  Icons.mode_comment_outlined,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          ExcludeSemantics(
                                            child: Text(
                                              '$commentsCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ExcludeSemantics(
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.bookmark_border,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
