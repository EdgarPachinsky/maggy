import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

import 'web_app_launcher.dart';

/// Adapter for Telegram.
///
/// - **Telegram Desktop** (from telegram.org, `com.tdesktop.Telegram`):
///   launched natively with `-workdir <profile dir>`, which Telegram
///   supports for running separate instances side by side. Full isolation.
/// - **Telegram for macOS** (`ru.keepcoder.Telegram`) and the App Store
///   build of Telegram Desktop are sandboxed and can't use another data
///   folder, so profiles run Telegram Web in their own Chromium window.
class TelegramAdapter implements AppAdapter {
  static const desktopBundleId = 'com.tdesktop.Telegram';
  static const nativeMacBundleId = 'ru.keepcoder.Telegram';
  static const webUrl = 'https://web.telegram.org/a/';

  /// Finds the browser used to host Telegram Web (injectable for tests).
  final String? Function() findBrowser;

  TelegramAdapter({this.findBrowser = ChromiumBrowserLocator.find});

  @override
  String get identifier => 'telegram';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        desktopBundleId,
        nativeMacBundleId,
        'org.telegram.desktop', // App Store build of Telegram Desktop
      };

  bool _isDesktop(AppDescriptor app) => app.bundleIdentifier == desktopBundleId;

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
    if (_isDesktop(app)) return CompatibilityStatus.supported;
    return findBrowser() == null
        ? CompatibilityStatus.experimental
        : CompatibilityStatus.supportedWithLimitations;
  }

  @override
  Future<void> createProfile(AppDescriptor app, MagicProfile profile) async {
    await Directory(profile.dataDirectory).create(recursive: true);
  }

  @override
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile) {
    if (_isDesktop(app)) {
      return LaunchPlan.newAppInstance(
        appPath: app.appPath,
        appArguments: [
          '-workdir',
          profile.dataDirectory,
          ...profile.launchArguments,
        ],
        environment: profile.environmentVariables,
      );
    }

    return webAppLaunchPlan(
      url: webUrl,
      appName: 'Telegram',
      profile: profile,
      browserPath: findBrowser(),
      extraWarnings: [
        if (app.bundleIdentifier == nativeMacBundleId)
          'Tip: Telegram for macOS can also hold up to 3 accounts itself '
              '(Settings → Add Account).',
      ],
    );
  }

  @override
  Future<bool> validate(MagicProfile profile) async {
    return Directory(profile.dataDirectory).existsSync();
  }

  @override
  Future<void> resetProfile(MagicProfile profile) async {
    final dir = Directory(profile.dataDirectory);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
