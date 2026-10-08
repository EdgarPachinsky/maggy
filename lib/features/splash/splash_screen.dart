import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:magic/app/providers.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';
import 'package:magic/shared/magic_logo.dart';

/// Animated splash that starts the app scan and shows what is happening
/// (which app is being read, how many were found) until it finishes.
///
/// The scan runs on a native background thread, so the UI stays responsive.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Never keep the user on the splash longer than this, even if the scan
  /// is still going (the apps screen shows its own progress).
  static const _maxWait = Duration(seconds: 15);

  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  StreamSubscription<ScanProgress>? _progressSub;
  Timer? _timeout;

  String _status = 'Starting up…';
  String _detail = '';
  bool _animationDone = false;
  bool _scanDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleUp = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationDone = true;
        _maybeNavigate();
      }
    });
    _controller.forward();

    _startScan();
    _timeout = Timer(_maxWait, () {
      _scanDone = true;
      _maybeNavigate();
    });
  }

  void _startScan() {
    // Subscribe before the scan starts so no progress events are missed.
    _progressSub =
        ref.read(platformApiProvider).scanProgress.listen((progress) {
      if (!mounted) return;
      setState(() {
        _status = progress.index < progress.total
            ? 'Scanning applications (${progress.index} of ${progress.total})'
            : 'Checking compatibility…';
        _detail = progress.appName;
      });
    });

    ref.read(scanAppsProvider.future).then((apps) async {
      if (!mounted) return;
      setState(() {
        _status = 'Found ${apps.length} apps';
        _detail = '';
      });
      // Let the result register before moving on.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _scanDone = true;
      _maybeNavigate();
    }, onError: (Object e) {
      if (!mounted) return;
      setState(() {
        _status = 'Could not scan applications';
        _detail = '';
      });
      // The apps screen shows the error with a retry button.
      _scanDone = true;
      _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (_navigated || !mounted || !_animationDone || !_scanDone) return;
    _navigated = true;
    context.go('/apps');
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    _timeout?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(
                    scale: _scaleUp.value,
                    child: child,
                  ),
                );
              },
              child: const MagicLogo(size: 80),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeIn,
              child: SizedBox(
                width: 360,
                child: Column(
                  children: [
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 4),
                    // Fixed height so the layout doesn't jump as names change.
                    SizedBox(
                      height: 18,
                      child: Text(
                        _detail,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
