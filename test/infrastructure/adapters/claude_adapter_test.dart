import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/claude_adapter.dart';

void main() {
  group('ClaudeAdapter', () {
    late ClaudeAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = ClaudeAdapter();
      tempDir = (await Directory.systemTemp.createTemp('claude_test_')).path;
    });

    tearDown(() async {
      final dir = Directory(tempDir);
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('identifier is claude', () {
      expect(adapter.identifier, 'claude');
    });

    test('supports Claude desktop bundle ID', () {
      expect(adapter.supportedBundleIdentifiers,
          contains('com.anthropic.claudefordesktop'));
    });

    test('Claude is fully supported', () {
      const claude = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
      );
      expect(adapter.compatibility(claude), CompatibilityStatus.supported);
    });

    test('buildLaunchPlan uses wrapper path when wrapper exists', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
        executablePath: '/Applications/Claude.app/Contents/MacOS/Claude',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/claude-work',
      );

      // Create a fake wrapper directory so buildLaunchPlan picks it up
      Directory('$tempDir/claude-work/Claude.app').createSync(recursive: true);

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.executablePath, '/usr/bin/open');
      expect(plan.arguments, contains('-na'));
      expect(plan.arguments,
          contains('$tempDir/claude-work/Claude.app'));
      expect(plan.arguments, contains('--args'));
      expect(plan.arguments,
          contains('--user-data-dir=$tempDir/claude-work'));
    });

    test('buildLaunchPlan falls back to original app when wrapper missing', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/claude-work',
      );

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.arguments, contains('/Applications/Claude.app'));
      expect(plan.warnings,
          anyElement(contains('App wrapper not found')));
      expect(plan.deepLinkRoute, isNull);
    });

    test('two profiles produce different launch paths', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
      );
      final now = DateTime.now();
      final work = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/work',
      );
      final personal = MagicProfile(
        id: 'p2',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/personal',
      );

      // Create fake wrappers
      Directory('$tempDir/work/Claude.app').createSync(recursive: true);
      Directory('$tempDir/personal/Claude.app').createSync(recursive: true);

      final planWork = adapter.buildLaunchPlan(app, work);
      final planPersonal = adapter.buildLaunchPlan(app, personal);

      // Each profile gets its own wrapper path
      expect(planWork.arguments, contains('$tempDir/work/Claude.app'));
      expect(
          planPersonal.arguments, contains('$tempDir/personal/Claude.app'));
    });

    test('--args separates open flags from app flags', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/claude-work',
      );

      Directory('$tempDir/claude-work/Claude.app').createSync(recursive: true);

      final plan = adapter.buildLaunchPlan(app, profile);
      final argsIndex = plan.arguments.indexOf('--args');
      final dataDirIndex = plan.arguments
          .indexWhere((a) => a.startsWith('--user-data-dir='));
      expect(argsIndex, lessThan(dataDirIndex));
    });

    test('createProfile creates wrapper with symlinks', () async {
      final app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '$tempDir/fake-source/Claude.app',
      );

      // Create a minimal fake source app bundle.
      final srcContents = '$tempDir/fake-source/Claude.app/Contents';
      await Directory('$srcContents/MacOS').create(recursive: true);
      await Directory('$srcContents/Frameworks').create(recursive: true);
      await Directory('$srcContents/Resources').create(recursive: true);
      await File('$srcContents/MacOS/Claude').writeAsString('binary');
      await File('$srcContents/Info.plist').writeAsString(
        '<?xml version="1.0"?>'
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" '
        '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
        '<plist version="1.0"><dict>'
        '<key>CFBundleIdentifier</key>'
        '<string>com.anthropic.claudefordesktop</string>'
        '<key>CFBundleName</key>'
        '<string>Claude</string>'
        '</dict></plist>',
      );

      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/claude-new',
      );

      await adapter.createProfile(app, profile);

      // Data directory exists
      expect(await Directory('$tempDir/claude-new').exists(), isTrue);

      // Wrapper .app exists
      final wrapperPath = '$tempDir/claude-new/Claude.app';
      expect(await Directory(wrapperPath).exists(), isTrue);

      // Info.plist is a real file (not symlink), others are symlinks
      expect(await FileSystemEntity.isLink('$wrapperPath/Contents/Info.plist'),
          isFalse);
      expect(await FileSystemEntity.isLink('$wrapperPath/Contents/MacOS'),
          isTrue);
      expect(await FileSystemEntity.isLink('$wrapperPath/Contents/Frameworks'),
          isTrue);
      expect(await FileSystemEntity.isLink('$wrapperPath/Contents/Resources'),
          isTrue);
    });

    test('resetProfile deletes data directory and wrapper', () async {
      final profileDir = Directory('$tempDir/claude-reset');
      await profileDir.create(recursive: true);
      await Directory('$tempDir/claude-reset/Claude.app')
          .create(recursive: true);
      await File('${profileDir.path}/session.json').writeAsString('{}');

      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
        dataDirectory: profileDir.path,
      );

      await adapter.resetProfile(profile);
      expect(await profileDir.exists(), isFalse);
    });

    test('buildLaunchPlan includes auth warning', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.anthropic.claudefordesktop',
        displayName: 'Claude',
        appPath: '/Applications/Claude.app',
      );
      final now = DateTime.now();
      final profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.anthropic.claudefordesktop',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '$tempDir/claude-work',
      );

      Directory('$tempDir/claude-work/Claude.app').createSync(recursive: true);

      final plan = adapter.buildLaunchPlan(app, profile);
      expect(plan.warnings,
          anyElement(contains('close all other Claude windows')));
      expect(plan.deepLinkRoute, isNotNull);
      expect(plan.deepLinkRoute!.scheme, 'claude');
      expect(plan.deepLinkRoute!.targetAppPath,
          '$tempDir/claude-work/Claude.app');
      expect(plan.deepLinkRoute!.fallbackBundleId,
          'com.anthropic.claudefordesktop');
    });
  });
}
