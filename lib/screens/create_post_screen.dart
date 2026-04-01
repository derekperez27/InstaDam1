import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _imagePath;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_saving) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      final message = tr(context, 'create_post_description_error_required');
      final direction = Directionality.of(context);
      final view = View.of(context);
      SemanticsService.sendAnnouncement(view, message, direction);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
      );
      return;
    }
    final desc = _ctrl.text.trim();
    setState(() => _saving = true);
    final prov = Provider.of<AppProvider>(context, listen: false);
    final userId = prov.currentUser?.id ?? 0;
    final post = Post(
      userId: userId,
      imagePath: _imagePath ?? '',
      description: desc,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await prov.addPost(post);
    if (mounted) {
      setState(() => _saving = false);
      final message = tr(context, 'create_post_published_announcement');
      final direction = Directionality.of(context);
      final view = View.of(context);
      SemanticsService.sendAnnouncement(view, message, direction);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'create_post'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: Semantics(
                    button: true,
                    label: _imagePath == null
                        ? tr(context, 'create_post_image_selector_no_image')
                        : tr(context, 'create_post_image_selector_with_image'),
                    hint: tr(context, 'create_post_image_selector_hint'),
                    onTap: _pickImage,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imagePath == null
                            ? ExcludeSemantics(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      size: 36,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(tr(context, 'tap_to_add_image')),
                                  ],
                                ),
                              )
                            : ExcludeSemantics(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: Text(
                    tr(context, 'create_post_description_label_required'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3),
                  child: Semantics(
                    textField: true,
                    label: tr(context, 'create_post_description_field_label'),
                    hint: tr(context, 'create_post_description_field_hint'),
                    child: TextFormField(
                      controller: _ctrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: tr(context, 'description'),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr(
                            context,
                            'create_post_description_error_required',
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(4),
                  child: Semantics(
                    button: true,
                    enabled: !_saving,
                    liveRegion: _saving,
                    label: _saving
                        ? tr(context, 'create_post_publishing')
                        : tr(context, 'publish'),
                    hint: _saving
                        ? tr(context, 'create_post_loading_hint')
                        : tr(context, 'create_post_publish_hint'),
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _publish,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _saving
                            ? tr(context, 'create_post_publishing')
                            : tr(context, 'publish'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        if (!mounted) return;
        final message = tr(context, 'create_post_image_selector_with_image');
        final direction = Directionality.of(context);
        final view = View.of(context);
        SemanticsService.sendAnnouncement(view, message, direction);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Image pick failed: $e');
    }
  }
}
