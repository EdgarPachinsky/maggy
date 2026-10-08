/// Fully resolved instructions for launching a profiled app instance.
///
/// Built by an adapter in Dart, then handed to the Swift bridge for execution.
class LaunchPlan {
  final String executablePath;
  final List<String> arguments;
  final Map<String, String> environment;
  final String? workingDirectory;
  final List<String> warnings;

  /// When set, the next deep link for [DeepLinkRoute.scheme] is routed to
  /// this launched instance instead of the system default handler.
  final DeepLinkRoute? deepLinkRoute;

  /// When set, launch this .app bundle as a new instance through macOS
  /// (gives the real app PID and passes [environment] through), instead of
  /// running [executablePath].
  final String? appBundlePath;

  /// Arguments for the app when launched via [appBundlePath].
  final List<String> appArguments;

  const LaunchPlan({
    required this.executablePath,
    this.arguments = const [],
    this.environment = const {},
    this.workingDirectory,
    this.warnings = const [],
    this.deepLinkRoute,
    this.appBundlePath,
    this.appArguments = const [],
  });

  /// Plan for a new instance of the app at [appPath].
  ///
  /// [executablePath]/[arguments] describe the equivalent
  /// `open -na <app> --args ...` command (useful for logs and tests).
  LaunchPlan.newAppInstance({
    required String appPath,
    this.appArguments = const [],
    this.environment = const {},
    this.warnings = const [],
    this.deepLinkRoute,
  })  : executablePath = '/usr/bin/open',
        arguments = ['-na', appPath, '--args', ...appArguments],
        workingDirectory = null,
        appBundlePath = appPath;

  @override
  String toString() =>
      'LaunchPlan($executablePath, args=${arguments.length}, '
      'env=${environment.length}, warnings=${warnings.length})';
}

/// Tells Magic to catch the next `scheme://` link (e.g. an OAuth callback)
/// and forward it to the app bundle at [targetAppPath].
class DeepLinkRoute {
  final String scheme;
  final String targetAppPath;

  /// Bundle ID that normally handles [scheme]; links go there when the
  /// target instance is no longer running.
  final String? fallbackBundleId;

  const DeepLinkRoute({
    required this.scheme,
    required this.targetAppPath,
    this.fallbackBundleId,
  });

  @override
  String toString() => 'DeepLinkRoute($scheme -> $targetAppPath)';
}
