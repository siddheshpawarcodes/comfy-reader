import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';

/// Cozy animated splash: warm gradient + vignette, a glowing book mark, the
/// "Comfy Reader" wordmark and a tagline. Does real init work in parallel,
/// then transitions to Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to after first frame so provider notifications don't fire mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  /// Runs startup work in parallel with the intro animation, then navigates.
  Future<void> _boot() async {
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final minShow = reduceMotion
        ? const Duration(milliseconds: 600)
        : const Duration(milliseconds: 2800);

    final stopwatch = Stopwatch()..start();
    await _initWork();
    final elapsed = stopwatch.elapsed;
    if (elapsed < minShow) {
      await Future<void>.delayed(minShow - elapsed);
    }
    if (mounted) context.go('/home');
  }

  /// Warms the first few covers so Home doesn't pop in. The library is already
  /// loaded when its provider is created (app.dart); settings load in their
  /// provider's constructor. Permission status is checked lazily on Home.
  Future<void> _initWork() async {
    if (!mounted) return;
    final library = context.read<LibraryProvider>();
    for (final book in library.books.take(6)) {
      await library.ensureCover(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comfy = Theme.of(context).extension<ComfyColors>()!;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final accent = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.25),
            radius: 1.1,
            colors: [
              Color.alphaBlend(accent.withValues(alpha: 0.10), bg),
              bg,
              isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFFEADFCB),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing book mark.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: comfy.gold.withValues(alpha: 0.35),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(AssetPaths.splashLogo, width: 132, height: 132),
              )
                  .animate()
                  .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.82, 0.82),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.easeOutBack,
                  ),
              24.verticalSpace,
              Text('Comfy Reader', style: Theme.of(context).textTheme.displayLarge)
                  .animate()
                  .fadeIn(delay: 550.ms, duration: 700.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),
              10.verticalSpace,
              Text(
                "Read like it's a real book.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 1100.ms, duration: 700.ms)
                  .slideY(begin: 0.6, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}
