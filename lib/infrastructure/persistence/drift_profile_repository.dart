import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/profile_repository.dart';

import 'database.dart';

/// Drift-backed implementation of [ProfileRepository].
class DriftProfileRepository implements ProfileRepository {
  final MagicDatabase _db;

  DriftProfileRepository(this._db);

  @override
  Future<List<MagicProfile>> getByApp(String bundleId) =>
      _db.getProfilesByApp(bundleId);

  @override
  Future<MagicProfile?> getById(String id) => _db.getProfileById(id);

  @override
  Future<void> insert(MagicProfile profile) => _db.insertProfile(profile);

  @override
  Future<void> update(MagicProfile profile) => _db.updateProfile(profile);

  @override
  Future<void> delete(String id) => _db.deleteProfile(id);

  @override
  Stream<List<MagicProfile>> watchByApp(String bundleId) =>
      _db.watchProfilesByApp(bundleId);

  @override
  Stream<List<MagicProfile>> watchAll() => _db.watchAllProfiles();
}
