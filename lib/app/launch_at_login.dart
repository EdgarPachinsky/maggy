import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:magic/app/running_profiles.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/profile_repository.dart';
import 'package:magic/domain/services/profile_service.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Result of turning "open at login" on or off.
enum LoginItemResult {
  /// Maggy is (or is no longer) a login item, as intended.
  ok,

  /// macOS wants the user to allow Maggy in System Settings → General →
  /// Login Items.
  needsApproval,

  /// Registration failed (e.g. running from an unusual location).
  failed,
}

/// "Open at login" for profiles.
///
/// Maggy itself is registered as a login item while at least one profile
/// has the option on. When Maggy starts for the first time after the Mac
/// boots, it opens those profiles (skipping ones already running).
class LaunchAtLoginController {
  final MagicPlatformApi _platformApi;
  final ProfileRepository _profileRepo;
  final ProfileService _profileService;
  final RunningProfilesNotifier _running;
  final String _baseDataDir;

  LaunchAtLoginController({
    required MagicPlatformApi platformApi,
    required ProfileRepository profileRepo,
    required ProfileService profileService,
    required RunningProfilesNotifier running,
    required String baseDataDir,
  })  : _platformApi = platformApi,
        _profileRepo = profileRepo,
        _profileService = profileService,
        _running = running,
        _baseDataDir = baseDataDir;

  File get _stateFile => File(p.join(_baseDataDir, 'login_launch.json'));

  /// Turn the option on/off for one profile and update Maggy's login item.
  Future<LoginItemResult> setForProfile(String profileId, bool enabled) async {
    await _profileService.setLaunchAtLogin(profileId, enabled);
    return syncLoginItem();
  }

  /// Register Maggy as a login item iff any profile wants it.
  Future<LoginItemResult> syncLoginItem() async {
    final profiles = await _profileRepo.watchAll().first;
    final wanted = profiles.any((p) => p.launchAtLogin);
    final status = await _platformApi.setLoginItemEnabled(wanted);
    if (status == 'requiresApproval') return LoginItemResult.needsApproval;
    if (wanted && status == 'enabled') return LoginItemResult.ok;
    if (!wanted && status != 'enabled' && !status.startsWith('error')) {
      return LoginItemResult.ok;
    }
    return LoginItemResult.failed;
  }

  /// Open "at login" profiles once per Mac boot. Safe to call on every start.
  Future<void> runStartupLaunches() async {
    final bootTime = await _platformApi.bootTime();
    if (bootTime <= 0) return;

    final previousBoot = await _readLastBoot();
    await _writeLastBoot(bootTime);
    // First run ever (no record) or already done for this boot: nothing to do.
    if (previousBoot == null || previousBoot == bootTime) return;

    final profiles = await _profileRepo.watchAll().first;
    final toOpen = profiles.where((p) => p.launchAtLogin).toList();
    if (toOpen.isEmpty) return;

    await _running.refresh();
    for (final MagicProfile profile in toOpen) {
      if (_running.isRunning(profile.id)) continue;
      try {
        await _running.launch(profile.id);
      } catch (_) {
        // One failing profile shouldn't stop the others.
      }
    }
  }

  Future<int?> _readLastBoot() async {
    try {
      final data = jsonDecode(await _stateFile.readAsString());
      return (data as Map)['bootTime'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeLastBoot(int bootTime) async {
    try {
      await _stateFile.writeAsString(jsonEncode({'bootTime': bootTime}));
    } catch (_) {}
  }
}
