import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../routes/app_routes.dart';
import '../themes/app_theme.dart';
import '../utils/loc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _navigationDelay = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _announceSplash();
      _navigateToNextScreen();
    });
  }

  Future<void> _announceSplash() async {
    final direction = Directionality.of(context);
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, tr(context, 'app_name'), direction);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    SemanticsService.sendAnnouncement(
      view,
      tr(context, 'app_loading'),
      direction,
    );
  }

  Future<void> _navigateToNextScreen() async {
    await Future<void>.delayed(_navigationDelay);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface),
          ),
          const Positioned(
            top: -72,
            right: -24,
            child: ExcludeSemantics(
              child: _DecorativeCircle(size: 184, color: AppColors.surfaceTint),
            ),
          ),
          const Positioned(
            bottom: -88,
            left: -36,
            child: ExcludeSemantics(
              child: _DecorativeCircle(size: 220, color: AppColors.surfaceTint),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      container: true,
                      header: true,
                      label: tr(context, 'app_name'),
                      child: ExcludeSemantics(
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ExcludeSemantics(
                      child: Text(
                        tr(context, 'app_name'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      container: true,
                      liveRegion: true,
                      label: tr(context, 'app_loading'),
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr(context, 'app_loading'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
