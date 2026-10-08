import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/adapters/adapter_registry.dart';
import 'package:magic/infrastructure/adapters/chromium_adapter.dart';
import 'package:magic/infrastructure/adapters/firefox_adapter.dart';
import 'package:magic/infrastructure/adapters/generic_adapter.dart';
import 'package:magic/infrastructure/adapters/vscode_adapter.dart';

void main() {
  group('AdapterRegistry', () {
    late AdapterRegistry registry;

    setUp(() {
      registry = AdapterRegistry([
        ChromiumAdapter(),
        FirefoxAdapter(),
        VSCodeAdapter(),
        GenericAdapter(),
      ]);
    });

    test('finds chromium adapter for Chrome', () {
      final adapter = registry.findAdapter('com.google.Chrome');
      expect(adapter, isNotNull);
      expect(adapter!.identifier, 'chromium');
    });

    test('finds firefox adapter for Firefox', () {
      final adapter = registry.findAdapter('org.mozilla.firefox');
      expect(adapter, isNotNull);
      expect(adapter!.identifier, 'firefox');
    });

    test('finds vscode adapter for VS Code', () {
      final adapter = registry.findAdapter('com.microsoft.VSCode');
      expect(adapter, isNotNull);
      expect(adapter!.identifier, 'vscode');
    });

    test('returns null for unknown bundle ID', () {
      // Generic adapter has empty supportedBundleIdentifiers,
      // so it won't match via findAdapter.
      final adapter = registry.findAdapter('com.random.app');
      expect(adapter, isNull);
    });

    test('isSupported returns true for known apps', () {
      expect(registry.isSupported('com.google.Chrome'), isTrue);
      expect(registry.isSupported('org.mozilla.firefox'), isTrue);
      expect(registry.isSupported('com.microsoft.VSCode'), isTrue);
    });

    test('isSupported returns false for unknown apps', () {
      expect(registry.isSupported('com.random.app'), isFalse);
    });

    test('adapters list includes all registered adapters', () {
      expect(registry.adapters, hasLength(4));
    });
  });
}
