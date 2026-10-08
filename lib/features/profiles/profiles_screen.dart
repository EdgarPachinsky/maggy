import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:magic/app/launch_at_login.dart';
import 'package:magic/app/providers.dart';
import 'package:magic/app/running_profiles.dart';
import 'package:magic/domain/models/models.dart';

class ProfilesScreen extends ConsumerWidget {
  final String bundleId;

  const ProfilesScreen({super.key, required this.bundleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profileListProvider(bundleId));
    final appsAsync = ref.watch(appListProvider);
    final appName = appsAsync.whenOrNull(
      data: (apps) => apps
          .where((a) => a.bundleIdentifier == bundleId)
          .map((a) => a.displayName)
          .firstOrNull,
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appName ?? bundleId),
          Expanded(
            child: profilesAsync.when(
              data: (profiles) => _buildProfileList(context, ref, profiles),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProfileDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Profile'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/apps'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Profiles — $title',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(
      BuildContext context, WidgetRef ref, List<MagicProfile> profiles) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Create a profile to get started.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _ProfileTile(profile: profile);
      },
    );
  }

  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Profile'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Profile name',
            hintText: 'e.g. Work, Personal, Client A',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              await ref.read(profileServiceProvider).createProfile(
                    bundleId: bundleId,
                    name: name,
                  );
              ref.invalidate(profileListProvider(bundleId));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Human-readable byte size, e.g. "1.2 GB".
String _formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final digits = unit == 0 || value >= 100 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

/// Coloured circle with the profile's emoji or initial.
class _ProfileAvatar extends StatelessWidget {
  final int color;
  final String label;
  final bool running;
  final double radius;

  const _ProfileAvatar({
    required this.color,
    required this.label,
    this.running = false,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Color(color),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.9,
        ),
      ),
    );
    if (!running) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: radius * 0.6,
            height: radius * 0.6,
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
    );
  }
}

enum _MoreAction { appearance, openAtLogin, reveal, clearCache }

class _ProfileTile extends ConsumerWidget {
  final MagicProfile profile;

  const _ProfileTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(
      runningProfilesProvider.select((m) => m.containsKey(profile.id)),
    );
    final size = ref.watch(profileSizeProvider(profile.dataDirectory));
    final activity = ref.watch(
      profileActivityProvider.select((m) => m[profile.id]),
    );

    final subtitle = [
      activity?.label ?? (running ? 'Running' : 'Not running'),
      if (size.valueOrNull != null) _formatBytes(size.value!),
      if (profile.launchAtLogin) 'Opens at login',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _ProfileAvatar(
          color: profile.displayColor,
          label: profile.badgeLabel,
          running: running,
        ),
        title: Text(profile.name),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activity != null)
              const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              )
            else if (running) ...[
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Focus',
                onPressed: () => _focus(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: 'Quit',
                onPressed: () => _quit(context, ref),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Launch',
                onPressed: () => _launch(context, ref),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Rename',
              onPressed: () => _showRenameDialog(context, ref),
            ),
            PopupMenuButton<_MoreAction>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                switch (action) {
                  case _MoreAction.appearance:
                    _showAppearanceDialog(context, ref);
                  case _MoreAction.openAtLogin:
                    _toggleOpenAtLogin(context, ref);
                  case _MoreAction.reveal:
                    ref.read(storageServiceProvider).reveal(profile);
                  case _MoreAction.clearCache:
                    _confirmClearCache(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _MoreAction.appearance,
                  child: ListTile(
                    leading: Icon(Icons.palette_outlined),
                    title: Text('Color & emoji…'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                CheckedPopupMenuItem(
                  value: _MoreAction.openAtLogin,
                  checked: profile.launchAtLogin,
                  child: const Text('Open at login'),
                ),
                const PopupMenuItem(
                  value: _MoreAction.reveal,
                  child: ListTile(
                    leading: Icon(Icons.folder_open_outlined),
                    title: Text('Reveal in Finder'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _MoreAction.clearCache,
                  enabled: !running,
                  child: ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text('Clear cache…'),
                    subtitle: running ? const Text('Quit the app first') : null,
                    contentPadding: EdgeInsets.zero,
                    enabled: !running,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: running ? 'Quit the app before deleting' : 'Delete profile',
              onPressed: running ? null : () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _launch(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final running = ref.read(runningProfilesProvider.notifier);
    try {
      final outcome = await ref.read(profileActivityProvider.notifier).track(
            profile.id,
            ProfileActivity.launching,
            () => running.launchAndWait(profile.id),
          );
      if (outcome == null) return; // already busy
      if (outcome.success) {
        var msg = '${profile.name} launched (PID ${outcome.pid})';
        if (outcome.warnings.isNotEmpty) {
          msg += '\n${outcome.warnings.join('\n')}';
        }
        messenger.showSnackBar(SnackBar(content: Text(msg)));
      } else {
        _showError(messenger, 'Launch failed: ${outcome.errorMessage}');
      }
    } catch (e) {
      _showError(messenger, 'Error: $e');
    }
  }

  Future<void> _toggleOpenAtLogin(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final enable = !profile.launchAtLogin;
    try {
      final result = await ref
          .read(launchAtLoginProvider)
          .setForProfile(profile.id, enable);
      final message = switch (result) {
        LoginItemResult.ok => enable
            ? '${profile.name} will open when you log in'
            : '${profile.name} will no longer open at login',
        LoginItemResult.needsApproval =>
          'Allow Maggy in System Settings → General → Login Items '
              'so profiles can open at login',
        LoginItemResult.failed =>
          'Saved, but Maggy could not register as a login item',
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      _showError(messenger, 'Could not change: $e');
    }
  }

  Future<void> _focus(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(runningProfilesProvider.notifier).focus(profile.id);
    if (!ok) _showError(messenger, 'Could not bring ${profile.name} to the front');
  }

  Future<void> _quit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final running = ref.read(runningProfilesProvider.notifier);
    final ok = await ref.read(profileActivityProvider.notifier).track(
          profile.id,
          ProfileActivity.quitting,
          () => running.quit(profile.id),
        );
    if (ok == false) _showError(messenger, 'Could not quit ${profile.name}');
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: profile.name)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: profile.name.length,
      );

    Future<void> submit(BuildContext dialogContext) async {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      Navigator.of(dialogContext).pop();
      if (name == profile.name) return;
      try {
        await ref.read(profileServiceProvider).renameProfile(profile.id, name);
      } catch (e) {
        _showError(messenger, 'Rename failed: $e');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Profile name'),
          onSubmitted: (_) => submit(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => submit(ctx),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showAppearanceDialog(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    int? color = profile.color;
    final emojiController = TextEditingController(text: profile.emoji ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final emoji = emojiController.text.trim().characters.take(1).toString();
          final preview = profile.withAppearance(color: color, emoji: emoji);
          return AlertDialog(
            title: const Text('Color & Emoji'),
            content: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _ProfileAvatar(
                      color: preview.displayColor,
                      label: preview.badgeLabel,
                      radius: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in MagicProfile.palette)
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() => color = c),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: preview.displayColor == c
                                    ? Theme.of(ctx).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emojiController,
                    decoration: const InputDecoration(
                      labelText: 'Emoji (optional)',
                      hintText: 'e.g. 💼 🏠 🧪',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await ref.read(profileServiceProvider).updateAppearance(
                          profile.id,
                          color: color,
                          emoji: emoji,
                        );
                  } catch (e) {
                    _showError(messenger, 'Could not save: $e');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClearCache(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: Text(
          'Removes cached files for "${profile.name}". Sign-ins, cookies, '
          'settings and extensions are kept. The app may be a bit slower '
          'the first time it starts again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (ref.read(runningProfilesProvider).containsKey(profile.id)) {
                _showError(messenger, 'Quit ${profile.name} before clearing its cache');
                return;
              }
              try {
                final freed =
                    await ref.read(storageServiceProvider).clearCache(profile);
                ref.invalidate(profileSizeProvider(profile.dataDirectory));
                messenger.showSnackBar(SnackBar(
                  content: Text('Freed ${_formatBytes(freed)}'),
                ));
              } catch (e) {
                _showError(messenger, 'Could not clear cache: $e');
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: Text(
          'This will permanently delete "${profile.name}" and all its data. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final container = ProviderScope.containerOf(context, listen: false);
              await container.read(profileServiceProvider).resetProfile(profile.id);
              container.invalidate(
                  profileListProvider(profile.appBundleIdentifier));
              // Stop opening Maggy at login if no profile needs it any more.
              if (profile.launchAtLogin) {
                await container.read(launchAtLoginProvider).syncLoginItem();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
