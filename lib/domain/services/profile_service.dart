import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/app_repository.dart';
import 'package:magic/domain/repositories/profile_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages profile lifecycle: creation, validation, launch planning, reset.
class ProfileService {
  final ProfileRepository _profileRepo;
  final AppRepository _appRepo;
  final List<AppAdapter> _adapters;
  final String _baseDataDir;
  final Uuid _uuid = const Uuid();

  ProfileService({
    required ProfileRepository profileRepo,
    required AppRepository appRepo,
    required List<AppAdapter> adapters,
    required String baseDataDir,
  })  : _profileRepo = profileRepo,
        _appRepo = appRepo,
        _adapters = adapters,
        _baseDataDir = baseDataDir;

  /// Create a new profile for the given app.
  Future<MagicProfile> createProfile({
    required String bundleId,
    required String name,
    List<String> launchArguments = const [],
    Map<String, String> environmentVariables = const {},
  }) async {
    final app = await _appRepo.getByBundleId(bundleId);
    if (app == null) {
      throw ArgumentError('Unknown application: $bundleId');
    }

    final id = _uuid.v4();
    final now = DateTime.now();
    final dataDir =
        '$_baseDataDir/profiles/${app.bundleIdentifier}/$id';

    final profile = MagicProfile(
      id: id,
      appBundleIdentifier: bundleId,
      name: name,
      createdAt: now,
      updatedAt: now,
      dataDirectory: dataDir,
      launchArguments: launchArguments,
      environmentVariables: environmentVariables,
      adapterVersion: app.adapterID,
    );

    // Let the adapter set up the data directory.
    final adapter = _findAdapter(bundleId);
    if (adapter != null) {
      await adapter.createProfile(app, profile);
    } else {
      // For unsupported apps, just create the directory.
      await Directory(dataDir).create(recursive: true);
    }

    await _profileRepo.insert(profile);
    return profile;
  }

  /// Build a launch plan for the given profile.
  Future<LaunchPlan> buildLaunchPlan(String profileId) async {
    final profile = await _profileRepo.getById(profileId);
    if (profile == null) {
      throw ArgumentError('Unknown profile: $profileId');
    }

    final app = await _appRepo.getByBundleId(profile.appBundleIdentifier);
    if (app == null) {
      throw StateError('App not found for profile: ${profile.appBundleIdentifier}');
    }

    final adapter = _findAdapter(profile.appBundleIdentifier);
    if (adapter != null) {
      return adapter.buildLaunchPlan(app, profile);
    }

    // Generic fallback: launch the app with the profile's custom args/env.
    return LaunchPlan(
      executablePath: app.executablePath ?? '${app.appPath}/Contents/MacOS/${app.displayName}',
      arguments: profile.launchArguments,
      environment: profile.environmentVariables,
      warnings: [
        'No dedicated adapter for ${app.displayName}. '
            'Profile isolation is not guaranteed.',
      ],
    );
  }

  /// Delete all data for a profile (reset). Only touches Magic-owned paths.
  Future<void> resetProfile(String profileId) async {
    final profile = await _profileRepo.getById(profileId);
    if (profile == null) {
      throw ArgumentError('Unknown profile: $profileId');
    }

    // Safety: only delete directories under our base data dir.
    if (!profile.dataDirectory.startsWith(_baseDataDir)) {
      throw StateError(
        'Refusing to delete directory outside Maggy data: '
        '${profile.dataDirectory}',
      );
    }

    final adapter = _findAdapter(profile.appBundleIdentifier);
    if (adapter != null) {
      await adapter.resetProfile(profile);
    } else {
      final dir = Directory(profile.dataDirectory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }

    await _profileRepo.delete(profileId);
  }

  /// Rename a profile. The data directory is unchanged.
  Future<MagicProfile> renameProfile(String profileId, String newName) async {
    final name = newName.trim();
    if (name.isEmpty) {
      throw ArgumentError('Profile name cannot be empty');
    }

    final profile = await _profileRepo.getById(profileId);
    if (profile == null) {
      throw ArgumentError('Unknown profile: $profileId');
    }
    if (profile.name == name) return profile;

    final renamed = profile.copyWith(name: name, updatedAt: DateTime.now());
    await _profileRepo.update(renamed);
    await _notifyAdapter(renamed);
    return renamed;
  }

  /// Set a profile's colour (ARGB, `null` = automatic) and emoji
  /// (`null`/empty = none).
  Future<MagicProfile> updateAppearance(
    String profileId, {
    required int? color,
    required String? emoji,
  }) async {
    final profile = await _profileRepo.getById(profileId);
    if (profile == null) {
      throw ArgumentError('Unknown profile: $profileId');
    }
    final updated = profile.withAppearance(color: color, emoji: emoji);
    await _profileRepo.update(updated);
    await _notifyAdapter(updated);
    return updated;
  }

  /// Turn "open at login" on or off for a profile.
  Future<MagicProfile> setLaunchAtLogin(String profileId, bool enabled) async {
    final profile = await _profileRepo.getById(profileId);
    if (profile == null) {
      throw ArgumentError('Unknown profile: $profileId');
    }
    final updated =
        profile.copyWith(launchAtLogin: enabled, updatedAt: DateTime.now());
    await _profileRepo.update(updated);
    return updated;
  }

  /// Let adapters that mirror profile details elsewhere follow along.
  /// A failure here must not undo the change.
  Future<void> _notifyAdapter(MagicProfile profile) async {
    final adapter = _findAdapter(profile.appBundleIdentifier);
    if (adapter is! ProfileUpdateAware) return;
    final app = await _appRepo.getByBundleId(profile.appBundleIdentifier);
    if (app == null) return;
    try {
      await (adapter as ProfileUpdateAware).onProfileUpdated(app, profile);
    } catch (_) {}
  }

  /// Get all profiles for a given app.
  Future<List<MagicProfile>> getProfilesForApp(String bundleId) {
    return _profileRepo.getByApp(bundleId);
  }

  AppAdapter? _findAdapter(String bundleId) {
    for (final adapter in _adapters) {
      if (adapter.supportedBundleIdentifiers.contains(bundleId)) {
        return adapter;
      }
    }
    return null;
  }
}
