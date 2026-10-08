import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/app_repository.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Scans for installed apps and enriches them with adapter compatibility info.
class AppScannerService {
  final MagicPlatformApi _platformApi;
  final AppRepository _appRepository;
  final List<AppAdapter> _adapters;

  AppScannerService({
    required MagicPlatformApi platformApi,
    required AppRepository appRepository,
    required List<AppAdapter> adapters,
  })  : _platformApi = platformApi,
        _appRepository = appRepository,
        _adapters = adapters;

  /// Discover installed apps, match them against adapters, and persist.
  Future<List<AppDescriptor>> scan() async {
    final platformApps = await _platformApi.discoverApps();

    final apps = platformApps.map((info) {
      final adapter = _findAdapter(info.bundleIdentifier);
      final generic = _findGenericAdapter();
      final effectiveAdapter = adapter ?? generic;
      final descriptor = AppDescriptor(
        bundleIdentifier: info.bundleIdentifier,
        displayName: info.displayName,
        appPath: info.appPath,
        version: info.version,
        iconPath: info.iconPath,
        executablePath: info.executablePath,
        adapterID: effectiveAdapter?.identifier,
      );
      if (effectiveAdapter != null) {
        return descriptor.copyWith(
          compatibilityStatus: effectiveAdapter.compatibility(descriptor),
        );
      }
      return descriptor;
    }).toList();

    // Sort by display name.
    apps.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

    await _appRepository.replaceAll(apps);
    return apps;
  }

  AppAdapter? _findAdapter(String bundleId) {
    for (final adapter in _adapters) {
      if (adapter.supportedBundleIdentifiers.contains(bundleId)) {
        return adapter;
      }
    }
    return null;
  }

  AppAdapter? _findGenericAdapter() {
    for (final adapter in _adapters) {
      if (adapter.identifier == 'generic') {
        return adapter;
      }
    }
    return null;
  }
}
