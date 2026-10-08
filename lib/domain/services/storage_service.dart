import 'dart:io';

import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';
import 'package:path/path.dart' as p;

/// Disk usage and cache cleanup for profile data directories.
///
/// Only ever touches folders inside a profile's own data directory.
class StorageService {
  final MagicPlatformApi _platformApi;

  StorageService({required MagicPlatformApi platformApi})
      : _platformApi = platformApi;

  /// Known cache folders, relative to a profile's data directory. Deleting
  /// them only costs re-downloading/re-building caches; logins, cookies,
  /// settings and extensions are untouched.
  static const cacheFolders = <String>[
    // Chromium browsers (--user-data-dir, "Default" profile)
    'Default/Cache',
    'Default/Code Cache',
    'Default/GPUCache',
    'Default/DawnCache',
    'Default/DawnGraphiteCache',
    'Default/DawnWebGPUCache',
    'GrShaderCache',
    'GraphiteDawnCache',
    'ShaderCache',
    'component_crx_cache',
    // Electron apps (Claude, VS Code)
    'Cache',
    'Code Cache',
    'GPUCache',
    'DawnCache',
    'DawnGraphiteCache',
    'DawnWebGPUCache',
    'CachedData',
    'CachedExtensionVSIXs',
    // Firefox
    'cache2',
    'startupCache',
    'shader-cache',
  ];

  /// Total size of the profile's data directory in bytes.
  Future<int> sizeOf(MagicProfile profile) =>
      _platformApi.directorySize(profile.dataDirectory);

  /// Delete the profile's cache folders. Returns the bytes freed.
  ///
  /// Call only while the profile's app is not running.
  Future<int> clearCache(MagicProfile profile) async {
    final root = p.normalize(profile.dataDirectory);
    var freed = 0;
    for (final relative in cacheFolders) {
      final path = p.normalize(p.join(root, relative));
      if (!p.isWithin(root, path)) continue;
      // Real directories only: never follow symlinks (e.g. Claude's wrapper
      // links to the original app).
      if (FileSystemEntity.typeSync(path, followLinks: false) !=
          FileSystemEntityType.directory) {
        continue;
      }
      freed += await _platformApi.directorySize(path);
      await Directory(path).delete(recursive: true);
    }
    return freed;
  }

  /// Show the profile's data directory in Finder.
  Future<void> reveal(MagicProfile profile) =>
      _platformApi.revealInFinder(profile.dataDirectory);
}
