import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/app_provider.dart';
import '../utils/loc.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _imagePath;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final desc = _ctrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'enter_description'))));
      return;
    }
    setState(() => _saving = true);
    final prov = Provider.of<AppProvider>(context, listen: false);
    final userId = prov.currentUser?.id ?? 0;
    final post = Post(userId: userId, imagePath: _imagePath ?? '', description: desc, createdAt: DateTime.now().millisecondsSinceEpoch);
    await prov.addPost(post);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'published'))));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'create_post'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // image picker / preview
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo, size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(tr(context, 'tap_to_add_image'))
                        ],
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imagePath!), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: InputDecoration(border: const OutlineInputBorder(), labelText: tr(context, 'description')),
            ),
            const SizedBox(height: 12),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(onPressed: _publish, icon: const Icon(Icons.send), label: Text(tr(context, 'publish')))
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;
      final path = result.files.single.path;
      if (path != null) {
        setState(() => _imagePath = path);
      }
    } catch (e) {}
  }
}
