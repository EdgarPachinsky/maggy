import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

/// Fallback adapter for any application.
///
/// Allows manually configured arguments, environment variables, and working
/// directory. Does NOT guarantee separate accounts, Keychain credentials,
/// or application data. Never labeled "isolated."
class GenericAdapter implements AppAdapter {
  @override
  String get identifier => 'generic';

  /// The generic adapter matches any bundle ID not handled by a specific
  /// adapter. It is always checked last by the registry.
  @override
  Set<String> get supportedBundleIdentifiers => const {};

  /// Returns [CompatibilityStatus.experimental] for everything.
  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    return CompatibilityStatus.experimental;
  }

  @override
  Future<void> createProfile(AppDescriptor app, MagicProfile profile) async {
    final dir = Directory(profile.dataDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    final executable = app.executablePath ??
        '${app.appPath}/Contents/MacOS/${app.displayName}';

    return LaunchPlan(
      executablePath: executable,
      arguments: profile.launchArguments,
      environment: profile.environmentVariables,
      workingDirectory: profile.dataDirectory,
      warnings: [
        'Generic experimental mode: ${app.displayName} has no dedicated adapter. '
            'Profile isolation is NOT guaranteed. Separate accounts, Keychain '
            'credentials, and app data isolation are not ensured.',
      ],
    );
  }

  @override
  Future<bool> validate(MagicProfile profile) async {
    return Directory(profile.dataDirectory).existsSync();
  }

  @override
  Future<void> resetProfile(MagicProfile profile) async {
    final dir = Directory(profile.dataDirectory);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
