import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../providers/app_provider.dart';
import '../services/db_service.dart';
import '../utils/loc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final out = path.join(dir.path, 'insta_export.json');
      final json = await DbService().exportDatabaseToJson(outputFilePath: out, pretty: true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'exported_to', {'path': out, 'bytes': '${json.length}'}))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    setState(() => _exporting = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final inPath = path.join(dir.path, 'insta_export.json');
      final f = File(inPath);
      if (!await f.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'no_import_file'))));
        return;
      }
      final json = await f.readAsString();
      await DbService().importDatabaseFromJson(json, replaceExisting: true);
      // reload posts
      final prov = Provider.of<AppProvider>(context, listen: false);
      await prov.loadPosts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'import_completed'))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'import_failed', {'err': '$e'}))));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'settings'))),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context, 'dark_mode')),
                Switch(value: prov.isDarkMode, onChanged: (v) => prov.setDarkMode(v)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context, 'notifications')),
                Switch(value: prov.notificationsEnabled, onChanged: (v) => prov.setNotificationsEnabled(v)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(tr(context, 'language')),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: prov.language,
                  items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'es', child: Text('Español'))],
                  onChanged: (v) {
                    if (v != null) prov.setLanguage(v);
                  },
                )
              ],
            ),
            const Divider(),
            ListTile(
              title: Text(tr(context, 'export_db')),
              trailing: _exporting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _export, child: Text(tr(context, 'export'))),
            ),
            ListTile(
              title: Text(tr(context, 'import_db')),
              trailing: _exporting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _import, child: Text(tr(context, 'import'))),
            ),
            const Divider(),
            ListTile(
              title: Text(tr(context, 'profile')),
              subtitle: Text(prov.profileName ?? tr(context, 'no_name')),
              trailing: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                child: Text(tr(context, 'edit')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
