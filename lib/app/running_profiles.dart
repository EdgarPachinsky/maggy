import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/repositories/profile_repository.dart';
import 'package:magic/domain/services/launch_service.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

/// Tracks which profiles are running: profile ID → PID.
///
/// Running apps are matched by their launch arguments (each profile's data
/// directory), so this also picks up profiles that were already open when
/// Maggy started, and notices when they quit.
class RunningProfilesNotifier extends StateNotifier<Map<String, int>> {
  static const _pollInterval = Duration(seconds: 3);

  final MagicPlatformApi _platformApi;
  final LaunchService _launchService;

  StreamSubscription<List<MagicProfile>>? _profilesSub;
  Timer? _timer;
  List<MagicProfile> _profiles = const [];
  bool _refreshing = false;

  RunningProfilesNotifier({
    required MagicPlatformApi platformApi,
    required ProfileRepository profileRepo,
    required LaunchService launchService,
  })  : _platformApi = platformApi,
        _launchService = launchService,
        super(const {}) {
    _profilesSub = profileRepo.watchAll().listen((profiles) {
      _profiles = profiles;
      refresh();
    });
    _timer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  bool isRunning(String profileId) => state.containsKey(profileId);

  /// Re-check which profiles are running.
  Future<void> refresh() async {
    if (_refreshing || !mounted) return;
    _refreshing = true;
    try {
      final markers = {for (final p in _profiles) p.id: p.dataDirectory};
      final found = markers.isEmpty
          ? <String, int>{}
          : await _platformApi.findRunningProfiles(markers);
      if (mounted && !const MapEquality<String, int>().equals(found, state)) {
        state = found;
      }
    } catch (_) {
      // Keep the last known state; try again on the next tick.
    } finally {
      _refreshing = false;
    }
  }

  /// Launch a profile and mark it running straight away.
  Future<LaunchOutcome> launch(String profileId) async {
    final outcome = await _launchService.launch(profileId);
    if (outcome.success && outcome.pid > 0 && mounted) {
      state = {...state, profileId: outcome.pid};
    }
    // Confirm shortly after (the app may hand off to an existing instance).
    Future<void>.delayed(const Duration(seconds: 2), refresh);
    return outcome;
  }

  /// Bring a running profile's app to the front.
  Future<bool> focus(String profileId) async {
    final pid = state[profileId];
    if (pid == null) return false;
    return _platformApi.activateProcess(pid);
  }

  /// Ask a running profile's app to quit, and wait (up to [timeout]) until
  /// it has actually exited. Returns false if it was not running or the
  /// quit request was refused.
  Future<bool> quit(
    String profileId, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final pid = state[profileId];
    if (pid == null) return false;
    final ok = await _platformApi.terminateProcess(pid);
    if (!ok) return false;
    await _waitUntil(profileId, running: false, timeout: timeout);
    return true;
  }

  /// Poll until [profileId] is (not) running, or [timeout] passes.
  Future<void> _waitUntil(
    String profileId, {
    required bool running,
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (mounted && DateTime.now().isBefore(deadline)) {
      if (isRunning(profileId) == running) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await refresh();
    }
  }

  /// Launch, then wait until the app shows up as running (up to 8 s).
  Future<LaunchOutcome> launchAndWait(String profileId) async {
    final outcome = await launch(profileId);
    if (outcome.success) {
      await _waitUntil(profileId,
          running: true, timeout: const Duration(seconds: 8));
    }
    return outcome;
  }

  /// Launch if not running, otherwise focus.
  Future<void> launchOrFocus(String profileId) async {
    if (isRunning(profileId)) {
      await focus(profileId);
    } else {
      await launch(profileId);
    }
  }

  @override
  void dispose() {
    _profilesSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

/// What Maggy is currently doing with a profile, for spinners in the UI.
enum ProfileActivity {
  launching('Launching…'),
  quitting('Quitting…');

  const ProfileActivity(this.label);
  final String label;
}

/// Profile ID → in-progress activity (launching / quitting).
class ProfileActivityNotifier extends StateNotifier<Map<String, ProfileActivity>> {
  ProfileActivityNotifier() : super(const {});

  /// Mark [profileId] busy with [activity] while [action] runs. If the
  /// profile is already busy, [action] is not started and null is returned.
  Future<T?> track<T>(
    String profileId,
    ProfileActivity activity,
    Future<T> Function() action,
  ) async {
    if (state.containsKey(profileId)) return null;
    state = {...state, profileId: activity};
    try {
      return await action();
    } finally {
      if (mounted) {
        state = {...state}..remove(profileId);
      }
    }
  }
}
