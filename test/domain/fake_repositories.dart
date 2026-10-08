import 'dart:async';

import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/app_repository.dart';
import 'package:magic/domain/repositories/profile_repository.dart';

/// In-memory fake [AppRepository] for testing.
class FakeAppRepository implements AppRepository {
  final List<AppDescriptor> storedApps = [];
  final _controller = StreamController<List<AppDescriptor>>.broadcast();

  @override
  Future<List<AppDescriptor>> getAll() async => List.of(storedApps);

  @override
  Future<AppDescriptor?> getByBundleId(String bundleId) async {
    return storedApps
        .where((a) => a.bundleIdentifier == bundleId)
        .firstOrNull;
  }

  @override
  Future<void> upsert(AppDescriptor app) async {
    storedApps.removeWhere((a) => a.bundleIdentifier == app.bundleIdentifier);
    storedApps.add(app);
    _controller.add(List.of(storedApps));
  }

  @override
  Future<void> replaceAll(List<AppDescriptor> apps) async {
    storedApps
      ..clear()
      ..addAll(apps);
    _controller.add(List.of(storedApps));
  }

  @override
  Stream<List<AppDescriptor>> watchAll() => _controller.stream;

  final Set<String> pinned = {};
  final _pinnedController = StreamController<Set<String>>.broadcast();

  @override
  Stream<Set<String>> watchPinned() => _pinnedController.stream;

  @override
  Future<void> setPinned(String bundleId, bool value) async {
    value ? pinned.add(bundleId) : pinned.remove(bundleId);
    _pinnedController.add(Set.of(pinned));
  }
}

/// In-memory fake [ProfileRepository] for testing.
class FakeProfileRepository implements ProfileRepository {
  final List<MagicProfile> storedProfiles = [];
  final _controller = StreamController<List<MagicProfile>>.broadcast();

  @override
  Future<List<MagicProfile>> getByApp(String bundleId) async {
    return storedProfiles
        .where((p) => p.appBundleIdentifier == bundleId)
        .toList();
  }

  @override
  Future<MagicProfile?> getById(String id) async {
    return storedProfiles.where((p) => p.id == id).firstOrNull;
  }

  @override
  Future<void> insert(MagicProfile profile) async {
    storedProfiles.add(profile);
    _controller.add(List.of(storedProfiles));
  }

  @override
  Future<void> update(MagicProfile profile) async {
    storedProfiles.removeWhere((p) => p.id == profile.id);
    storedProfiles.add(profile);
    _controller.add(List.of(storedProfiles));
  }

  @override
  Future<void> delete(String id) async {
    storedProfiles.removeWhere((p) => p.id == id);
    _controller.add(List.of(storedProfiles));
  }

  @override
  Stream<List<MagicProfile>> watchByApp(String bundleId) {
    return _controller.stream
        .map((all) => all.where((p) => p.appBundleIdentifier == bundleId).toList());
  }

  @override
  Stream<List<MagicProfile>> watchAll() => _controller.stream;
}
