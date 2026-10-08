import 'dart:async';

import 'package:flutter/services.dart';

import 'platform_api.dart';

/// MethodChannel-based implementation of [MagicPlatformApi] for macOS.
class MethodChannelPlatformApi implements MagicPlatformApi {
  static const _channel = MethodChannel('com.magic.platform');

  final _scanProgress = StreamController<ScanProgress>.broadcast();
  final _statusMenuSelections = StreamController<String>.broadcast();

  MethodChannelPlatformApi() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  /// Calls coming from Swift (currently only scan progress).
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'scanProgress') {
      final m = (call.arguments as Map).cast<String, dynamic>();
      _scanProgress.add(ScanProgress(
        index: m['index'] as int,
        total: m['total'] as int,
        appName: m['name'] as String,
      ));
    } else if (call.method == 'statusMenuSelected') {
      final m = (call.arguments as Map).cast<String, dynamic>();
      _statusMenuSelections.add(m['profileId'] as String);
    }
    return null;
  }

  @override
  Stream<String> get statusMenuSelections => _statusMenuSelections.stream;

  @override
  Future<PlatformLaunchResult> launchApp({
    required String appPath,
    required List<String> arguments,
    required Map<String, String> environment,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('launchApp', {
      'appPath': appPath,
      'arguments': arguments,
      'environment': environment,
    });
    return PlatformLaunchResult(
      pid: result?['pid'] as int? ?? -1,
      success: result?['success'] as bool? ?? false,
      errorMessage: result?['errorMessage'] as String?,
    );
  }

  @override
  Future<Map<String, int>> findRunningProfiles(
      Map<String, String> markers) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
        'findRunningProfiles', {'markers': markers});
    return (result ?? const {}).map((k, v) => MapEntry(k, v as int));
  }

  @override
  Future<bool> activateProcess(int pid) async {
    return await _channel.invokeMethod<bool>('activateProcess', {'pid': pid}) ??
        false;
  }

  @override
  Future<bool> terminateProcess(int pid) async {
    return await _channel.invokeMethod<bool>('terminateProcess', {'pid': pid}) ??
        false;
  }

  @override
  Future<void> setBadgedAppIcon({
    required String targetAppPath,
    required String sourceAppPath,
    required int color,
    required String label,
  }) async {
    await _channel.invokeMethod<void>('setBadgedAppIcon', {
      'targetAppPath': targetAppPath,
      'sourceAppPath': sourceAppPath,
      'color': color,
      'label': label,
    });
  }

  @override
  Future<Map<String, int>> runningAppCounts() async {
    final result =
        await _channel.invokeMapMethod<String, dynamic>('runningAppCounts');
    return (result ?? const {}).map((k, v) => MapEntry(k, v as int));
  }

  @override
  Future<int> quitApp(String bundleId, {bool force = false}) async {
    return await _channel.invokeMethod<int>(
            'quitApp', {'bundleId': bundleId, 'force': force}) ??
        0;
  }

  @override
  Future<String> setLoginItemEnabled(bool enabled) async {
    return await _channel.invokeMethod<String>(
            'setLoginItemEnabled', {'enabled': enabled}) ??
        'unknown';
  }

  @override
  Future<int> bootTime() async {
    return await _channel.invokeMethod<int>('bootTime') ?? 0;
  }

  @override
  Future<void> updateStatusMenu(List<StatusMenuEntry> entries) async {
    await _channel.invokeMethod<void>('updateStatusMenu', {
      'entries': [for (final e in entries) e.toMap()],
    });
  }

  @override
  Stream<ScanProgress> get scanProgress => _scanProgress.stream;

  @override
  Future<List<PlatformAppInfo>> discoverApps() async {
    final result = await _channel.invokeListMethod<Map>('discoverApps');
    if (result == null) return [];
    return result.map((map) {
      final m = map.cast<String, dynamic>();
      return PlatformAppInfo(
        bundleIdentifier: m['bundleIdentifier'] as String,
        displayName: m['displayName'] as String,
        appPath: m['appPath'] as String,
        version: m['version'] as String?,
        iconPath: m['iconPath'] as String?,
        executablePath: m['executablePath'] as String?,
      );
    }).toList();
  }

  @override
  Future<PlatformLaunchResult> launchProcess({
    required String executablePath,
    required List<String> arguments,
    required Map<String, String> environment,
    String? workingDirectory,
  }) async {
    final result =
        await _channel.invokeMapMethod<String, dynamic>('launchProcess', {
      'executablePath': executablePath,
      'arguments': arguments,
      'environment': environment,
      'workingDirectory': workingDirectory,
    });
    return PlatformLaunchResult(
      pid: result?['pid'] as int? ?? -1,
      success: result?['success'] as bool? ?? false,
      errorMessage: result?['errorMessage'] as String?,
    );
  }

  @override
  Future<bool> isProcessRunning(int pid) async {
    final result =
        await _channel.invokeMethod<bool>('isProcessRunning', {'pid': pid});
    return result ?? false;
  }

  @override
  Future<int> directorySize(String path) async {
    final result =
        await _channel.invokeMethod<int>('directorySize', {'path': path});
    return result ?? 0;
  }

  @override
  Future<void> revealInFinder(String path) async {
    await _channel.invokeMethod<void>('revealInFinder', {'path': path});
  }

  @override
  Future<void> armDeepLinkRoute({
    required String scheme,
    required String targetAppPath,
    String? fallbackBundleId,
  }) async {
    await _channel.invokeMethod<void>('armDeepLinkRoute', {
      'scheme': scheme,
      'targetAppPath': targetAppPath,
      'fallbackBundleId': fallbackBundleId,
    });
  }
}
