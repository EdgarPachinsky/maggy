import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';

void main() {
  group('AppDescriptor', () {
    test('equality is based on bundleIdentifier', () {
      const a = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
      );
      const b = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Chrome (different name)',
        appPath: '/other/path',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith produces a new instance with overridden fields', () {
      const original = AppDescriptor(
        bundleIdentifier: 'com.google.Chrome',
        displayName: 'Google Chrome',
        appPath: '/Applications/Google Chrome.app',
        compatibilityStatus: CompatibilityStatus.unknown,
      );
      final updated = original.copyWith(
        compatibilityStatus: CompatibilityStatus.supported,
        adapterID: 'chromium',
      );
      expect(updated.compatibilityStatus, CompatibilityStatus.supported);
      expect(updated.adapterID, 'chromium');
      expect(updated.displayName, 'Google Chrome');
    });

    test('default compatibilityStatus is unknown', () {
      const app = AppDescriptor(
        bundleIdentifier: 'com.example.app',
        displayName: 'Example',
        appPath: '/Applications/Example.app',
      );
      expect(app.compatibilityStatus, CompatibilityStatus.unknown);
    });
  });

  group('CompatibilityStatus', () {
    test('has correct labels', () {
      expect(CompatibilityStatus.supported.label, 'Supported');
      expect(CompatibilityStatus.experimental.label, 'Experimental');
      expect(
          CompatibilityStatus.supportedWithLimitations.label,
          'Supported with limitations');
    });
  });
}
