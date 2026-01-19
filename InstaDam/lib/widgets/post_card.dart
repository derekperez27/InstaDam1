import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/app_provider.dart';
import '../screens/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image placeholder or file
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[200],
                child: post.imagePath.isNotEmpty && File(post.imagePath).existsSync()
                    ? Image.file(File(post.imagePath), fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Text(post.description),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${post.likes} likes'),
                  Row(
                    children: [
                      IconButton(
                          onPressed: prov.currentUser == null
                              ? null
                              : () async {
                                  await prov.toggleLike(post);
                                },
                          icon: Icon(prov.isLikedByMe(post.id ?? 0) ? Icons.thumb_up : Icons.thumb_up_alt_outlined)),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
