import 'app_adapter.dart';

/// Central registry that maps bundle identifiers to their adapter.
class AdapterRegistry {
  final List<AppAdapter> _adapters;
  final Map<String, AppAdapter> _index = {};

  AdapterRegistry(this._adapters) {
    for (final adapter in _adapters) {
      for (final bundleId in adapter.supportedBundleIdentifiers) {
        _index[bundleId] = adapter;
      }
    }
  }

  /// All registered adapters.
  List<AppAdapter> get adapters => List.unmodifiable(_adapters);

  /// Find the adapter for a given bundle identifier, or null.
  AppAdapter? findAdapter(String bundleId) => _index[bundleId];

  /// Whether any adapter supports this bundle identifier.
  bool isSupported(String bundleId) => _index.containsKey(bundleId);
}
