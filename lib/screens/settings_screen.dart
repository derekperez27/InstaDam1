import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  void _announce(String message) {
    final direction = Directionality.of(context);
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, message, direction);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
    );
  }

  String _languageName(BuildContext context, String code) {
    if (code == 'es') return tr(context, 'language_spanish');
    return tr(context, 'language_english');
  }

  Future<void> _onThemeChanged(bool enabled) async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    prov.setDarkMode(enabled);
    if (!mounted) return;
    _announce(
      tr(
        context,
        enabled ? 'theme_enabled_announcement' : 'theme_disabled_announcement',
      ),
    );
  }

  Future<void> _onNotificationsChanged(bool enabled) async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    await prov.setNotificationsEnabled(enabled);
    if (!mounted) return;
    _announce(
      tr(
        context,
        enabled
            ? 'notifications_enabled_announcement'
            : 'notifications_disabled_announcement',
      ),
    );
  }

  Future<void> _onLanguageChanged(String? languageCode) async {
    if (languageCode == null) return;
    final prov = Provider.of<AppProvider>(context, listen: false);
    if (prov.language == languageCode) return;
    await prov.setLanguage(languageCode);
    if (!mounted) return;
    _announce(
      tr(context, 'language_changed_announcement', {
        'lang': _languageName(context, languageCode),
      }),
    );
  }

  Future<void> _confirmLogout() async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => Semantics(
            namesRoute: true,
            label: tr(ctx, 'logout_dialog_label'),
            child: AlertDialog(
              title: Text(tr(ctx, 'logout_confirm_title')),
              content: Text(tr(ctx, 'logout_confirm_message')),
              actions: [
                Semantics(
                  button: true,
                  label: tr(ctx, 'cancel'),
                  child: ExcludeSemantics(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(tr(ctx, 'cancel')),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: tr(ctx, 'logout_confirm_button'),
                  child: ExcludeSemantics(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(tr(ctx, 'logout')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!confirmed) return;
    await prov.logout();
    if (!mounted) return;
    _announce(tr(context, 'logout_success_announcement'));
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final out = path.join(dir.path, 'insta_export.json');
      final json = await DbService().exportDatabaseToJson(
        outputFilePath: out,
        pretty: true,
      );
      if (!mounted) return;
      _announce(
        tr(context, 'exported_to', {'path': out, 'bytes': '${json.length}'}),
      );
    } catch (e) {
      if (!mounted) return;
      _announce(tr(context, 'export_failed', {'err': '$e'}));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    setState(() => _exporting = true);
    final prov = Provider.of<AppProvider>(context, listen: false);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final inPath = path.join(dir.path, 'insta_export.json');
      final f = File(inPath);
      if (!await f.exists()) {
        if (!mounted) return;
        _announce(tr(context, 'no_import_file'));
        return;
      }
      final json = await f.readAsString();
      await DbService().importDatabaseFromJson(json, replaceExisting: true);
      // reload posts
      await prov.loadPosts();
      if (!mounted) return;
      _announce(tr(context, 'import_completed'));
    } catch (e) {
      if (!mounted) return;
      _announce(tr(context, 'import_failed', {'err': '$e'}));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          MergeSemantics(
            child: Semantics(
              container: true,
              label: tr(context, 'theme_switch_semantics_label'),
              toggled: prov.isDarkMode,
              onTapHint: tr(context, 'theme_switch_semantics_hint'),
              child: SwitchListTile.adaptive(
                value: prov.isDarkMode,
                onChanged: _onThemeChanged,
                secondary: Icon(
                  prov.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: Text(tr(context, 'dark_mode')),
                subtitle: Text(
                  prov.isDarkMode
                      ? tr(context, 'state_on')
                      : tr(context, 'state_off'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          MergeSemantics(
            child: Semantics(
              container: true,
              label: tr(context, 'notifications_switch_semantics_label'),
              toggled: prov.notificationsEnabled,
              onTapHint: tr(context, 'notifications_switch_semantics_hint'),
              child: SwitchListTile.adaptive(
                value: prov.notificationsEnabled,
                onChanged: _onNotificationsChanged,
                secondary: Icon(
                  prov.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
                title: Text(tr(context, 'notifications')),
                subtitle: Text(
                  prov.notificationsEnabled
                      ? tr(context, 'state_on')
                      : tr(context, 'state_off'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            container: true,
            label: tr(context, 'language_selector_semantics_label', {
              'lang': _languageName(context, prov.language),
            }),
            onTapHint: tr(context, 'language_selector_hint'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(context, 'language_selector_visible_label'),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(prov.language),
                  isExpanded: true,
                  initialValue: prov.language,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(tr(context, 'language_english')),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(tr(context, 'language_spanish')),
                    ),
                  ],
                  onChanged: _onLanguageChanged,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(tr(context, 'export_db')),
            trailing: _exporting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _export,
                    child: Text(tr(context, 'export')),
                  ),
          ),
          ListTile(
            title: Text(tr(context, 'import_db')),
            trailing: _exporting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _import,
                    child: Text(tr(context, 'import')),
                  ),
          ),
          const Divider(),
          ListTile(
            title: Text(tr(context, 'profile')),
            subtitle: Text(prov.profileName ?? tr(context, 'no_name')),
            trailing: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
              child: Text(tr(context, 'edit')),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: tr(context, 'logout_button_semantics'),
            onTapHint: tr(context, 'logout_button_hint'),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: Text(tr(context, 'logout')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
