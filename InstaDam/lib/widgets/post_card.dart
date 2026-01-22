import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../screens/post_detail_screen.dart';
import '../services/db_service.dart';
import '../utils/loc.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    Widget imageWidget() {
      if (post.imagePath.isNotEmpty && File(post.imagePath).existsSync()) {
        return Image.file(File(post.imagePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      }
      return const Center(child: Icon(Icons.image, size: 56, color: Colors.white24));
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
      },
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
                BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Image background (vertical / portrait feel)
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      color: const Color(0xFF111214),
                      child: imageWidget(),
                    ),
                  ),

                  // Top overlay: user and menu
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<User?>(
                          future: DbService().getUserById(post.userId),
                          builder: (context, snap) {
                            final user = snap.data;
                            final name = (user != null && user.username.isNotEmpty) ? user.username : 'User';
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.black45,
                                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          color: const Color(0xFF1A1A1C),
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (v) async {
                            if (v == 'delete') {
                              if (post.id == null) return;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(tr(context, 'delete_post') ?? 'Delete post'),
                                  content: Text(tr(context, 'delete_post_confirm') ?? 'Are you sure you want to delete this post?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(tr(context, 'cancel') ?? 'Cancel')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(tr(context, 'delete') ?? 'Delete')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await prov.deletePost(post.id!);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'post_deleted') ?? 'Post deleted')));
                              }
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (prov.currentUser?.id == post.userId)
                              PopupMenuItem(value: 'delete', child: Text(tr(context, 'delete') ?? 'Delete')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom gradient with caption and actions
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
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(post.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: prov.currentUser == null
                                        ? null
                                        : () async {
                                            await prov.toggleLike(post);
                                          },
                                    icon: Icon(
                                      prov.isLikedByMe(post.id ?? 0) ? Icons.favorite : Icons.favorite_border,
                                      color: prov.isLikedByMe(post.id ?? 0) ? Colors.redAccent : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${post.likes}', style: const TextStyle(color: Colors.white)),
                                  const SizedBox(width: 14),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.mode_comment_outlined, color: Colors.white)),
                                  const SizedBox(width: 6),
                                  Text('${prov.commentsForPost(post.id ?? 0).length}', style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.white)),
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
    );
  }
}
