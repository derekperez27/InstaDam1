import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../providers/app_provider.dart';
import '../utils/loc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1622), Color(0xFF2B2430)],
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DiagonalTexturePainter()),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Card(
                    color: const Color(0xFF1C1A1D),
                    shadowColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black87, width: 2),
                    ),
                    elevation: 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withAlpha((0.18 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, size: 44, color: Colors.white70),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _isLogin ? tr(context, 'login') : tr(context, 'register'),
                              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () => setState(() => _isLogin = !_isLogin),
                              child: Text(_isLogin ? tr(context, 'dont_have_account') : tr(context, 'have_account')),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _userCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline),
                                hintText: tr(context, 'username'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? tr(context, 'enter_username') : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: tr(context, 'password'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              obscureText: true,
                              validator: (v) => (v == null || v.isEmpty) ? tr(context, 'enter_password') : null,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tr(context, 'remember_user'))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: _isLogin ? _onLogin : _onRegister,
                                child: Text(_isLogin ? tr(context, 'login') : tr(context, 'register')),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_isLogin)
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'forgot_password_not_impl'))));
                                },
                                child: Text(tr(context, 'forgot_password')),
                              ),
                          ],
                        ),
                      ),
                    ),
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

class _DiagonalTexturePainter extends CustomPainter {
  final double opacity;
  const _DiagonalTexturePainter({this.opacity = 0.02});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    const spacing = 18.0;
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalTexturePainter oldDelegate) => oldDelegate.opacity != opacity;
}
 

