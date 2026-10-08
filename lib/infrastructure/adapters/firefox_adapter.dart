import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

/// Adapter for Firefox and Firefox-family browsers.
///
/// Uses `-profile <path>` to launch Firefox with a dedicated profile directory.
/// Uses `-no-remote` to allow multiple concurrent instances with different
/// profiles.
class FirefoxAdapter implements AppAdapter {
  @override
  String get identifier => 'firefox';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        'org.mozilla.firefox',
        'org.mozilla.firefoxdeveloperedition',
        'org.mozilla.nightly',
      };

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    if (app.bundleIdentifier == 'org.mozilla.firefox') {
      return CompatibilityStatus.supported;
    }
    return CompatibilityStatus.supportedWithLimitations;
  }

  @override
  Future<void> createProfile(AppDescriptor app, MagicProfile profile) async {
    final dir = Directory(profile.dataDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    // Firefox populates the profile directory on first launch.
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    // Launch a new instance. Combined with -no-remote and -profile this
    // gives full multi-instance support.
    return LaunchPlan.newAppInstance(
      appPath: app.appPath,
      appArguments: [
        '-profile',
        profile.dataDirectory,
        '-no-remote',
        ...profile.launchArguments,
      ],
      environment: profile.environmentVariables,
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
