import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/loc.dart';

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
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    await prov.setProfileName(_ctrl.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'profile'))),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _ctrl, decoration: InputDecoration(labelText: tr(context, 'profile'))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: Text(tr(context, 'save'))),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () async {
                  await prov.logout();
                  if (mounted) Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(tr(context, 'logout')))
          ],
        ),
      ),
    );
  }
}
