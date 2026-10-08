import '../models/models.dart';

/// Contract for application-specific profile support.
///
/// Each adapter knows how to create isolated data directories and build
/// launch plans for a specific family of applications.
abstract class AppAdapter {
  /// Unique identifier for this adapter (e.g. 'chromium', 'firefox').
  String get identifier;

  /// Bundle identifiers this adapter can handle.
  Set<String> get supportedBundleIdentifiers;

  /// Check whether [app] is compatible with this adapter.
  CompatibilityStatus compatibility(AppDescriptor app);

  /// Prepare the profile data directory for first use.
  Future<void> createProfile(AppDescriptor app, MagicProfile profile);

  /// Produce a fully-resolved launch plan.
  LaunchPlan buildLaunchPlan(AppDescriptor app, MagicProfile profile);

  /// Validate that a profile's data directory is intact.
  Future<bool> validate(MagicProfile profile);

  /// Delete profile data to reset it. Only touches Magic-owned directories.
  Future<void> resetProfile(MagicProfile profile);
}

/// Optional extra for adapters that mirror profile details (name, colour,
/// emoji) outside the database, e.g. in a wrapper app bundle's name and icon.
abstract class ProfileUpdateAware {
  Future<void> onProfileUpdated(AppDescriptor app, MagicProfile profile);
}
