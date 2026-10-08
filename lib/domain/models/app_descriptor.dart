import 'compatibility_status.dart';

/// Describes a macOS application discovered on the system.
class AppDescriptor {
  final String bundleIdentifier;
  final String displayName;
  final String appPath;
  final String? version;
  final String? iconPath;
  final String? executablePath;
  final String? adapterID;
  final CompatibilityStatus compatibilityStatus;

  const AppDescriptor({
    required this.bundleIdentifier,
    required this.displayName,
    required this.appPath,
    this.version,
    this.iconPath,
    this.executablePath,
    this.adapterID,
    this.compatibilityStatus = CompatibilityStatus.unknown,
  });

  AppDescriptor copyWith({
    String? bundleIdentifier,
    String? displayName,
    String? appPath,
    String? version,
    String? iconPath,
    String? executablePath,
    String? adapterID,
    CompatibilityStatus? compatibilityStatus,
  }) {
    return AppDescriptor(
      bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
      displayName: displayName ?? this.displayName,
      appPath: appPath ?? this.appPath,
      version: version ?? this.version,
      iconPath: iconPath ?? this.iconPath,
      executablePath: executablePath ?? this.executablePath,
      adapterID: adapterID ?? this.adapterID,
      compatibilityStatus: compatibilityStatus ?? this.compatibilityStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDescriptor &&
          runtimeType == other.runtimeType &&
          bundleIdentifier == other.bundleIdentifier;

  @override
  int get hashCode => bundleIdentifier.hashCode;

  @override
  String toString() => 'AppDescriptor($bundleIdentifier, $displayName)';
}
