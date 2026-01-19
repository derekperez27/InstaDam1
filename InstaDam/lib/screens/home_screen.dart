import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'create_post_screen.dart';
import '../widgets/post_card.dart';
import '../utils/loc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    await prov.loadPosts();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'feed')), actions: [
        IconButton(onPressed: () => Navigator.of(context).pushNamed('/profile'), icon: const Icon(Icons.person)),
        IconButton(onPressed: () => Navigator.of(context).pushNamed('/settings'), icon: const Icon(Icons.settings)),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : prov.posts.isEmpty
              ? Center(child: Text(tr(context, 'no_posts')))
              : RefreshIndicator(
                  onRefresh: () => prov.loadPosts(),
                  child: ListView.builder(
                    itemCount: prov.posts.length,
                    itemBuilder: (context, i) => PostCard(post: prov.posts[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          if (created == true) await prov.loadPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
