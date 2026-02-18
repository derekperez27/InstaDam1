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
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _remember = false;
  bool _isLogin = true;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'invalid_credentials'))),
      );
    }
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final user = await _auth.register(username, password, remember: _remember);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'user_exists'))),
      );
    } else {
      if (!mounted) return;
      Provider.of<AppProvider>(context, listen: false).setCurrentUser(user);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5D068A), Color(0xFFFF2A7B)],
              ),
            ),
          ),
          Positioned(
            left: -50,
            top: -40,
            child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withAlpha((0.08 * 255).round()), shape: BoxShape.circle)),
          ),
          Positioned(
            right: -40,
            top: 20,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withAlpha((0.06 * 255).round()), shape: BoxShape.circle)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.18 * 255).round()),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.25 * 255).round()), blurRadius: 12, offset: const Offset(0, 6))],
                        ),
                        child: const Icon(Icons.person, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _isLogin ? tr(context, 'login') : tr(context, 'register'),
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Colors.white.withAlpha((0.06 * 255).round()),
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _userCtrl,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.person_outline),
                                    hintText: tr(context, 'username'),
                                    filled: true,
                                    fillColor: Colors.white.withAlpha((0.04 * 255).round()),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? tr(context, 'enter_username') : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passCtrl,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    hintText: tr(context, 'password'),
                                    filled: true,
                                    fillColor: Colors.white.withAlpha((0.04 * 255).round()),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  obscureText: true,
                                  validator: (v) => (v == null || v.isEmpty) ? tr(context, 'enter_password') : null,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(tr(context, 'remember_user'), style: const TextStyle(color: Colors.white70))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC44D),
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _isLogin ? _onLogin : _onRegister,
                                    child: Text(_isLogin ? tr(context, 'login') : tr(context, 'register')),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => setState(() => _isLogin = !_isLogin),
                                  child: Text(_isLogin ? tr(context, 'dont_have_account') : tr(context, 'have_account'), style: const TextStyle(color: Colors.white70)),
                                ),
                                if (_isLogin)
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'forgot_password_not_impl'))));
                                    },
                                    child: Text(tr(context, 'forgot_password'), style: const TextStyle(color: Colors.white70)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 

