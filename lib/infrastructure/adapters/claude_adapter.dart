import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Adapter for Claude desktop app (Electron-based).
///
/// Claude uses OAuth with a `claude://` URL scheme for authentication callbacks.
/// When multiple instances of the same app are running, macOS routes deeplinks
/// to the first registered instance — so a second instance can never complete
/// authentication.
///
/// To solve this, the adapter creates a **symlink wrapper app bundle** per
/// profile with a unique `CFBundleIdentifier`. The wrapper symlinks all
/// binaries and frameworks to the original — no files are copied or re-signed,
/// so Electron's code integrity checks pass. Only `Info.plist` is customised.
///
/// The user must close all other Claude instances before authenticating a new
/// profile (so the `claude://` callback reaches the right one). After the
/// initial sign-in, all profiles can run simultaneously.
class ClaudeAdapter implements AppAdapter, ProfileUpdateAware {
  /// Used to badge each profile's wrapper icon. Optional so tests can
  /// construct the adapter without a platform bridge.
  final MagicPlatformApi? platformApi;

  ClaudeAdapter({this.platformApi});

  @override
  String get identifier => 'claude';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        'com.anthropic.claudefordesktop',
      };

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    return CompatibilityStatus.supported;
  }

  /// Path where the wrapper app bundle lives for this profile.
  String _wrapperAppPath(AppDescriptor app, MagicProfile profile) {
    final appName = app.appPath.split('/').last; // e.g. "Claude.app"
    return '${profile.dataDirectory}/$appName';
  }

  @override
  Future<void> createProfile(AppDescriptor app, MagicProfile profile) async {
    final dataDir = Directory(profile.dataDirectory);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    await _createWrapperApp(app, profile);
    await _applyIconBadge(app, profile);
  }

  /// Badge the wrapper's icon with the profile colour and initial/emoji so
  /// each Claude is easy to tell apart in the Dock and Cmd-Tab.
  Future<void> _applyIconBadge(AppDescriptor app, MagicProfile profile) async {
    final api = platformApi;
    final wrapperPath = _wrapperAppPath(app, profile);
    if (api == null || !await Directory(wrapperPath).exists()) return;
    try {
      await api.setBadgedAppIcon(
        targetAppPath: wrapperPath,
        sourceAppPath: app.appPath,
        color: profile.displayColor,
        label: profile.badgeLabel,
      );
    } catch (_) {
      // Cosmetic only; never block profile creation.
    }
  }

  /// Creates a thin wrapper .app bundle that symlinks all binaries and
  /// frameworks to the original Claude.app. Only Info.plist is a real file
  /// with a patched CFBundleIdentifier.
  ///
  /// Because the actual Electron Framework binary is the original (accessed
  /// via symlink), its code signature remains valid and Electron's startup
  /// integrity check passes.
  Future<void> _createWrapperApp(
      AppDescriptor app, MagicProfile profile) async {
    final wrapperPath = _wrapperAppPath(app, profile);
    final wrapperDir = Directory(wrapperPath);
    if (await wrapperDir.exists()) return; // already created

    // Create the Contents directory for our wrapper.
    await Directory('$wrapperPath/Contents').create(recursive: true);

    // Symlink every item in Contents/ EXCEPT Info.plist and _CodeSignature.
    // Info.plist gets a custom copy; _CodeSignature is omitted because it
    // would be invalid for our modified Info.plist.
    final originalContents = Directory('${app.appPath}/Contents');
    await for (final entity in originalContents.list()) {
      final name = entity.path.split('/').last;
      if (name == 'Info.plist' || name == '_CodeSignature') continue;
      await Link('$wrapperPath/Contents/$name').create(entity.path);
    }

    // Copy and patch Info.plist.
    final plistPath = '$wrapperPath/Contents/Info.plist';
    await File('${app.appPath}/Contents/Info.plist').copy(plistPath);

    final idSuffix = profile.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    await Process.run('/usr/libexec/PlistBuddy', [
      '-c',
      'Set :CFBundleIdentifier com.anthropic.claudefordesktop.magic.$idSuffix',
      plistPath,
    ]);
    await Process.run('/usr/libexec/PlistBuddy', [
      '-c',
      'Set :CFBundleName Claude (${profile.name})',
      plistPath,
    ]);

    // Strip quarantine so Gatekeeper doesn't block the wrapper.
    await Process.run('xattr', ['-cr', wrapperPath]);
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    final wrapperPath = _wrapperAppPath(app, profile);
    final wrapperExists = Directory(wrapperPath).existsSync();

    return LaunchPlan.newAppInstance(
      appPath: wrapperExists ? wrapperPath : app.appPath,
      appArguments: [
        '--user-data-dir=${profile.dataDirectory}',
        ...profile.launchArguments,
      ],
      environment: profile.environmentVariables,
      deepLinkRoute: wrapperExists
          ? DeepLinkRoute(
              scheme: 'claude',
              targetAppPath: wrapperPath,
              fallbackBundleId: 'com.anthropic.claudefordesktop',
            )
          : null,
      warnings: [
        if (!wrapperExists)
          'App wrapper not found. Create the profile first for independent authentication.',
        'First-time sign-in: close all other Claude windows before authenticating. '
            'Once signed in, all profiles can run simultaneously.',
      ],
    );
  }

  /// Keep the wrapper's app name and badged icon (shown in the menu bar,
  /// Dock and Cmd-Tab) in sync. A running instance picks the name up on its
  /// next launch.
  @override
  Future<void> onProfileUpdated(AppDescriptor app, MagicProfile profile) async {
    final plistPath = '${_wrapperAppPath(app, profile)}/Contents/Info.plist';
    if (!await File(plistPath).exists()) return;
    await Process.run('/usr/libexec/PlistBuddy', [
      '-c',
      'Set :CFBundleName Claude (${profile.name})',
      plistPath,
    ]);
    await _applyIconBadge(app, profile);
  }

  @override
  Future<bool> validate(MagicProfile profile) async {
    return Directory(profile.dataDirectory).existsSync();
  }

  @override
  Future<void> resetProfile(MagicProfile profile) async {
    final dir = Directory(profile.dataDirectory);
    if (await dir.exists()) {
      await dir.delete(recursive: true); // removes wrapper + Electron data
    }
  }
}
