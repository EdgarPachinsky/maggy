import 'dart:io';

import 'package:magic/domain/models/models.dart';

/// Finds an installed Chromium-based browser to host web apps.
class ChromiumBrowserLocator {
  /// Checked in this order, in /Applications then ~/Applications.
  static const candidates = [
    'Google Chrome.app',
    'Chromium.app',
    'Microsoft Edge.app',
    'Brave Browser.app',
    'Vivaldi.app',
  ];

  /// Path of the first installed Chromium browser, or null.
  static String? find() {
    final home = Platform.environment['HOME'];
    for (final dir in ['/Applications', if (home != null) '$home/Applications']) {
      for (final name in candidates) {
        final path = '$dir/$name';
        if (Directory(path).existsSync()) return path;
      }
    }
    return null;
  }
}

/// Launch plan that opens [url] as a standalone app window in a Chromium
/// browser, with the profile's own data directory. Each profile therefore
/// has its own cookies and login, fully separate from other profiles and
/// from your normal browser.
///
/// Used for apps whose desktop version cannot run separate accounts
/// side by side (e.g. sandboxed App Store apps).
LaunchPlan webAppLaunchPlan({
  required String url,
  required String appName,
  required MagicProfile profile,
  required String? browserPath,
  List<String> extraWarnings = const [],
}) {
  if (browserPath == null) {
    return LaunchPlan(
      executablePath: '/usr/bin/open',
      arguments: [url],
      warnings: [
        'No Chrome, Edge, Brave, Vivaldi or Chromium found, so $appName '
            'opened in your default browser without a separate profile. '
            'Install one of them to keep $appName accounts apart.',
      ],
    );
  }

  final browserName =
      browserPath.split('/').last.replaceAll(RegExp(r'\.app$'), '');
  return LaunchPlan.newAppInstance(
    appPath: browserPath,
    appArguments: [
      '--user-data-dir=${profile.dataDirectory}',
      '--app=$url',
      '--no-first-run',
      '--no-default-browser-check',
      ...profile.launchArguments,
    ],
    environment: profile.environmentVariables,
    warnings: [
      'Opens $appName Web in its own $browserName window.',
      ...extraWarnings,
    ],
  );
}
