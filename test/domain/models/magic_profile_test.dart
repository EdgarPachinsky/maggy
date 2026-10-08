import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';

void main() {
  group('MagicProfile', () {
    final now = DateTime(2025, 1, 1);

    test('equality is based on id', () {
      final a = MagicProfile(
        id: 'abc-123',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/profiles/abc-123',
      );
      final b = MagicProfile(
        id: 'abc-123',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/profiles/other',
      );
      expect(a, equals(b));
    });

    test('copyWith updates specified fields', () {
      final profile = MagicProfile(
        id: 'abc-123',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/profiles/abc-123',
        status: ProfileStatus.ready,
      );
      final running = profile.copyWith(status: ProfileStatus.running);
      expect(running.status, ProfileStatus.running);
      expect(running.name, 'Work');
      expect(running.id, 'abc-123');
    });

    test('default status is ready', () {
      final profile = MagicProfile(
        id: 'test',
        appBundleIdentifier: 'com.example',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/test',
      );
      expect(profile.status, ProfileStatus.ready);
    });

    test('default launchArguments and environmentVariables are empty', () {
      final profile = MagicProfile(
        id: 'test',
        appBundleIdentifier: 'com.example',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/test',
      );
      expect(profile.launchArguments, isEmpty);
      expect(profile.environmentVariables, isEmpty);
    });
  });

  group('LaunchPlan', () {
    test('can be created with minimal arguments', () {
      const plan = LaunchPlan(
        executablePath: '/usr/bin/open',
      );
      expect(plan.arguments, isEmpty);
      expect(plan.environment, isEmpty);
      expect(plan.warnings, isEmpty);
      expect(plan.workingDirectory, isNull);
    });

    test('toString includes summary', () {
      const plan = LaunchPlan(
        executablePath: '/usr/bin/open',
        arguments: ['--arg1'],
        environment: {'KEY': 'val'},
        warnings: ['Be careful'],
      );
      expect(plan.toString(), contains('args=1'));
      expect(plan.toString(), contains('env=1'));
      expect(plan.toString(), contains('warnings=1'));
    });
  });
}
