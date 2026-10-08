import 'dart:io';

import 'package:magic/domain/adapters/app_adapter.dart';
import 'package:magic/domain/models/models.dart';

import 'web_app_launcher.dart';

/// Adapter for WhatsApp.
///
/// The Mac app is sandboxed and keeps one account per Mac user, with no
/// option to point it at another data folder, so a second copy cannot hold
/// a separate account. Instead each profile runs WhatsApp Web in its own
/// Chromium app window with its own data directory: fully separate logins,
/// several can run at once.
class WhatsAppAdapter implements AppAdapter {
  static const webUrl = 'https://web.whatsapp.com';

  /// Finds the browser used to host WhatsApp Web (injectable for tests).
  final String? Function() findBrowser;

  WhatsAppAdapter({this.findBrowser = ChromiumBrowserLocator.find});

  @override
  String get identifier => 'whatsapp';

  @override
  Set<String> get supportedBundleIdentifiers => const {
        'net.whatsapp.WhatsApp', // current native Mac app
        'WhatsApp', // older Electron desktop app
      };

  @override
  CompatibilityStatus compatibility(AppDescriptor app) {
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
    return webAppLaunchPlan(
      url: webUrl,
      appName: 'WhatsApp',
      profile: profile,
      browserPath: findBrowser(),
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
