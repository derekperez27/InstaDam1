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
    // Use vivid, warm accent that matches dark mode palette
    const Color darkAccent = Color(0xFF5D068A);
    final Color accent = darkAccent;

    return Scaffold(
      // gradient background for a more vivid look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade900, accent.withAlpha(30)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(tr(context, 'feed'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.of(context).pushNamed('/profile'), icon: const Icon(Icons.person, color: Colors.white)),
                    IconButton(onPressed: () => Navigator.of(context).pushNamed('/settings'), icon: const Icon(Icons.settings, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : prov.posts.isEmpty
                        ? Center(child: Text(tr(context, 'no_posts'), style: const TextStyle(color: Colors.white70)))
                        : RefreshIndicator(
                            color: accent,
                            onRefresh: () => prov.loadPosts(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              itemCount: prov.posts.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, i) => PostCard(
                                post: prov.posts[i],
                                // pass accent color to PostCard if it supports it (it will ignore if not)
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () async {
          final created = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          if (created == true) await prov.loadPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
