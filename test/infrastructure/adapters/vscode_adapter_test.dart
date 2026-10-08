import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/vscode_adapter.dart';

void main() {
  group('VSCodeAdapter', () {
    late VSCodeAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = VSCodeAdapter();
      tempDir = (await Directory.systemTemp.createTemp('vscode_test_')).path;
    });

    tearDown(() async {
      final dir = Directory(tempDir);
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('identifier is vscode', () {
      expect(adapter.identifier, 'vscode');
    });

    test('supports VS Code bundle IDs', () {
      expect(adapter.supportedBundleIdentifiers,
          contains('com.microsoft.VSCode'));
    });

    test('compatibility is supportedWithLimitations', () {
      const vscode = AppDescriptor(
        bundleIdentifier: 'com.microsoft.VSCode',
        displayName: 'Visual Studio Code',
        appPath: '/Applications/Visual Studio Code.app',
      );
      expect(adapter.compatibility(vscode),
          CompatibilityStatus.supportedWithLimitations);
    });

    test('buildLaunchPlan uses open -na with --user-data-dir and --extensions-dir', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.microsoft.VSCode',
        displayName: 'Visual Studio Code',
        appPath: '/Applications/Visual Studio Code.app',
        executablePath:
            '/Applications/Visual Studio Code.app/Contents/MacOS/Electron',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.microsoft.VSCode',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/vscode-work',
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.executablePath, '/usr/bin/open');
      expect(plan.arguments, contains('-na'));
      expect(plan.arguments, contains('/Applications/Visual Studio Code.app'));
      expect(plan.arguments, contains('--args'));
      expect(plan.arguments,
          contains('--user-data-dir=$tempDir/vscode-work'));
      expect(plan.arguments,
          contains('--extensions-dir=$tempDir/vscode-work/extensions'));
      expect(plan.warnings, isNotEmpty);
    });

    test('createProfile creates data and extensions directories', () async {
      const app = AppDescriptor(
        bundleIdentifier: 'com.microsoft.VSCode',
        displayName: 'Visual Studio Code',
        appPath: '/Applications/Visual Studio Code.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.microsoft.VSCode',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/vscode-test',
      );

      await adapter.createProfile(app, profile);
      expect(await Directory('$tempDir/vscode-test').exists(), isTrue);
      expect(
          await Directory('$tempDir/vscode-test/extensions').exists(), isTrue);
    });

    test('resetProfile deletes the data directory', () async {
      final profileDir = Directory('$tempDir/vscode-reset');
      await profileDir.create(recursive: true);
      await Directory('$tempDir/vscode-reset/extensions').create();

      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.microsoft.VSCode',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: profileDir.path,
      );

      await adapter.resetProfile(profile);
      expect(await profileDir.exists(), isFalse);
    });
  });
}
