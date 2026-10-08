import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/domain/services/app_scanner_service.dart';
import 'package:magic/infrastructure/platform/platform_api.dart';

import '../../infrastructure/platform/fake_platform_api.dart';
import '../fake_repositories.dart';

void main() {
  group('AppScannerService', () {
    late FakePlatformApi platformApi;
    late FakeAppRepository appRepo;
    late AppScannerService service;

    setUp(() {
      platformApi = FakePlatformApi(
        appsToReturn: [
          const PlatformAppInfo(
            bundleIdentifier: 'com.google.Chrome',
            displayName: 'Google Chrome',
            appPath: '/Applications/Google Chrome.app',
            version: '120.0',
            executablePath:
                '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
          ),
          const PlatformAppInfo(
            bundleIdentifier: 'com.apple.Safari',
            displayName: 'Safari',
            appPath: '/Applications/Safari.app',
          ),
          const PlatformAppInfo(
            bundleIdentifier: 'org.mozilla.firefox',
            displayName: 'Firefox',
            appPath: '/Applications/Firefox.app',
          ),
        ],
      );
      appRepo = FakeAppRepository();
      service = AppScannerService(
        platformApi: platformApi,
        appRepository: appRepo,
        adapters: [], // No adapters in Phase 1
      );
    });

    test('scan discovers apps and persists them', () async {
      final apps = await service.scan();
      expect(apps, hasLength(3));
      expect(appRepo.storedApps, hasLength(3));
    });

    test('scan sorts apps by display name', () async {
      final apps = await service.scan();
      expect(apps[0].displayName, 'Firefox');
      expect(apps[1].displayName, 'Google Chrome');
      expect(apps[2].displayName, 'Safari');
    });

    test('scan sets compatibility to unknown when no adapter matches',
        () async {
      final apps = await service.scan();
      for (final app in apps) {
        expect(app.compatibilityStatus, CompatibilityStatus.unknown);
        expect(app.adapterID, isNull);
      }
    });

    test('scan preserves app metadata', () async {
      final apps = await service.scan();
      final chrome =
          apps.firstWhere((a) => a.bundleIdentifier == 'com.google.Chrome');
      expect(chrome.version, '120.0');
      expect(chrome.executablePath, contains('Google Chrome'));
    });
  });
}
