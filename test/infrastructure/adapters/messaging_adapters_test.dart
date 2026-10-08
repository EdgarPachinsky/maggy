import 'package:flutter_test/flutter_test.dart';
import 'package:magic/domain/models/models.dart';
import 'package:magic/infrastructure/adapters/telegram_adapter.dart';
import 'package:magic/infrastructure/adapters/whatsapp_adapter.dart';

const _chrome = '/Applications/Google Chrome.app';

MagicProfile _profile(String bundleId) {
  final now = DateTime(2026);
  return MagicProfile(
    id: 'p1',
    appBundleIdentifier: bundleId,
    name: 'Work',
    createdAt: now,
    updatedAt: now,
    dataDirectory: '/tmp/maggy/p1',
  );
}

void main() {
  group('WhatsAppAdapter', () {
    const app = AppDescriptor(
      bundleIdentifier: 'net.whatsapp.WhatsApp',
      displayName: 'WhatsApp',
      appPath: '/Applications/WhatsApp.app',
    );

    test('opens WhatsApp Web in an isolated Chromium app window', () {
      final adapter = WhatsAppAdapter(findBrowser: () => _chrome);
      final plan = adapter.buildLaunchPlan(app, _profile(app.bundleIdentifier));

      expect(plan.appBundlePath, _chrome);
      expect(plan.appArguments, contains('--user-data-dir=/tmp/maggy/p1'));
      expect(plan.appArguments, contains('--app=${WhatsAppAdapter.webUrl}'));
      expect(adapter.compatibility(app),
          CompatibilityStatus.supportedWithLimitations);
    });

    test('falls back to the default browser when no Chromium is installed', () {
      final adapter = WhatsAppAdapter(findBrowser: () => null);
      final plan = adapter.buildLaunchPlan(app, _profile(app.bundleIdentifier));

      expect(plan.appBundlePath, isNull);
      expect(plan.arguments, [WhatsAppAdapter.webUrl]);
      expect(plan.warnings, isNotEmpty);
      expect(adapter.compatibility(app), CompatibilityStatus.experimental);
    });
  });

  group('TelegramAdapter', () {
    test('Telegram Desktop runs natively with its own -workdir', () {
      const app = AppDescriptor(
        bundleIdentifier: TelegramAdapter.desktopBundleId,
        displayName: 'Telegram Desktop',
        appPath: '/Applications/Telegram Desktop.app',
      );
      final adapter = TelegramAdapter(findBrowser: () => _chrome);
      final plan = adapter.buildLaunchPlan(app, _profile(app.bundleIdentifier));

      expect(plan.appBundlePath, app.appPath);
      expect(plan.appArguments, ['-workdir', '/tmp/maggy/p1']);
      expect(adapter.compatibility(app), CompatibilityStatus.supported);
    });

    test('Telegram for macOS uses Telegram Web with a tip', () {
      const app = AppDescriptor(
        bundleIdentifier: TelegramAdapter.nativeMacBundleId,
        displayName: 'Telegram',
        appPath: '/Applications/Telegram.app',
      );
      final adapter = TelegramAdapter(findBrowser: () => _chrome);
      final plan = adapter.buildLaunchPlan(app, _profile(app.bundleIdentifier));

      expect(plan.appBundlePath, _chrome);
      expect(plan.appArguments, contains('--app=${TelegramAdapter.webUrl}'));
      expect(plan.warnings, anyElement(contains('up to 3 accounts')));
    });
  });
}
