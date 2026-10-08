import 'profile_status.dart';

/// A named, isolated profile for a specific application.
class MagicProfile {
  final String id;
  final String appBundleIdentifier;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String dataDirectory;
  final List<String> launchArguments;
  final Map<String, String> environmentVariables;
  final ProfileStatus status;
  final int? storageBytes;
  final String? adapterVersion;

  /// User-picked colour (ARGB). `null` = automatic colour from [displayColor].
  final int? color;

  /// Optional emoji shown instead of the initial. `null` = none.
  final String? emoji;

  /// Open this profile automatically when you log in to your Mac.
  final bool launchAtLogin;

  const MagicProfile({
    required this.id,
    required this.appBundleIdentifier,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.dataDirectory,
    this.launchArguments = const [],
    this.environmentVariables = const {},
    this.status = ProfileStatus.ready,
    this.storageBytes,
    this.adapterVersion,
    this.color,
    this.emoji,
    this.launchAtLogin = false,
  });

  /// Colours offered for profiles (ARGB).
  static const palette = <int>[
    0xFF6C5CE7, // purple
    0xFF0984E3, // blue
    0xFF00A8A8, // teal
    0xFF00B36B, // green
    0xFFE17055, // orange
    0xFFD63031, // red
    0xFFE84393, // pink
    0xFF57606F, // slate
  ];

  /// The colour to show: the picked one, or a stable automatic one.
  int get displayColor {
    if (color != null) return color!;
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }

  /// Short label for avatars and badges: the emoji, or the first letter.
  String get badgeLabel {
    if (emoji != null && emoji!.isNotEmpty) return emoji!;
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  /// Copy with an explicit appearance (either value may be cleared to null).
  MagicProfile withAppearance({required int? color, required String? emoji}) {
    return MagicProfile(
      id: id,
      appBundleIdentifier: appBundleIdentifier,
      name: name,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dataDirectory: dataDirectory,
      launchArguments: launchArguments,
      environmentVariables: environmentVariables,
      status: status,
      storageBytes: storageBytes,
      adapterVersion: adapterVersion,
      color: color,
      emoji: (emoji == null || emoji.trim().isEmpty) ? null : emoji.trim(),
      launchAtLogin: launchAtLogin,
    );
  }

  MagicProfile copyWith({
    String? id,
    String? appBundleIdentifier,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dataDirectory,
    List<String>? launchArguments,
    Map<String, String>? environmentVariables,
    ProfileStatus? status,
    int? storageBytes,
    String? adapterVersion,
    int? color,
    String? emoji,
    bool? launchAtLogin,
  }) {
    return MagicProfile(
      id: id ?? this.id,
      appBundleIdentifier: appBundleIdentifier ?? this.appBundleIdentifier,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataDirectory: dataDirectory ?? this.dataDirectory,
      launchArguments: launchArguments ?? this.launchArguments,
      environmentVariables: environmentVariables ?? this.environmentVariables,
      status: status ?? this.status,
      storageBytes: storageBytes ?? this.storageBytes,
      adapterVersion: adapterVersion ?? this.adapterVersion,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MagicProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MagicProfile($id, $name, $appBundleIdentifier)';
}
