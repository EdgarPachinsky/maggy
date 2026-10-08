import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/app_repository.dart';

import 'database.dart';

/// Drift-backed implementation of [AppRepository].
class DriftAppRepository implements AppRepository {
  final MagicDatabase _db;

  DriftAppRepository(this._db);

  @override
  Future<List<AppDescriptor>> getAll() => _db.getAllApps();

  @override
  Future<AppDescriptor?> getByBundleId(String bundleId) =>
      _db.getAppByBundleId(bundleId);

  @override
  Future<void> upsert(AppDescriptor app) => _db.upsertApp(app);

  @override
  Future<void> replaceAll(List<AppDescriptor> apps) =>
      _db.replaceAllApps(apps);

  @override
  Stream<List<AppDescriptor>> watchAll() => _db.watchAllApps();

  @override
  Stream<Set<String>> watchPinned() => _db.watchPinnedApps();

  @override
  Future<void> setPinned(String bundleId, bool pinned) =>
      _db.setAppPinned(bundleId, pinned);
}
