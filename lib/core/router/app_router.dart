import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_shell.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/settings/voices_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/durations.dart';

/// App routes: splash → home → reader. Home is a bottom-nav shell hosting the
/// Library, Continue Reading, and Settings tabs. Transitions use a soft fade.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _fadePage(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _fadePage(state, const HomeShell()),
    ),
    GoRoute(
      path: '/reader/:bookId',
      pageBuilder: (context, state) => _fadePage(
        state,
        ReaderScreen(bookId: state.pathParameters['bookId']!),
      ),
    ),
    GoRoute(
      path: '/voices',
      pageBuilder: (context, state) => _fadePage(state, const VoicesScreen()),
    ),
  ],
);

/// A soft cross-fade — used for splash → home and the reader (whose cover Hero
/// carries the visual continuity).
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppDurations.base,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}
