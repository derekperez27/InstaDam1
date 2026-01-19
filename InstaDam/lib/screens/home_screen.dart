import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'create_post_screen.dart';
import '../widgets/post_card.dart';

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
      appBar: AppBar(title: const Text('Feed')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : prov.posts.isEmpty
              ? const Center(child: Text('Sin publicaciones aún'))
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
