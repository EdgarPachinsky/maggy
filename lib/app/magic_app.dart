import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router.dart';
import 'status_menu_sync.dart';

class MagicApp extends ConsumerWidget {
  const MagicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the menu bar launcher in sync for the app's lifetime.
    ref.watch(statusMenuSyncProvider);
    // Opens "at login" profiles after the Mac boots (once per boot).
    ref.watch(startupLaunchesProvider);

    return MaterialApp.router(
      title: 'Maggy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
