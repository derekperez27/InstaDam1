import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/app_provider.dart';
import '../screens/post_detail_screen.dart';
import '../utils/loc.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<AppProvider>(context, listen: false);
    _ctrl.text = prov.profileName ?? '';
    if (prov.posts.isEmpty) {
      prov.loadPosts();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save({String? avatarPath}) async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    await prov.setProfileName(_ctrl.text.trim());
    if (avatarPath != null && avatarPath.trim().isNotEmpty) {
      await prov.setCurrentUserAvatar(avatarPath);
    }
  }

  Future<String?> _pickAvatarPath() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !mounted) return path;
    final message = tr(context, 'profile_photo_selected');
    final direction = Directionality.of(context);
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, message, direction);
    return path;
  }

  Future<void> _openEditProfileDialog() async {
    final context = this.context;
    final prov = Provider.of<AppProvider>(context, listen: false);
    _ctrl.text = prov.profileName ?? '';
    String? selectedAvatarPath = prov.currentUser?.avatarPath;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(tr(ctx, 'edit_profile_button_text')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: CircleAvatar(
                    radius: 34,
                    backgroundImage: (selectedAvatarPath != null &&
                            selectedAvatarPath!.isNotEmpty &&
                            File(selectedAvatarPath!).existsSync())
                        ? FileImage(File(selectedAvatarPath!))
                        : null,
                    child: (selectedAvatarPath == null ||
                            selectedAvatarPath!.isEmpty ||
                            !File(selectedAvatarPath!).existsSync())
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  button: true,
                  label: tr(ctx, 'change_profile_photo'),
                  hint: tr(ctx, 'change_profile_photo_hint'),
                  child: ExcludeSemantics(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _pickAvatarPath();
                        if (path == null) return;
                        setLocalState(() => selectedAvatarPath = path);
                      },
                      icon: const Icon(Icons.photo_camera),
                      label: Text(tr(ctx, 'change_profile_photo')),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(labelText: tr(ctx, 'profile_name_label')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr(ctx, 'cancel')),
            ),
            TextButton(
              onPressed: () async {
                await _save(avatarPath: selectedAvatarPath);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: Text(tr(ctx, 'save')),
            ),
          ],
        ),
      ),
    );
  }

  String _gridSummaryLabel(BuildContext context, Post post, int index, int total) {
    final description = post.description.trim().isEmpty
        ? tr(context, 'no_description')
        : post.description.trim();
    return tr(context, 'profile_grid_item_semantics', {
      'index': '${index + 1}',
      'total': '$total',
      'description': description,
      'likes': '${post.likes}',
    });
  }

  Future<void> _openPostDetails(BuildContext context, Post post) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final currentUser = prov.currentUser;
    final username = currentUser?.username.isNotEmpty == true
        ? currentUser!.username
        : tr(context, 'unknown_user');
    final customName = prov.profileName?.trim() ?? '';
    final profileName = customName.isNotEmpty ? customName : username;
    final bio = tr(context, 'profile_default_bio', {'user': username});
    final myPosts = prov.posts
        .where((p) => currentUser?.id != null && p.userId == currentUser!.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final postCount = myPosts.length;
    final followersCount = myPosts.fold<int>(0, (sum, p) => sum + p.likes);
    final followingCount = prov.posts
        .map((p) => p.userId)
        .toSet()
        .where((id) => currentUser?.id == null || id != currentUser!.id)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'profile'))),
      body: RefreshIndicator(
        onRefresh: () => prov.loadPosts(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  image: true,
                  label: tr(context, 'profile_avatar_semantics', {'user': username}),
                  child: ExcludeSemantics(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: (currentUser?.avatarPath != null &&
                              currentUser!.avatarPath!.isNotEmpty &&
                              File(currentUser.avatarPath!).existsSync())
                          ? FileImage(File(currentUser.avatarPath!))
                          : null,
                      child: (currentUser?.avatarPath == null ||
                              currentUser!.avatarPath!.isEmpty ||
                              !File(currentUser.avatarPath!).existsSync())
                          ? Text(
                              username.isNotEmpty ? username[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 28),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MergeSemantics(
                    child: Semantics(
                      container: true,
                      label: tr(context, 'profile_stats_summary', {
                        'posts': '$postCount',
                        'followers': '$followersCount',
                        'following': '$followingCount',
                      }),
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatBlock(label: tr(context, 'posts_count_label'), value: '$postCount'),
                            _StatBlock(label: tr(context, 'followers_count_label'), value: '$followersCount'),
                            _StatBlock(label: tr(context, 'following_count_label'), value: '$followingCount'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              container: true,
              label: tr(context, 'profile_identity_summary', {
                'username': username,
                'name': profileName,
                'bio': bio,
              }),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('@$username', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(bio, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              label: tr(context, 'edit_profile_button_label'),
              hint: tr(context, 'edit_profile_button_hint'),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ExcludeSemantics(
                  child: OutlinedButton(
                    onPressed: _openEditProfileDialog,
                    child: Text(tr(context, 'edit_profile_button_text')),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr(context, 'my_posts_grid_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (myPosts.isEmpty)
              Semantics(
                liveRegion: true,
                label: tr(context, 'feed_empty_announcement'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(tr(context, 'no_posts')),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myPosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemBuilder: (ctx, index) {
                  final post = myPosts[index];
                  return FocusTraversalOrder(
                    order: NumericFocusOrder(index.toDouble()),
                    child: Semantics(
                      button: true,
                      sortKey: OrdinalSortKey(index.toDouble()),
                      label: _gridSummaryLabel(ctx, post, index, myPosts.length),
                      hint: tr(ctx, 'open_post_details'),
                      onTap: () => _openPostDetails(ctx, post),
                      child: ExcludeSemantics(
                        child: InkWell(
                          onTap: () => _openPostDetails(ctx, post),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, color: Colors.white54),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(125),
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                  ),
                                  child: Text(
                                    tr(ctx, 'likes', {'n': '${post.likes}'}),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            Text(
              tr(context, 'filtered_feed_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (myPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(tr(context, 'no_posts')),
              )
            else
              ...myPosts.map((post) => PostCard(post: post)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await prov.logout();
                  if (mounted) navigator.pushReplacementNamed('/login');
                },
                child: Text(tr(context, 'logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
