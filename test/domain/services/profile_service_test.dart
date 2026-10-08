import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/services/profile_service.dart';

import '../fake_repositories.dart';

void main() {
  group('ProfileService', () {
    late FakeAppRepository appRepo;
    late FakeProfileRepository profileRepo;
    late ProfileService service;
    late String baseDir;

    setUp(() async {
      appRepo = FakeAppRepository();
      profileRepo = FakeProfileRepository();

      // Use a temporary directory for test isolation.
      baseDir = (await Directory.systemTemp
              .createTemp('magic_test_'))
          .path;

      // Seed an app.
      await appRepo.upsert(const AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
        executablePath:
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      ));

      service = ProfileService(
        profileRepo: profileRepo,
        appRepo: appRepo,
        adapters: [],
        baseDataDir: baseDir,
      );
    });

    tearDown(() async {
      final dir = Directory(baseDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    test('createProfile creates a profile with a data directory', () async {
      final profile = await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Work',
      );

      expect(profile.name, 'Work');
      expect(profile.appBundleIdentifier, 'com.google.Chrome');
      expect(profile.dataDirectory, startsWith(baseDir));
      expect(profile.status, ProfileStatus.ready);

      // Directory should have been created.
      expect(await Directory(profile.dataDirectory).exists(), isTrue);

      // Should be persisted.
      expect(profileRepo.storedProfiles, hasLength(1));
    });

    test('createProfile throws for unknown app', () async {
      expect(
        () => service.createProfile(
          bundleId: 'com.unknown.app',
          name: 'Test',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('buildLaunchPlan returns a generic plan when no adapter', () async {
      final profile = await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Work',
      );

      final plan = await service.buildLaunchPlan(profile.id);
      expect(plan.executablePath, contains('Google Chrome'));
      expect(plan.warnings, isNotEmpty);
    });

    test('resetProfile deletes data directory and profile record', () async {
      final profile = await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Disposable',
      );

      expect(await Directory(profile.dataDirectory).exists(), isTrue);
      expect(profileRepo.storedProfiles, hasLength(1));

      await service.resetProfile(profile.id);

      expect(await Directory(profile.dataDirectory).exists(), isFalse);
      expect(profileRepo.storedProfiles, isEmpty);
    });

    test('resetProfile refuses to delete directories outside base dir',
        () async {
      // Manually insert a profile with a bad data directory.
      final now = DateTime.now();
      final badProfile = MagicProfile(
        id: 'bad-profile',
        appBundleIdentifier: 'com.google.Chrome',
        name: 'Evil',
        createdAt: now,
        updatedAt: now,
        dataDirectory: '/tmp/definitely-not-magic',
      );
      await profileRepo.insert(badProfile);

      expect(
        () => service.resetProfile('bad-profile'),
        throwsA(isA<StateError>()),
      );
    });

    test('renameProfile updates the name and keeps the data directory',
        () async {
      final profile = await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Work',
      );

      final renamed = await service.renameProfile(profile.id, '  Client A ');

      expect(renamed.name, 'Client A');
      expect(renamed.dataDirectory, profile.dataDirectory);
      final stored = await profileRepo.getById(profile.id);
      expect(stored!.name, 'Client A');
    });

    test('renameProfile rejects an empty name', () async {
      final profile = await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Work',
      );

      expect(
        () => service.renameProfile(profile.id, '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getProfilesForApp returns profiles for the correct app', () async {
      await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Work',
      );
      await service.createProfile(
        bundleId: 'com.google.Chrome',
        name: 'Personal',
      );

      final profiles =
          await service.getProfilesForApp('com.google.Chrome');
      expect(profiles, hasLength(2));
    });
  });
}
