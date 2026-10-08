import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/services/profile_service.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Orchestrates building a launch plan and executing it via the platform bridge.
class LaunchService {
  final ProfileService _profileService;
  final MagicPlatformApi _platformApi;

  LaunchService({
    required ProfileService profileService,
    required MagicPlatformApi platformApi,
  })  : _profileService = profileService,
        _platformApi = platformApi;

  /// Build the launch plan for [profileId] and execute it.
  ///
  /// Returns the launch result. Warnings from the plan are included
  /// so the caller can display them.
  Future<LaunchOutcome> launch(String profileId) async {
    final plan = await _profileService.buildLaunchPlan(profileId);

    final appBundlePath = plan.appBundlePath;
    final result = appBundlePath != null
        ? await _platformApi.launchApp(
            appPath: appBundlePath,
            arguments: plan.appArguments,
            environment: plan.environment,
          )
        : await _platformApi.launchProcess(
            executablePath: plan.executablePath,
            arguments: plan.arguments,
            environment: plan.environment,
            workingDirectory: plan.workingDirectory,
          );

    final warnings = [...plan.warnings];
    final route = plan.deepLinkRoute;
    if (result.success && route != null) {
      try {
        await _platformApi.armDeepLinkRoute(
          scheme: route.scheme,
          targetAppPath: route.targetAppPath,
          fallbackBundleId: route.fallbackBundleId,
        );
      } catch (e) {
        warnings.add('Could not set up ${route.scheme}:// sign-in routing: $e');
      }
    }

    return LaunchOutcome(
      pid: result.pid,
      success: result.success,
      errorMessage: result.errorMessage,
      warnings: warnings,
    );
  }
}

/// Result of a profile launch attempt.
class LaunchOutcome {
  final int pid;
  final bool success;
  final String? errorMessage;
  final List<String> warnings;

  const LaunchOutcome({
    required this.pid,
    required this.success,
    this.errorMessage,
    this.warnings = const [],
  });
}
