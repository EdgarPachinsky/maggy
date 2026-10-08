import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/firefox_adapter.dart';

void main() {
  group('FirefoxAdapter', () {
    late FirefoxAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = FirefoxAdapter();
      tempDir = (await Directory.systemTemp.createTemp('firefox_test_')).path;
    });

    tearDown(() async {
      final dir = Directory(tempDir);
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('identifier is firefox', () {
      expect(adapter.identifier, 'firefox');
    });

    test('supports Firefox bundle IDs', () {
      expect(adapter.supportedBundleIdentifiers,
          contains('org.mozilla.firefox'));
    });

    test('Firefox is fully supported', () {
      const firefox = AppDescriptor(
        bundleIdentifier: 'org.mozilla.firefox',
        displayName: 'Firefox',
        appPath: '/Applications/Firefox.app',
      );
      expect(adapter.compatibility(firefox), CompatibilityStatus.supported);
    });

    test('buildLaunchPlan uses open -na with -profile and -no-remote', () {
      const app = AppDescriptor(
        bundleIdentifier: 'org.mozilla.firefox',
        displayName: 'Firefox',
        appPath: '/Applications/Firefox.app',
        executablePath: '/Applications/Firefox.app/Contents/MacOS/firefox',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'org.mozilla.firefox',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/firefox-work',
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.executablePath, '/usr/bin/open');
      expect(plan.arguments, contains('-na'));
      expect(plan.arguments, contains('--args'));
      expect(plan.arguments, contains('-profile'));
      expect(plan.arguments, contains('$tempDir/firefox-work'));
      expect(plan.arguments, contains('-no-remote'));
    });

    test('two profiles get different -profile paths', () {
      const app = AppDescriptor(
        bundleIdentifier: 'org.mozilla.firefox',
        displayName: 'Firefox',
        appPath: '/Applications/Firefox.app',
        executablePath: '/Applications/Firefox.app/Contents/MacOS/firefox',
      );
      final now = DateTime.now();
      final work = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'org.mozilla.firefox',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/work',
      );
      final personal = MagicProfile(
        id: 'p2',
        appBundleIdentifier: 'org.mozilla.firefox',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/personal',
      );

      final planWork = adapter.buildLaunchPlan(app, work);
      final planPersonal = adapter.buildLaunchPlan(app, personal);

      final workProfileIdx = planWork.arguments.indexOf('-profile');
      final personalProfileIdx =
          planPersonal.arguments.indexOf('-profile');
      expect(planWork.arguments[workProfileIdx + 1],
          isNot(planPersonal.arguments[personalProfileIdx + 1]));
    });

    test('createProfile creates directory', () async {
      const app = AppDescriptor(
        bundleIdentifier: 'org.mozilla.firefox',
        displayName: 'Firefox',
        appPath: '/Applications/Firefox.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'org.mozilla.firefox',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/new-ff-profile',
      );

      await adapter.createProfile(app, profile);
      expect(await Directory('$tempDir/new-ff-profile').exists(), isTrue);
    });

    test('resetProfile removes directory', () async {
      final profileDir = Directory('$tempDir/ff-to-reset');
      await profileDir.create(recursive: true);

      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'org.mozilla.firefox',
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
