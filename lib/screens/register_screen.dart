import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../utils/loc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _rememberFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();

  final AuthService _auth = AuthService();

  bool _remember = false;
  bool _isLoading = false;
  String? _globalError;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _rememberFocus.dispose();
    _submitFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    setState(() {
      _globalError = null;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final user = await _auth.register(username, password, remember: _remember);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _globalError = tr(context, 'user_exists');
        _isLoading = false;
      });
      return;
    }

    Provider.of<AppProvider>(context, listen: false).setCurrentUser(user);
    Navigator.pushReplacementNamed(context, '/home');
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withAlpha((0.04 * 255).round()),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
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
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.08 * 255).round()),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.06 * 255).round()),
                shape: BoxShape.circle,
              ),
            ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.25 * 255).round()),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_alt_1, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        tr(context, 'register'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(tr(context, 'username')),
                                TextFormField(
                                  controller: _userCtrl,
                                  focusNode: _userFocus,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(tr(context, 'username_hint')).copyWith(
                                    prefixIcon: const Icon(Icons.person_outline),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passFocus);
                                  },
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return tr(context, 'enter_username');
                                    }
                                    if (v.trim().length < 3) {
                                      return tr(context, 'username_min_chars');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _fieldLabel(tr(context, 'password')),
                                TextFormField(
                                  controller: _passCtrl,
                                  focusNode: _passFocus,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(tr(context, 'password_hint')).copyWith(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_rememberFocus);
                                  },
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return tr(context, 'enter_password');
                                    }
                                    if (v.length < 6) {
                                      return tr(context, 'password_min_chars');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                Semantics(
                                  label: tr(context, 'remember_user'),
                                  toggled: _remember,
                                  child: SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    focusNode: _rememberFocus,
                                    title: Text(
                                      tr(context, 'remember_user'),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    value: _remember,
                                    onChanged: _isLoading
                                        ? null
                                        : (v) {
                                            setState(() => _remember = v);
                                          },
                                  ),
                                ),
                                if (_globalError != null) ...[
                                  const SizedBox(height: 6),
                                  Semantics(
                                    liveRegion: true,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withAlpha((0.18 * 255).round()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _globalError!,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Semantics(
                                  button: true,
                                  enabled: !_isLoading,
                                  label: _isLoading ? tr(context, 'registering') : tr(context, 'register'),
                                  child: ElevatedButton(
                                    focusNode: _submitFocus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC44D),
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      minimumSize: const Size(double.infinity, 48),
                                    ),
                                    onPressed: _isLoading ? null : _onRegister,
                                    child: _isLoading
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(tr(context, 'registering')),
                                            ],
                                          )
                                        : Text(tr(context, 'register')),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.pop(context);
                                        },
                                  child: Text(
                                    tr(context, 'have_account'),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
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
