import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:magic/app/providers.dart';
import 'package:magic/app/running_profiles.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Keeps the menu bar launcher in sync with profiles, app names and running
/// state, and handles clicks on it (launch, or focus if already running).
///
/// Watch this once near the root of the app to keep it alive.
final statusMenuSyncProvider = Provider<void>((ref) {
  final platformApi = ref.watch(platformApiProvider);

  var profiles = <MagicProfile>[];
  var appNames = <String, String>{};
  var running = ref.read(runningProfilesProvider);

  Future<void> push() async {
    String appName(MagicProfile p) =>
        appNames[p.appBundleIdentifier] ?? p.appBundleIdentifier;

    final sorted = [...profiles]..sort((a, b) {
        final byApp =
            appName(a).toLowerCase().compareTo(appName(b).toLowerCase());
        return byApp != 0
            ? byApp
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    try {
      await platformApi.updateStatusMenu([
        for (final p in sorted)
          StatusMenuEntry(
            profileId: p.id,
            name: p.name,
            appName: appName(p),
            running: running.containsKey(p.id),
            color: p.displayColor,
            emoji: p.emoji,
          ),
      ]);
    } catch (_) {
      // Menu bar is a convenience; never crash the app over it.
    }
  }

  final subscriptions = <StreamSubscription<Object?>>[
    ref.read(profileRepositoryProvider).watchAll().listen((value) {
      profiles = value;
      push();
    }),
    ref.read(appRepositoryProvider).watchAll().listen((apps) {
      appNames = {for (final a in apps) a.bundleIdentifier: a.displayName};
      push();
    }),
    platformApi.statusMenuSelections.listen((profileId) {
      final running = ref.read(runningProfilesProvider.notifier);
      final Future<Object?> action = running.isRunning(profileId)
          ? running.focus(profileId)
          : ref.read(profileActivityProvider.notifier).track(
                profileId,
                ProfileActivity.launching,
                () => running.launchAndWait(profileId),
              );
      action.catchError((Object _) => null);
    }),
  ];

  ref.listen<Map<String, int>>(runningProfilesProvider, (_, next) {
    running = next;
    push();
  });

  ref.onDispose(() {
    for (final s in subscriptions) {
      s.cancel();
    }
  });
});
