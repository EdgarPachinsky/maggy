import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:magic/domain/adapters/adapter_registry.dart';
import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/app_repository.dart';
import 'package:magic/domain/repositories/profile_repository.dart';
import 'package:magic/domain/services/app_scanner_service.dart';
import 'package:magic/domain/services/launch_service.dart';
import 'package:magic/domain/services/profile_service.dart';
import 'package:magic/domain/services/storage_service.dart';
import 'package:magic/infrastructure/adapters/chromium_adapter.dart';
import 'package:magic/infrastructure/adapters/claude_adapter.dart';
import 'package:magic/infrastructure/adapters/firefox_adapter.dart';
import 'package:magic/infrastructure/adapters/generic_adapter.dart';
import 'package:magic/infrastructure/adapters/telegram_adapter.dart';
import 'package:magic/infrastructure/adapters/vscode_adapter.dart';
import 'package:magic/infrastructure/adapters/whatsapp_adapter.dart';
import 'package:magic/infrastructure/persistence/database.dart';
import 'package:magic/infrastructure/persistence/drift_app_repository.dart';
import 'package:magic/infrastructure/persistence/drift_profile_repository.dart';
import 'package:magic/infrastructure/platform/method_channel_platform_api.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

import 'launch_at_login.dart';
import 'running_profiles.dart';

// ── Base data directory ──

final baseDataDirProvider = Provider<String>((ref) {
  // Overridden at app startup after path_provider resolves.
  throw UnimplementedError('baseDataDirProvider must be overridden');
});

// ── Platform API ──

final platformApiProvider = Provider<MagicPlatformApi>((ref) {
  return MethodChannelPlatformApi();
});

// ── Database ──

final databaseProvider = Provider<MagicDatabase>((ref) {
  final baseDir = ref.watch(baseDataDirProvider);
  final dbPath = p.join(baseDir, 'magic.db');
  return MagicDatabase(NativeDatabase.createInBackground(File(dbPath)));
});

// ── Repositories ──

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return DriftAppRepository(ref.watch(databaseProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return DriftProfileRepository(ref.watch(databaseProvider));
});

// ── Adapters ──

final adaptersProvider = Provider<List<AppAdapter>>((ref) {
  return [
    ChromiumAdapter(),
    ClaudeAdapter(platformApi: ref.watch(platformApiProvider)),
    FirefoxAdapter(),
    VSCodeAdapter(),
    WhatsAppAdapter(),
    TelegramAdapter(),
    GenericAdapter(),
  ];
});

final adapterRegistryProvider = Provider<AdapterRegistry>((ref) {
  return AdapterRegistry(ref.watch(adaptersProvider));
});

// ── Services ──

final appScannerServiceProvider = Provider<AppScannerService>((ref) {
  return AppScannerService(
    platformApi: ref.watch(platformApiProvider),
    appRepository: ref.watch(appRepositoryProvider),
    adapters: ref.watch(adaptersProvider),
  );
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(
    profileRepo: ref.watch(profileRepositoryProvider),
    appRepo: ref.watch(appRepositoryProvider),
    adapters: ref.watch(adaptersProvider),
    baseDataDir: ref.watch(baseDataDirProvider),
  );
});

final launchServiceProvider = Provider<LaunchService>((ref) {
  return LaunchService(
    profileService: ref.watch(profileServiceProvider),
    platformApi: ref.watch(platformApiProvider),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(platformApi: ref.watch(platformApiProvider));
});

// ── Running profiles (profile ID → PID) ──

final runningProfilesProvider =
    StateNotifierProvider<RunningProfilesNotifier, Map<String, int>>((ref) {
  return RunningProfilesNotifier(
    platformApi: ref.watch(platformApiProvider),
    profileRepo: ref.watch(profileRepositoryProvider),
    launchService: ref.watch(launchServiceProvider),
  );
});

/// Profile ID → what Maggy is doing with it right now (for spinners).
final profileActivityProvider =
    StateNotifierProvider<ProfileActivityNotifier, Map<String, ProfileActivity>>(
        (ref) => ProfileActivityNotifier());

// ── Open at login ──

final launchAtLoginProvider = Provider<LaunchAtLoginController>((ref) {
  return LaunchAtLoginController(
    platformApi: ref.watch(platformApiProvider),
    profileRepo: ref.watch(profileRepositoryProvider),
    profileService: ref.watch(profileServiceProvider),
    running: ref.watch(runningProfilesProvider.notifier),
    baseDataDir: ref.watch(baseDataDirProvider),
  );
});

/// Runs once at app start: opens "at login" profiles after a Mac boot.
final startupLaunchesProvider = FutureProvider<void>((ref) {
  return ref.read(launchAtLoginProvider).runStartupLaunches();
});

// ── Running apps & pins ──

/// Running Dock apps: bundle ID → instance count. Refreshes every 3 s;
/// invalidate to refresh immediately.
final runningAppsProvider = StreamProvider<Map<String, int>>((ref) async* {
  final api = ref.watch(platformApiProvider);
  while (true) {
    try {
      yield await api.runningAppCounts();
    } catch (_) {
      // Try again next tick.
    }
    await Future<void>.delayed(const Duration(seconds: 3));
  }
});

/// Bundle IDs of pinned apps.
final pinnedAppsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(appRepositoryProvider).watchPinned();
});

/// Number of profiles per app bundle ID.
final profileCountsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(profileRepositoryProvider).watchAll().map((profiles) {
    final counts = <String, int>{};
    for (final p in profiles) {
      counts[p.appBundleIdentifier] = (counts[p.appBundleIdentifier] ?? 0) + 1;
    }
    return counts;
  });
});

/// Size of a profile's data directory, keyed by the directory path.
final profileSizeProvider =
    FutureProvider.autoDispose.family<int, String>((ref, dataDirectory) {
  return ref.watch(platformApiProvider).directorySize(dataDirectory);
});

// ── UI State ──

final appListProvider =
    StreamProvider<List<AppDescriptor>>((ref) {
  return ref.watch(appRepositoryProvider).watchAll();
});

final selectedAppProvider = StateProvider<AppDescriptor?>((ref) => null);

final profileListProvider =
    StreamProvider.family<List<MagicProfile>, String>((ref, bundleId) {
  return ref.watch(profileRepositoryProvider).watchByApp(bundleId);
});

// ── Scan trigger ──

final scanAppsProvider = FutureProvider<List<AppDescriptor>>((ref) {
  return ref.watch(appScannerServiceProvider).scan();
});
