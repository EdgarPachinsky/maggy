import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:magic/domain/models/models.dart';

part 'database.g.dart';

/// Table for discovered applications.
class Apps extends Table {
  TextColumn get bundleIdentifier => text()();
  TextColumn get displayName => text()();
  TextColumn get appPath => text()();
  TextColumn get version => text().nullable()();
  TextColumn get iconPath => text().nullable()();
  TextColumn get executablePath => text().nullable()();
  TextColumn get adapterID => text().nullable()();
  TextColumn get compatibilityStatus => text().withDefault(const Constant('unknown'))();

  @override
  Set<Column> get primaryKey => {bundleIdentifier};
}

/// Table for Magic profiles.
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get appBundleIdentifier =>
      text().references(Apps, #bundleIdentifier)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get dataDirectory => text()();
  TextColumn get launchArguments =>
      text().withDefault(const Constant('[]'))();
  TextColumn get environmentVariables =>
      text().withDefault(const Constant('{}'))();
  TextColumn get status =>
      text().withDefault(const Constant('ready'))();
  IntColumn get storageBytes => integer().nullable()();
  TextColumn get adapterVersion => text().nullable()();

  /// Added in schema 2: profile colour (ARGB) and emoji.
  IntColumn get color => integer().nullable()();
  TextColumn get emoji => text().nullable()();

  /// Added in schema 3: open this profile when the user logs in.
  BoolColumn get launchAtLogin =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pinned (favourite) apps, shown first. Kept separate from [Apps] because
/// every scan replaces the whole app catalogue. Added in schema 3.
class PinnedApps extends Table {
  TextColumn get bundleIdentifier => text()();
  DateTimeColumn get pinnedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bundleIdentifier};
}

@DriftDatabase(tables: [Apps, Profiles, PinnedApps])
class MagicDatabase extends _$MagicDatabase {
  MagicDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(profiles, profiles.color);
            await m.addColumn(profiles, profiles.emoji);
          }
          if (from < 3) {
            await m.addColumn(profiles, profiles.launchAtLogin);
            await m.createTable(pinnedApps);
          }
        },
      );

  // ── App operations ──

  Future<List<AppDescriptor>> getAllApps() async {
    final rows = await select(apps).get();
    return rows.map(_appFromRow).toList();
  }

  Future<AppDescriptor?> getAppByBundleId(String bundleId) async {
    final row = await (select(apps)
          ..where((t) => t.bundleIdentifier.equals(bundleId)))
        .getSingleOrNull();
    return row == null ? null : _appFromRow(row);
  }

  Future<void> upsertApp(AppDescriptor app) async {
    await into(apps).insertOnConflictUpdate(_appToCompanion(app));
  }

  Future<void> replaceAllApps(List<AppDescriptor> appList) async {
    await transaction(() async {
      await delete(apps).go();
      for (final app in appList) {
        await into(apps).insert(_appToCompanion(app));
      }
    });
  }

  Stream<List<AppDescriptor>> watchAllApps() {
    return select(apps).watch().map(
          (rows) => rows.map(_appFromRow).toList(),
        );
  }

  // ── Pinned apps ──

  Stream<Set<String>> watchPinnedApps() {
    return select(pinnedApps)
        .watch()
        .map((rows) => {for (final r in rows) r.bundleIdentifier});
  }

  Future<void> setAppPinned(String bundleId, bool pinned) async {
    if (pinned) {
      await into(pinnedApps).insertOnConflictUpdate(PinnedAppsCompanion.insert(
        bundleIdentifier: bundleId,
        pinnedAt: DateTime.now(),
      ));
    } else {
      await (delete(pinnedApps)..where((t) => t.bundleIdentifier.equals(bundleId)))
          .go();
    }
  }

  // ── Profile operations ──

  Future<List<MagicProfile>> getProfilesByApp(String bundleId) async {
    final rows = await (select(profiles)
          ..where((t) => t.appBundleIdentifier.equals(bundleId)))
        .get();
    return rows.map(_profileFromRow).toList();
  }

  Future<MagicProfile?> getProfileById(String id) async {
    final row = await (select(profiles)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _profileFromRow(row);
  }

  Future<void> insertProfile(MagicProfile profile) async {
    await into(profiles).insert(_profileToCompanion(profile));
  }

  Future<void> updateProfile(MagicProfile profile) async {
    await (update(profiles)..where((t) => t.id.equals(profile.id)))
        .write(_profileToCompanion(profile));
  }

  Future<void> deleteProfile(String id) async {
    await (delete(profiles)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<MagicProfile>> watchProfilesByApp(String bundleId) {
    return (select(profiles)
          ..where((t) => t.appBundleIdentifier.equals(bundleId)))
        .watch()
        .map((rows) => rows.map(_profileFromRow).toList());
  }

  Stream<List<MagicProfile>> watchAllProfiles() {
    return select(profiles)
        .watch()
        .map((rows) => rows.map(_profileFromRow).toList());
  }

  // ── Mappers ──

  static AppDescriptor _appFromRow(App row) {
    return AppDescriptor(
      bundleIdentifier: row.bundleIdentifier,
      displayName: row.displayName,
      appPath: row.appPath,
      version: row.version,
      iconPath: row.iconPath,
      executablePath: row.executablePath,
      adapterID: row.adapterID,
      compatibilityStatus: CompatibilityStatus.values.firstWhere(
        (e) => e.name == row.compatibilityStatus,
        orElse: () => CompatibilityStatus.unknown,
      ),
    );
  }

  static AppsCompanion _appToCompanion(AppDescriptor app) {
    return AppsCompanion.insert(
      bundleIdentifier: app.bundleIdentifier,
      displayName: app.displayName,
      appPath: app.appPath,
      version: Value(app.version),
      iconPath: Value(app.iconPath),
      executablePath: Value(app.executablePath),
      adapterID: Value(app.adapterID),
      compatibilityStatus: Value(app.compatibilityStatus.name),
    );
  }

  static MagicProfile _profileFromRow(Profile row) {
    return MagicProfile(
      id: row.id,
      appBundleIdentifier: row.appBundleIdentifier,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      dataDirectory: row.dataDirectory,
      launchArguments:
          (jsonDecode(row.launchArguments) as List).cast<String>(),
      environmentVariables:
          (jsonDecode(row.environmentVariables) as Map).cast<String, String>(),
      status: ProfileStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => ProfileStatus.ready,
      ),
      storageBytes: row.storageBytes,
      adapterVersion: row.adapterVersion,
      color: row.color,
      emoji: row.emoji,
      launchAtLogin: row.launchAtLogin,
    );
  }

  static ProfilesCompanion _profileToCompanion(MagicProfile profile) {
    return ProfilesCompanion.insert(
      id: profile.id,
      appBundleIdentifier: profile.appBundleIdentifier,
      name: profile.name,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      dataDirectory: profile.dataDirectory,
      launchArguments: Value(jsonEncode(profile.launchArguments)),
      environmentVariables: Value(jsonEncode(profile.environmentVariables)),
      status: Value(profile.status.name),
      storageBytes: Value(profile.storageBytes),
      adapterVersion: Value(profile.adapterVersion),
      color: Value(profile.color),
      emoji: Value(profile.emoji),
      launchAtLogin: Value(profile.launchAtLogin),
    );
  }
}
