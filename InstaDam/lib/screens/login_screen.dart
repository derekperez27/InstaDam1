import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../providers/app_provider.dart';
import '../utils/loc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = false;
  final AuthService _auth = AuthService();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final user = await _auth.login(username, password, remember: _remember);
    if (user != null) {
      if (!mounted) return;
      Provider.of<AppProvider>(context, listen: false).setCurrentUser(user);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'invalid_credentials'))));
    }
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final user = await _auth.register(username, password, remember: _remember);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'user_exists'))));
    } else {
      if (!mounted) return;
      Provider.of<AppProvider>(context, listen: false).setCurrentUser(user);
      Navigator.pushReplacementNamed(context, '/home');
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'login_register'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un usuario' : null,
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Introduce una contraseña' : null,
              ),
              Row(
                children: [
                  Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                  const SizedBox(width: 8),
                  Text(tr(context, 'remember_user'))
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: _onLogin, child: Text(tr(context, 'login'))),
                  ElevatedButton(onPressed: _onRegister, child: Text(tr(context, 'register'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
