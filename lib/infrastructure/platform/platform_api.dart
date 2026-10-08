/// Data class for an app discovered by the native platform plugin.
class PlatformAppInfo {
  final String bundleIdentifier;
  final String displayName;
  final String appPath;
  final String? version;
  final String? iconPath;
  final String? executablePath;

  const PlatformAppInfo({
    required this.bundleIdentifier,
    required this.displayName,
    required this.appPath,
    this.version,
    this.iconPath,
    this.executablePath,
  });
}

/// Result of a process launch.
class PlatformLaunchResult {
  final int pid;
  final bool success;
  final String? errorMessage;

  const PlatformLaunchResult({
    required this.pid,
    required this.success,
    this.errorMessage,
  });
}

/// One step of an app scan, reported while [MagicPlatformApi.discoverApps]
/// runs.
class ScanProgress {
  /// 1-based position of the app being read.
  final int index;
  final int total;
  final String appName;

  const ScanProgress({
    required this.index,
    required this.total,
    required this.appName,
  });
}

/// One profile row in the menu bar launcher.
class StatusMenuEntry {
  final String profileId;
  final String name;
  final String appName;
  final bool running;

  /// ARGB colour dot shown next to the name.
  final int color;
  final String? emoji;

  const StatusMenuEntry({
    required this.profileId,
    required this.name,
    required this.appName,
    required this.running,
    required this.color,
    this.emoji,
  });

  Map<String, Object?> toMap() => {
        'profileId': profileId,
        'name': name,
        'appName': appName,
        'running': running,
        'color': color,
        'emoji': emoji,
      };
}

/// Contract for the native platform bridge.
///
/// Implemented via MethodChannel on macOS, with a fake for testing.
abstract class MagicPlatformApi {
  /// Discover installed applications.
  Future<List<PlatformAppInfo>> discoverApps();

  /// Progress events emitted while [discoverApps] runs.
  Stream<ScanProgress> get scanProgress;

  /// Launch a process with the given executable, arguments, and environment.
  Future<PlatformLaunchResult> launchProcess({
    required String executablePath,
    required List<String> arguments,
    required Map<String, String> environment,
    String? workingDirectory,
  });

  /// Launch the .app bundle at [appPath] as a new instance via macOS.
  /// The returned PID is the app's own process.
  Future<PlatformLaunchResult> launchApp({
    required String appPath,
    required List<String> arguments,
    required Map<String, String> environment,
  });

  /// Find running apps whose launch arguments contain a profile's data
  /// directory. [markers] maps profile ID → data directory; returns
  /// profile ID → PID for the ones that are running.
  Future<Map<String, int>> findRunningProfiles(Map<String, String> markers);

  /// Bring the app with [pid] to the front.
  Future<bool> activateProcess(int pid);

  /// Ask the app with [pid] to quit (like Cmd-Q).
  Future<bool> terminateProcess(int pid);

  /// Give the app bundle at [targetAppPath] the icon of [sourceAppPath]
  /// with a coloured badge (ARGB [color]) showing [label].
  Future<void> setBadgedAppIcon({
    required String targetAppPath,
    required String sourceAppPath,
    required int color,
    required String label,
  });

  /// Running Dock apps: bundle ID → number of running instances.
  Future<Map<String, int>> runningAppCounts();

  /// Quit every running instance of [bundleId]. With [force], like
  /// Force Quit (unsaved work is lost). Returns how many were signalled.
  Future<int> quitApp(String bundleId, {bool force = false});

  /// Register/unregister Maggy as a login item. Returns the resulting
  /// status: `enabled`, `requiresApproval`, `notRegistered`, `notFound`,
  /// or `error: ...`.
  Future<String> setLoginItemEnabled(bool enabled);

  /// When the Mac last booted (seconds since epoch).
  Future<int> bootTime();

  /// Replace the profiles listed in the menu bar launcher.
  Future<void> updateStatusMenu(List<StatusMenuEntry> entries);

  /// Profile IDs clicked in the menu bar launcher.
  Stream<String> get statusMenuSelections;

  /// Check if a process with the given PID is running.
  Future<bool> isProcessRunning(int pid);

  /// Get the size of a directory in bytes.
  Future<int> directorySize(String path);

  /// Reveal a path in Finder.
  Future<void> revealInFinder(String path);

  /// Route the next `scheme://` link to the app bundle at [targetAppPath]
  /// (falling back to [fallbackBundleId] if that instance is gone).
  Future<void> armDeepLinkRoute({
    required String scheme,
    required String targetAppPath,
    String? fallbackBundleId,
  });
}
