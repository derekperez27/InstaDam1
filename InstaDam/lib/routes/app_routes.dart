import 'package:flutter/widgets.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        home: (_) => const HomeScreen(),
        settings: (_) => const SettingsScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
