import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:magic/app/providers.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/shared/magic_logo.dart';

const _hints = [
  'Maggy creates isolated profiles so you can run multiple accounts side by side.',
  'Supported apps like Chrome and Firefox get full profile isolation automatically.',
  'Each profile has its own data directory — cookies, sessions, and settings stay separate.',
  'You can run two Chrome profiles simultaneously with different logged-in accounts.',
  'Claude profiles let you sign in with different credentials in parallel.',
  'Use the experimental mode to try any app — but isolation is not guaranteed.',
  'Profile data is stored safely in ~/Library/Application Support/Magic/',
  'Deleting a profile only removes Maggy-owned data. Your original app is never touched.',
  'Firefox profiles use -no-remote so multiple instances can run at the same time.',
  'VS Code profiles isolate extensions and settings using --user-data-dir.',
];

/// Quick filters shown under the search field. Several can be on at once;
/// an app must match all of them. None selected = all apps.
enum _AppFilter {
  pinned('Pinned'),
  running('Running'),
  withProfiles('With profiles'),
  supported('Supported');

  const _AppFilter(this.label);
  final String label;
}

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _searchQuery = '';
  final Set<_AppFilter> _filters = {};

  @override
  void initState() {
    super.initState();
    // Kick off a non-blocking scan. The stream from watchAll() will push
    // results to the UI as they arrive; we don't await this.
    Future.microtask(() => ref.read(scanAppsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appListProvider);
    final scanState = ref.watch(scanAppsProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, scanState),
          Expanded(
            child: appsAsync.when(
              data: (apps) {
                if (apps.isEmpty && scanState.isLoading) {
                  return const _ScanProgressView();
                }
                return _buildAppList(apps);
              },
              loading: () => const _ScanProgressView(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load applications',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('$e',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(scanAppsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue scanState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MagicLogo(size: 28, showWordmark: false),
              const SizedBox(width: 10),
              Text(
                'MAGGY',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
              ),
              if (scanState.isLoading) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rescan applications',
                onPressed: scanState.isLoading
                    ? null
                    : () => ref.invalidate(scanAppsProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search applications...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _filters.isEmpty,
                onSelected: (_) => setState(_filters.clear),
              ),
              for (final f in _AppFilter.values)
                FilterChip(
                  label: Text(f.label),
                  selected: _filters.contains(f),
                  onSelected: (on) => setState(() {
                    on ? _filters.add(f) : _filters.remove(f);
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppList(List<AppDescriptor> apps) {
    final pinned = ref.watch(pinnedAppsProvider).valueOrNull ?? const <String>{};
    final running =
        ref.watch(runningAppsProvider).valueOrNull ?? const <String, int>{};
    final profileCounts =
        ref.watch(profileCountsProvider).valueOrNull ?? const <String, int>{};

    final query = _searchQuery.toLowerCase();
    bool matchesOne(AppDescriptor a, _AppFilter filter) => switch (filter) {
          _AppFilter.pinned => pinned.contains(a.bundleIdentifier),
          _AppFilter.running => running.containsKey(a.bundleIdentifier),
          _AppFilter.withProfiles =>
            (profileCounts[a.bundleIdentifier] ?? 0) > 0,
          _AppFilter.supported =>
            a.compatibilityStatus == CompatibilityStatus.supported ||
                a.compatibilityStatus ==
                    CompatibilityStatus.supportedWithLimitations,
        };
    bool matchesFilter(AppDescriptor a) =>
        _filters.every((f) => matchesOne(a, f));

    final filtered = apps
        .where((a) =>
            matchesFilter(a) &&
            (query.isEmpty ||
                a.displayName.toLowerCase().contains(query) ||
                a.bundleIdentifier.toLowerCase().contains(query)))
        .toList()
      // Pinned first, then alphabetical.
      ..sort((a, b) {
        final ap = pinned.contains(a.bundleIdentifier);
        final bp = pinned.contains(b.bundleIdentifier);
        if (ap != bp) return ap ? -1 : 1;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });

    if (filtered.isEmpty) {
      final message = _searchQuery.isNotEmpty
          ? 'No matches for "$_searchQuery"'
          : _filters.isEmpty
              ? 'No applications found.'
              : _filters.length > 1
                  ? 'No apps match all selected filters.'
                  : switch (_filters.first) {
                      _AppFilter.pinned =>
                        'No pinned apps yet. Use the pin button on any app.',
                      _AppFilter.running => 'None of your apps are running.',
                      _AppFilter.withProfiles => 'No apps have profiles yet.',
                      _AppFilter.supported => 'No supported apps found.',
                    };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    // Section headers when pinned apps are mixed with the rest.
    final pinnedCount =
        filtered.where((a) => pinned.contains(a.bundleIdentifier)).length;
    final showSections = pinnedCount > 0 && pinnedCount < filtered.length;
    final rows = <Object>[
      if (showSections) 'Pinned',
      for (var i = 0; i < filtered.length; i++) ...[
        if (showSections && i == pinnedCount) 'All apps',
        filtered[i],
      ],
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              row,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        final app = row as AppDescriptor;
        return _AppTile(
          app: app,
          pinned: pinned.contains(app.bundleIdentifier),
          runningCount: running[app.bundleIdentifier] ?? 0,
          profileCount: profileCounts[app.bundleIdentifier] ?? 0,
        );
      },
    );
  }
}

/// Shown while the initial app scan is in progress.
/// Displays an animated spinner with rotating hint tips.
class _ScanProgressView extends StatefulWidget {
  const _ScanProgressView();

  @override
  State<_ScanProgressView> createState() => _ScanProgressViewState();
}

class _ScanProgressViewState extends State<_ScanProgressView> {
  int _hintIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() => _hintIndex = (_hintIndex + 1) % _hints.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MagicLogo(size: 56, showWordmark: false),
            const SizedBox(height: 28),
            Text(
              'Discovering applications...',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey<int>(_hintIndex),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hints[_hintIndex],
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AppAction { quit, forceQuit }

class _AppTile extends ConsumerWidget {
  final AppDescriptor app;
  final bool pinned;
  final int runningCount;
  final int profileCount;

  const _AppTile({
    required this.app,
    required this.pinned,
    required this.runningCount,
    required this.profileCount,
  });

  bool get _running => runningCount > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasIcon = app.iconPath != null && File(app.iconPath!).existsSync();
    final icon = SizedBox(
      width: 40,
      height: 40,
      child: hasIcon
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(app.iconPath!),
                  width: 40, height: 40, fit: BoxFit.cover),
            )
          : const Icon(Icons.apps, size: 40),
    );

    final details = [
      app.bundleIdentifier,
      app.compatibilityStatus.label,
      if (profileCount > 0)
        profileCount == 1 ? '1 profile' : '$profileCount profiles',
      if (_running) 'Running',
    ].join('  ·  ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _running
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  icon,
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : icon,
        title: Text(app.displayName),
        subtitle: Text(
          details,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
              tooltip: pinned ? 'Unpin' : 'Pin to top',
              onPressed: () => ref
                  .read(appRepositoryProvider)
                  .setPinned(app.bundleIdentifier, !pinned),
            ),
            _compatibilityBadge(context, app.compatibilityStatus),
            if (_running)
              PopupMenuButton<_AppAction>(
                tooltip: 'More',
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => switch (action) {
                  _AppAction.quit => _quit(context, ref, force: false),
                  _AppAction.forceQuit => _quit(context, ref, force: true),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _AppAction.quit,
                    child: ListTile(
                      leading: Icon(Icons.stop_circle_outlined),
                      title: Text('Quit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _AppAction.forceQuit,
                    child: ListTile(
                      leading: Icon(Icons.dangerous_outlined, color: Colors.red),
                      title: Text('Force Quit…'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(width: 48),
          ],
        ),
        onTap: () {
          context.go(
              '/apps/${Uri.encodeComponent(app.bundleIdentifier)}/profiles');
        },
      ),
    );
  }

  /// Quit (or force quit) every running instance, asking first when it
  /// could lose work or affect more than one window.
  Future<void> _quit(BuildContext context, WidgetRef ref,
      {required bool force}) async {
    final messenger = ScaffoldMessenger.of(context);
    // The tile may leave the list (e.g. "Running" filter) before we finish,
    // so use the container rather than this widget's ref after awaiting.
    final container = ProviderScope.containerOf(context, listen: false);
    final instances = runningCount == 1
        ? ''
        : ' all $runningCount instances of';

    final needsConfirm = force || runningCount > 1;
    if (needsConfirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(force ? 'Force Quit ${app.displayName}?' : 'Quit ${app.displayName}?'),
          content: Text(
            force
                ? 'This will force quit$instances ${app.displayName}. '
                    'Unsaved changes will be lost.'
                : 'This will quit$instances ${app.displayName}, '
                    'including any profile windows.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: force
                  ? FilledButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(force ? 'Force Quit' : 'Quit'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      final count = await container
          .read(platformApiProvider)
          .quitApp(app.bundleIdentifier, force: force);
      if (count == 0) {
        messenger.showSnackBar(SnackBar(
          content: Text('${app.displayName} could not be quit'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
    // Refresh running state once the app has had a moment to exit.
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    container.invalidate(runningAppsProvider);
  }

  Widget _compatibilityBadge(
      BuildContext context, CompatibilityStatus status) {
    final (color, icon) = switch (status) {
      CompatibilityStatus.supported => (Colors.green, Icons.check_circle),
      CompatibilityStatus.supportedWithLimitations =>
        (Colors.orange, Icons.warning_amber),
      CompatibilityStatus.experimental => (Colors.blue, Icons.science),
      CompatibilityStatus.unsupported => (Colors.red, Icons.block),
      CompatibilityStatus.unknown => (Colors.grey, Icons.help_outline),
    };
    return Icon(icon, color: color, size: 20);
  }
}
