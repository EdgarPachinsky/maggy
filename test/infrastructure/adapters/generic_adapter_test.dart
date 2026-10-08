import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/generic_adapter.dart';

void main() {
  group('GenericAdapter', () {
    late GenericAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = GenericAdapter();
      tempDir = (await Directory.systemTemp.createTemp('generic_test_')).path;
    });

    tearDown(() async {
      final dir = Directory(tempDir);
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('identifier is generic', () {
      expect(adapter.identifier, 'generic');
    });

    test('supportedBundleIdentifiers is empty', () {
      expect(adapter.supportedBundleIdentifiers, isEmpty);
    });

    test('compatibility is always experimental', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.random.app',
        displayName: 'Random App',
        appPath: '/Applications/Random.app',
      );
      expect(adapter.compatibility(app), CompatibilityStatus.experimental);
    });

    test('buildLaunchPlan includes strong warnings', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.random.app',
        displayName: 'Random App',
        appPath: '/Applications/Random.app',
        executablePath:
            '/Applications/Random.app/Contents/MacOS/Random App',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.random.app',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/generic-test',
        launchArguments: ['--custom-flag'],
        environmentVariables: {'MY_VAR': 'value'},
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.arguments, contains('--custom-flag'));
      expect(plan.environment, containsPair('MY_VAR', 'value'));
      expect(plan.workingDirectory, '$tempDir/generic-test');
      expect(plan.warnings, isNotEmpty);
      expect(plan.warnings.first, contains('NOT guaranteed'));
    });
  });
}
