import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/persistence/database.dart';

void main() {
  group('MagicDatabase', () {
    late MagicDatabase db;

    setUp(() {
      db = MagicDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    group('apps', () {
      test('upsertApp and getAllApps round-trip', () async {
        const app = AppDescriptor(
          bundleIdentifier: 'com.google.Chrome',
          displayName: 'Google Chrome',
          appPath: '/Applications/Google Chrome.app',
          version: '120.0',
          compatibilityStatus: CompatibilityStatus.supported,
        );

        await db.upsertApp(app);
        final apps = await db.getAllApps();

        expect(apps, hasLength(1));
        expect(apps.first.bundleIdentifier, 'com.google.Chrome');
        expect(apps.first.displayName, 'Google Chrome');
        expect(apps.first.version, '120.0');
        expect(
            apps.first.compatibilityStatus, CompatibilityStatus.supported);
      });

      test('upsertApp updates existing entry', () async {
        const app = AppDescriptor(
          bundleIdentifier: 'com.google.Chrome',
          displayName: 'Chrome',
          appPath: '/Applications/Google Chrome.app',
        );
        await db.upsertApp(app);

        final updated = app.copyWith(displayName: 'Google Chrome Updated');
        await db.upsertApp(updated);

        final apps = await db.getAllApps();
        expect(apps, hasLength(1));
        expect(apps.first.displayName, 'Google Chrome Updated');
      });

      test('getAppByBundleId finds the right app', () async {
        const app = AppDescriptor(
          bundleIdentifier: 'com.google.Chrome',
          displayName: 'Chrome',
          appPath: '/path',
        );
        await db.upsertApp(app);

        final found = await db.getAppByBundleId('com.google.Chrome');
        expect(found, isNotNull);
        expect(found!.displayName, 'Chrome');

        final notFound = await db.getAppByBundleId('com.unknown');
        expect(notFound, isNull);
      });

      test('replaceAllApps clears and inserts', () async {
        await db.upsertApp(const AppDescriptor(
          bundleIdentifier: 'old',
          displayName: 'Old',
          appPath: '/old',
        ));

        await db.replaceAllApps([
          const AppDescriptor(
            bundleIdentifier: 'new1',
            displayName: 'New 1',
            appPath: '/new1',
          ),
          const AppDescriptor(
            bundleIdentifier: 'new2',
            displayName: 'New 2',
            appPath: '/new2',
          ),
        ]);

        final apps = await db.getAllApps();
        expect(apps, hasLength(2));
        expect(apps.map((a) => a.bundleIdentifier),
            containsAll(['new1', 'new2']));
      });
    });

    group('profiles', () {
      setUp(() async {
        // Insert an app first (foreign key).
        await db.upsertApp(const AppDescriptor(
          bundleIdentifier: 'com.google.Chrome',
          displayName: 'Chrome',
          appPath: '/path',
        ));
      });

      MagicProfile makeProfile({
        String id = 'p1',
        String name = 'Work',
      }) {
        final now = DateTime(2025, 1, 1);
        return MagicProfile(
          id: id,
          appBundleIdentifier: 'com.google.Chrome',
          name: name,
          createdAt: now,
          updatedAt: now,
          dataDirectory: '/tmp/profiles/$id',
          launchArguments: ['--arg1'],
          environmentVariables: {'KEY': 'value'},
          status: ProfileStatus.ready,
          storageBytes: 1024,
        );
      }

      test('insert and retrieve profile', () async {
        await db.insertProfile(makeProfile());
        final profile = await db.getProfileById('p1');
        expect(profile, isNotNull);
        expect(profile!.name, 'Work');
        expect(profile.launchArguments, ['--arg1']);
        expect(profile.environmentVariables, {'KEY': 'value'});
        expect(profile.storageBytes, 1024);
        expect(profile.status, ProfileStatus.ready);
      });

      test('getProfilesByApp filters correctly', () async {
        await db.insertProfile(makeProfile(id: 'p1', name: 'Work'));
        await db.insertProfile(makeProfile(id: 'p2', name: 'Personal'));

        final profiles =
            await db.getProfilesByApp('com.google.Chrome');
        expect(profiles, hasLength(2));

        final empty = await db.getProfilesByApp('com.other');
        expect(empty, isEmpty);
      });

      test('updateProfile changes fields', () async {
        await db.insertProfile(makeProfile());
        final updated =
            makeProfile().copyWith(name: 'Personal', status: ProfileStatus.running);
        await db.updateProfile(updated);

        final profile = await db.getProfileById('p1');
        expect(profile!.name, 'Personal');
        expect(profile.status, ProfileStatus.running);
      });

      test('deleteProfile removes the record', () async {
        await db.insertProfile(makeProfile());
        await db.deleteProfile('p1');
        final profile = await db.getProfileById('p1');
        expect(profile, isNull);
      });
    });
  });
}
