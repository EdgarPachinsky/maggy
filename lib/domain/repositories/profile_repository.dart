import '../models/models.dart';

/// Persistence contract for Magic profiles.
abstract class ProfileRepository {
  /// All profiles for a given app.
  Future<List<MagicProfile>> getByApp(String bundleId);

  /// Find a profile by ID.
  Future<MagicProfile?> getById(String id);

  /// Insert a new profile.
  Future<void> insert(MagicProfile profile);

  /// Update an existing profile.
  Future<void> update(MagicProfile profile);

  /// Delete a profile by ID.
  Future<void> delete(String id);

  /// Watch profiles for a specific app.
  Stream<List<MagicProfile>> watchByApp(String bundleId);

  /// Watch all profiles.
  Stream<List<MagicProfile>> watchAll();
}
