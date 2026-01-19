import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/app_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final desc = _ctrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce una descripción')));
      return;
    }
    setState(() => _saving = true);
    final prov = Provider.of<AppProvider>(context, listen: false);
    final userId = prov.currentUser?.id ?? 0;
    final post = Post(userId: userId, imagePath: '', description: desc, createdAt: DateTime.now().millisecondsSinceEpoch);
    await prov.addPost(post);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicado')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // simple placeholder for image
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 64, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Descripción'),
            ),
            const SizedBox(height: 12),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(onPressed: _publish, icon: const Icon(Icons.send), label: const Text('Publicar'))
          ],
        ),
      ),
    );
  }
}
