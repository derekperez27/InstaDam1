import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      final remembered = StorageService().getRememberedUser();
      if (remembered != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'InstaDAM',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
