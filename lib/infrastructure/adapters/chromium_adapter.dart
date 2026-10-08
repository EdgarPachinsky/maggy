import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

/// Adapter for Chromium-family browsers (Chrome, Chromium, Edge, Brave, Arc).
///
/// Uses `--user-data-dir` to point each profile at a separate data directory.
/// This gives full isolation: separate cookies, sessions, extensions, and
/// accounts. Multiple profiles can run concurrently.
class ChromiumAdapter implements AppAdapter {
  @override
  String get identifier => 'chromium';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        'com.google.Chrome',
        'com.google.Chrome.canary',
        'org.chromium.Chromium',
        'com.microsoft.edgemac',
        'com.brave.Browser',
        'company.thebrowser.Browser', // Arc
        'com.vivaldi.Vivaldi',
        'com.operasoftware.Opera',
      };

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    const fullySupported = {
      'com.google.Chrome',
      'com.google.Chrome.canary',
      'org.chromium.Chromium',
    };
    if (fullySupported.contains(app.bundleIdentifier)) {
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
    // Chromium creates its own internal structure on first launch.
    // We just need the directory to exist.
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    // Launch a new instance to get past any single-instance lock.
    return LaunchPlan.newAppInstance(
      appPath: app.appPath,
      appArguments: [
        '--user-data-dir=${profile.dataDirectory}',
        ...profile.launchArguments,
      ],
      environment: profile.environmentVariables,
      warnings: _warnings(app),
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

  String _executableName(AppDescriptor app) {
    return switch (app.bundleIdentifier) {
      'com.google.Chrome' => 'Google Chrome',
      'com.google.Chrome.canary' => 'Google Chrome Canary',
      'org.chromium.Chromium' => 'Chromium',
      'com.microsoft.edgemac' => 'Microsoft Edge',
      'com.brave.Browser' => 'Brave Browser',
      'company.thebrowser.Browser' => 'Arc',
      'com.vivaldi.Vivaldi' => 'Vivaldi',
      'com.operasoftware.Opera' => 'Opera',
      _ => app.displayName,
    };
  }

  List<String> _warnings(AppDescriptor app) {
    final warnings = <String>[];
    const withLimitations = {
      'com.microsoft.edgemac',
      'com.brave.Browser',
      'company.thebrowser.Browser',
      'com.vivaldi.Vivaldi',
      'com.operasoftware.Opera',
    };
    if (withLimitations.contains(app.bundleIdentifier)) {
      warnings.add(
        '${app.displayName} is Chromium-based but may have custom behavior '
        'that interferes with --user-data-dir isolation.',
      );
    }
    return warnings;
  }
}
