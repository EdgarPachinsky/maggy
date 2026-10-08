import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/services/storage_service.dart';

import '../../infrastructure/platform/fake_platform_api.dart';

void main() {
  group('StorageService.clearCache', () {
    late Directory dataDir;
    late Directory outside;
    late MagicProfile profile;
    late StorageService service;

    setUp(() async {
      dataDir = await Directory.systemTemp.createTemp('maggy_storage_');
      outside = await Directory.systemTemp.createTemp('maggy_outside_');
      final now = DateTime.now();
      profile = MagicProfile(
        id: 'p1',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Work',
        createdAt: now,
        updatedAt: now,
        dataDirectory: dataDir.path,
      );
      service = StorageService(platformApi: FakePlatformApi());
    });

    tearDown(() async {
      for (final d in [dataDir, outside]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    test('removes cache folders and keeps everything else', () async {
      final cache = Directory('${dataDir.path}/Default/Cache')
        ..createSync(recursive: true);
      File('${cache.path}/data_0').writeAsStringSync('x');
      final prefs = File('${dataDir.path}/Default/Preferences')
        ..writeAsStringSync('{}');
      final gpu = Directory('${dataDir.path}/GPUCache')..createSync();

      await service.clearCache(profile);

      expect(cache.existsSync(), isFalse);
      expect(gpu.existsSync(), isFalse);
      expect(prefs.existsSync(), isTrue);
    });

    test('does not follow a symlink named like a cache folder', () async {
      final keep = File('${outside.path}/keep.txt')..writeAsStringSync('x');
      Link('${dataDir.path}/Cache').createSync(outside.path);

      await service.clearCache(profile);

      expect(keep.existsSync(), isTrue);
    });
  });

  group('LaunchPlan.newAppInstance', () {
    test('mirrors the open -na command', () {
      final plan = LaunchPlan.newAppInstance(
        appPath: '/Applications/Google Chrome.app',
        appArguments: ['--user-data-dir=/tmp/x'],
      );
      expect(plan.executablePath, '/usr/bin/open');
      expect(plan.arguments,
          ['-na', '/Applications/Google Chrome.app', '--args', '--user-data-dir=/tmp/x']);
      expect(plan.appBundlePath, '/Applications/Google Chrome.app');
      expect(plan.appArguments, ['--user-data-dir=/tmp/x']);
    });
  });

  group('MagicProfile appearance', () {
    final now = DateTime(2026);
    final profile = MagicProfile(
      id: 'abc',
      appBundleIdentifier: 'x',
      name: 'work',
      createdAt: now,
      updatedAt: now,
      dataDirectory: '/tmp/x',
    );

    test('automatic colour is stable and from the palette', () {
      expect(MagicProfile.palette, contains(profile.displayColor));
      expect(profile.displayColor, profile.copyWith().displayColor);
    });

    test('badge label is the emoji or the capitalised initial', () {
      expect(profile.badgeLabel, 'W');
      final withEmoji = profile.withAppearance(color: null, emoji: '💼');
      expect(withEmoji.badgeLabel, '💼');
      expect(withEmoji.withAppearance(color: 0xFF000000, emoji: '  ').emoji,
          isNull);
    });
  });
}
