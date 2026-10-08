import 'package:go_router/go_router.dart';

import 'package:magic/features/applications/applications_screen.dart';
import 'package:magic/features/profiles/profiles_screen.dart';
import 'package:magic/features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/apps',
      builder: (context, state) => const ApplicationsScreen(),
    ),
    GoRoute(
      path: '/apps/:bundleId/profiles',
      builder: (context, state) {
        final bundleId = state.pathParameters['bundleId']!;
        return ProfilesScreen(bundleId: bundleId);
      },
    ),
  ],
);
