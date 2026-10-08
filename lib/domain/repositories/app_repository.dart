import '../models/models.dart';

/// Persistence contract for discovered applications.
abstract class AppRepository {
  /// Return all known applications.
  Future<List<AppDescriptor>> getAll();

  /// Find an app by bundle identifier.
  Future<AppDescriptor?> getByBundleId(String bundleId);

  /// Insert or update an application record.
  Future<void> upsert(AppDescriptor app);

  /// Replace the full catalog (used after a scan).
  Future<void> replaceAll(List<AppDescriptor> apps);

  /// Watch all apps as a stream.
  Stream<List<AppDescriptor>> watchAll();

  /// Watch the bundle IDs of pinned (favourite) apps.
  Stream<Set<String>> watchPinned();

  /// Pin or unpin an app.
  Future<void> setPinned(String bundleId, bool pinned);
}
