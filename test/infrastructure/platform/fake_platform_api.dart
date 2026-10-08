import 'dart:async';

import 'package:magic/infrastructure/platform/platform_api.dart';

/// In-memory fake for testing without the native macOS plugin.
class FakePlatformApi implements MagicPlatformApi {
  List<PlatformAppInfo> appsToReturn;
  Map<int, bool> runningProcesses = {};
  Map<String, int> directorySizes = {};
  int nextPid = 1000;

  FakePlatformApi({this.appsToReturn = const []});

  /// Add events here to simulate native scan progress.
  final scanProgressController = StreamController<ScanProgress>.broadcast();

  @override
  Stream<ScanProgress> get scanProgress => scanProgressController.stream;

  @override
  Future<List<PlatformAppInfo>> discoverApps() async => appsToReturn;

  @override
  Future<PlatformLaunchResult> launchProcess({
    required String executablePath,
    required List<String> arguments,
    required Map<String, String> environment,
    String? workingDirectory,
  }) async {
    final pid = nextPid++;
    runningProcesses[pid] = true;
    return PlatformLaunchResult(pid: pid, success: true);
  }

  /// Profile ID → PID reported by [findRunningProfiles].
  Map<String, int> runningProfiles = {};
  final List<int> activatedPids = [];
  final List<int> terminatedPids = [];
  List<StatusMenuEntry> statusMenuEntries = [];
  final statusMenuController = StreamController<String>.broadcast();

  @override
  Stream<String> get statusMenuSelections => statusMenuController.stream;

  @override
  Future<PlatformLaunchResult> launchApp({
    required String appPath,
    required List<String> arguments,
    required Map<String, String> environment,
  }) async {
    final pid = nextPid++;
    runningProcesses[pid] = true;
    return PlatformLaunchResult(pid: pid, success: true);
  }

  @override
  Future<Map<String, int>> findRunningProfiles(
          Map<String, String> markers) async =>
      {
        for (final e in runningProfiles.entries)
          if (markers.containsKey(e.key)) e.key: e.value,
      };

  @override
  Future<bool> activateProcess(int pid) async {
    activatedPids.add(pid);
    return true;
  }

  @override
  Future<bool> terminateProcess(int pid) async {
    terminatedPids.add(pid);
    return true;
  }

  @override
  Future<void> setBadgedAppIcon({
    required String targetAppPath,
    required String sourceAppPath,
    required int color,
    required String label,
  }) async {}

  @override
  Future<void> updateStatusMenu(List<StatusMenuEntry> entries) async {
    statusMenuEntries = entries;
  }

  Map<String, int> runningApps = {};
  final List<(String, bool)> quitRequests = [];
  bool? loginItemEnabled;
  int bootTimeValue = 1000;

  @override
  Future<Map<String, int>> runningAppCounts() async => Map.of(runningApps);

  @override
  Future<int> quitApp(String bundleId, {bool force = false}) async {
    quitRequests.add((bundleId, force));
    return runningApps.remove(bundleId) ?? 0;
  }

  @override
  Future<String> setLoginItemEnabled(bool enabled) async {
    loginItemEnabled = enabled;
    return enabled ? 'enabled' : 'notRegistered';
  }

  @override
  Future<int> bootTime() async => bootTimeValue;

  @override
  Future<bool> isProcessRunning(int pid) async =>
      runningProcesses[pid] ?? false;

  @override
  Future<int> directorySize(String path) async =>
      directorySizes[path] ?? 0;

  @override
  Future<void> revealInFinder(String path) async {}

  /// Routes armed via [armDeepLinkRoute], in call order.
  final List<({String scheme, String targetAppPath, String? fallbackBundleId})>
      armedRoutes = [];

  @override
  Future<void> armDeepLinkRoute({
    required String scheme,
    required String targetAppPath,
    String? fallbackBundleId,
  }) async {
    armedRoutes.add((
      scheme: scheme,
      targetAppPath: targetAppPath,
      fallbackBundleId: fallbackBundleId,
    ));
  }
}
