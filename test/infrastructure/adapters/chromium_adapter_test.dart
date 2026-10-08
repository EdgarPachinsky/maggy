import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/chromium_adapter.dart';

void main() {
  group('ChromiumAdapter', () {
    late ChromiumAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = ChromiumAdapter();
      tempDir = (await Directory.systemTemp.createTemp('chromium_test_')).path;
    });

    tearDown(() async {
      final dir = Directory(tempDir);
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('identifier is chromium', () {
      expect(adapter.identifier, 'chromium');
    });

    test('supports Chrome and Chromium bundle IDs', () {
      expect(adapter.supportedBundleIdentifiers,
          contains('com.google.Chrome'));
      expect(adapter.supportedBundleIdentifiers,
          contains('org.chromium.Chromium'));
    });

    test('Chrome is fully supported', () {
      const chrome = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
      );
      expect(adapter.compatibility(chrome), CompatibilityStatus.supported);
    });

    test('Edge is supported with limitations', () {
      const edge = AppDescriptor(
        bundleIdentifier: 'com.microsoft.edgemac',
        displayName: 'Microsoft Edge',
        appPath: '/Applications/Microsoft Edge.app',
      );
      expect(adapter.compatibility(edge),
          CompatibilityStatus.supportedWithLimitations);
    });

    test('buildLaunchPlan uses open -na with --user-data-dir', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
        executablePath:
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/profile-work',
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.executablePath, '/usr/bin/open');
      expect(plan.arguments, contains('-na'));
      expect(plan.arguments, contains('/Applications/Google Chrome.app'));
      expect(plan.arguments, contains('--args'));
      expect(plan.arguments,
          contains('--user-data-dir=$tempDir/profile-work'));
    });

    test('two profiles produce different user-data-dir paths', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
        executablePath:
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      );
      final now = DateTime.now();
      final work = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/work',
      );
      final personal = MagicProfile(
        id: 'p2',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/personal',
      );

      final planWork = adapter.buildLaunchPlan(app, work);
      final planPersonal = adapter.buildLaunchPlan(app, personal);

      final workDir = planWork.arguments
          .firstWhere((a) => a.startsWith('--user-data-dir='));
      final personalDir = planPersonal.arguments
          .firstWhere((a) => a.startsWith('--user-data-dir='));
      expect(workDir, isNot(personalDir));
    });

    test('createProfile creates the data directory', () async {
      const app = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/new-profile',
      );

      await adapter.createProfile(app, profile);
      expect(await Directory('$tempDir/new-profile').exists(), isTrue);
    });

    test('resetProfile deletes the data directory', () async {
      final profileDir = Directory('$tempDir/to-reset');
      await profileDir.create(recursive: true);
      await File('${profileDir.path}/data.txt').writeAsString('test');

      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: profileDir.path,
      );

      await adapter.resetProfile(profile);
      expect(await profileDir.exists(), isFalse);
    });

    test('buildLaunchPlan preserves custom launch arguments', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
        executablePath:
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/work',
        launchArguments: ['--disable-gpu', '--incognito'],
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.arguments, contains('--disable-gpu'));
      expect(plan.arguments, contains('--incognito'));
      // --user-data-dir should come right after --args
      final argsIdx = plan.arguments.indexOf('--args');
      expect(plan.arguments[argsIdx + 1],
          startsWith('--user-data-dir='));
    });
  });
}
