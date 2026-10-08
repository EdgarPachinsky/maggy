import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

/// Adapter for Visual Studio Code.
///
/// Uses `--user-data-dir` and `--extensions-dir` to isolate settings,
/// extensions, and workspace state per profile.
class VSCodeAdapter implements AppAdapter {
  @override
  String get identifier => 'vscode';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        'com.microsoft.VSCode',
        'com.microsoft.VSCodeInsiders',
        'com.vscodium.VSCodium',
      };

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    return CompatibilityStatus.supportedWithLimitations;
  }

  @override
  Future<void> createProfile(AppDescriptor app, MagicProfile profile) async {
    final dataDir = Directory(profile.dataDirectory);
    final extDir = Directory('${profile.dataDirectory}/extensions');
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    if (!await extDir.exists()) {
      await extDir.create(recursive: true);
    }
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    // Launch a new instance to get past Electron's single-instance lock.
    return LaunchPlan.newAppInstance(
      appPath: app.appPath,
      appArguments: [
        '--user-data-dir=${profile.dataDirectory}',
        '--extensions-dir=${profile.dataDirectory}/extensions',
        ...profile.launchArguments,
      ],
      environment: profile.environmentVariables,
      warnings: [
        'VS Code profiles share the same Keychain and system credentials. '
            'Separate accounts for extensions that use OS-level auth are not guaranteed.',
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
