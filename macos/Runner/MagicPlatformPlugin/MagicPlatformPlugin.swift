import Cocoa
import FlutterMacOS

/// Flutter method-channel plugin that bridges Dart to macOS platform APIs.
///
/// Exposes: app discovery, process launching, process observation,
/// directory size, and Finder reveal.
public class MagicPlatformPlugin: NSObject, FlutterPlugin {

    /// Used to push scan progress back to Dart.
    private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.magic.platform",
            binaryMessenger: registrar.messenger
        )
        let instance = MagicPlatformPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        DeepLinkRouter.shared.install()
        StatusMenuController.shared.onSelect = { [weak instance] profileId in
            instance?.channel?.invokeMethod("statusMenuSelected", arguments: ["profileId": profileId])
        }
        StatusMenuController.shared.install()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "discoverApps":
            handleDiscoverApps(result: result)
        case "launchProcess":
            handleLaunchProcess(call, result: result)
        case "isProcessRunning":
            handleIsProcessRunning(call, result: result)
        case "directorySize":
            handleDirectorySize(call, result: result)
        case "revealInFinder":
            handleRevealInFinder(call, result: result)
        case "armDeepLinkRoute":
            handleArmDeepLinkRoute(call, result: result)
        case "launchApp":
            handleLaunchApp(call, result: result)
        case "findRunningProfiles":
            handleFindRunningProfiles(call, result: result)
        case "activateProcess":
            guard let pid = (call.arguments as? [String: Any])?["pid"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing pid", details: nil))
                return
            }
            result(ProcessLauncher.activate(pid: pid_t(pid)))
        case "terminateProcess":
            guard let pid = (call.arguments as? [String: Any])?["pid"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing pid", details: nil))
                return
            }
            result(ProcessLauncher.terminate(pid: pid_t(pid)))
        case "setBadgedAppIcon":
            handleSetBadgedAppIcon(call, result: result)
        case "runningAppCounts":
            result(ProcessLauncher.runningAppCounts())
        case "quitApp":
            guard let args = call.arguments as? [String: Any],
                  let bundleId = args["bundleId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing bundleId", details: nil))
                return
            }
            result(ProcessLauncher.quitApps(bundleId: bundleId, force: args["force"] as? Bool ?? false))
        case "setLoginItemEnabled":
            let enabled = (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
            result(ProcessLauncher.setLoginItem(enabled: enabled))
        case "bootTime":
            result(ProcessLauncher.bootTime())
        case "updateStatusMenu":
            let entries = (call.arguments as? [String: Any])?["entries"] as? [[String: Any]] ?? []
            StatusMenuController.shared.update(entries: entries)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Scans off the main thread so the UI stays responsive, reporting each
    /// app to Dart as a `scanProgress` call.
    private func handleDiscoverApps(result: @escaping FlutterResult) {
        let channel = self.channel
        DispatchQueue.global(qos: .userInitiated).async {
            let apps = AppDiscovery.discover { index, total, name in
                DispatchQueue.main.async {
                    channel?.invokeMethod("scanProgress", arguments: [
                        "index": index,
                        "total": total,
                        "name": name,
                    ])
                }
            }
            DispatchQueue.main.async {
                result(apps)
            }
        }
    }

    private func handleLaunchApp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appPath = args["appPath"] as? String,
              let arguments = args["arguments"] as? [String],
              let environment = args["environment"] as? [String: String] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing launch arguments", details: nil))
            return
        }
        ProcessLauncher.launchApp(
            appPath: appPath,
            arguments: arguments,
            environment: environment
        ) { launchResult in
            result(launchResult)
        }
    }

    private func handleFindRunningProfiles(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let markers = args["markers"] as? [String: String] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing markers", details: nil))
            return
        }
        let pids = ProcessLauncher.regularAppPids()  // main thread
        DispatchQueue.global(qos: .utility).async {
            let found = ProcessLauncher.findRunningProfiles(pids: pids, markers: markers)
            DispatchQueue.main.async {
                result(found)
            }
        }
    }

    private func handleSetBadgedAppIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let target = args["targetAppPath"] as? String,
              let source = args["sourceAppPath"] as? String,
              let color = args["color"] as? Int,
              let label = args["label"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing icon arguments", details: nil))
            return
        }
        FileSystemBridge.setBadgedIcon(
            targetAppPath: target,
            sourceAppPath: source,
            color: color,
            label: label
        )
        result(nil)
    }

    private func handleLaunchProcess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let executablePath = args["executablePath"] as? String,
              let arguments = args["arguments"] as? [String],
              let environment = args["environment"] as? [String: String] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing launch arguments", details: nil))
            return
        }
        let workingDirectory = args["workingDirectory"] as? String
        let launchResult = ProcessLauncher.launch(
            executablePath: executablePath,
            arguments: arguments,
            environment: environment,
            workingDirectory: workingDirectory
        )
        result(launchResult)
    }

    private func handleIsProcessRunning(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let pid = args["pid"] as? Int32 else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing pid", details: nil))
            return
        }
        result(ProcessLauncher.isRunning(pid: pid))
    }

    private func handleDirectorySize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let size = FileSystemBridge.directorySize(path: path)
            DispatchQueue.main.async {
                result(size)
            }
        }
    }

    private func handleArmDeepLinkRoute(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scheme = args["scheme"] as? String,
              let targetAppPath = args["targetAppPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing scheme or targetAppPath", details: nil))
            return
        }
        DeepLinkRouter.shared.arm(
            scheme: scheme,
            targetAppPath: targetAppPath,
            fallbackBundleId: args["fallbackBundleId"] as? String
        )
        result(nil)
    }

    private func handleRevealInFinder(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
            return
        }
        FileSystemBridge.revealInFinder(path: path)
        result(nil)
    }
}

// MARK: - Deep link routing

/// Routes custom-scheme deep links (e.g. `claude://` sign-in callbacks) to a
/// specific profile instance instead of whichever app macOS picks.
///
/// macOS delivers a URL to the *default handler* for its scheme, so when
/// several instances of the same app run side by side, sign-in callbacks
/// always reach the original app. When a profile is launched, Magic
/// temporarily makes itself the default handler for the scheme ("arming"),
/// receives the next link, forwards it to that profile's app bundle, then
/// hands the scheme back to the previous handler.
final class DeepLinkRouter: NSObject {
    static let shared = DeepLinkRouter()

    private struct Route {
        let targetAppURL: URL
        /// Bundle ID to give the scheme back to once the route is used.
        let restoreBundleId: String?
        let armedAt: Date
    }

    /// Armed routes, keyed by lowercased scheme. Most recent launch wins.
    private var routes: [String: Route] = [:]
    /// An armed route that receives no link within this time falls back to
    /// the normal handler.
    private let routeLifetime: TimeInterval = 15 * 60
    private var installed = false

    private var ownBundleId: String? { Bundle.main.bundleIdentifier }

    /// Start listening for URL Apple events. Safe to call more than once.
    func install() {
        guard !installed else { return }
        installed = true
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURL(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate(_:)),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
    }

    /// Send the next `scheme://` link to the app bundle at [targetAppPath].
    func arm(scheme rawScheme: String, targetAppPath: String, fallbackBundleId: String?) {
        let scheme = rawScheme.lowercased()
        let restoreId = routes[scheme]?.restoreBundleId
            ?? normalHandler(for: scheme, fallback: fallbackBundleId)
        routes[scheme] = Route(
            targetAppURL: URL(fileURLWithPath: targetAppPath),
            restoreBundleId: restoreId,
            armedAt: Date()
        )
        claim(scheme)

        // The launched app may register itself as the handler while it
        // starts up, so claim the scheme again a few times.
        for delay in [2.0, 6.0, 15.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, self.routes[scheme] != nil else { return }
                self.claim(scheme)
            }
        }
    }

    @objc private func handleGetURL(
        _ event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        guard let string = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: string),
              let scheme = url.scheme?.lowercased() else { return }
        route(url, scheme: scheme)
    }

    private func route(_ url: URL, scheme: String) {
        if let armed = routes.removeValue(forKey: scheme) {
            restore(scheme, to: armed.restoreBundleId)
            let fresh = Date().timeIntervalSince(armed.armedAt) < routeLifetime
            // Only deliver to a running instance: launching the wrapper fresh
            // would start it without its profile arguments.
            if fresh, isRunning(appAt: armed.targetAppURL) {
                deliver(url, toAppAt: armed.targetAppURL)
                return
            }
            if let id = armed.restoreBundleId, let appURL = appURL(for: id) {
                deliver(url, toAppAt: appURL)
            }
            return
        }

        // Not armed (e.g. Magic was left as the handler): pass it on and
        // give the scheme back.
        if let id = normalHandler(for: scheme, fallback: nil), let appURL = appURL(for: id) {
            restore(scheme, to: id)
            deliver(url, toAppAt: appURL)
        }
    }

    @objc private func applicationWillTerminate(_ notification: Notification) {
        for (scheme, route) in routes {
            restore(scheme, to: route.restoreBundleId)
        }
        routes.removeAll()
    }

    // MARK: Helpers

    private func claim(_ scheme: String) {
        guard let own = ownBundleId else { return }
        LSSetDefaultHandlerForURLScheme(scheme as CFString, own as CFString)
    }

    private func restore(_ scheme: String, to bundleId: String?) {
        guard let bundleId = bundleId else { return }
        LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleId as CFString)
    }

    /// The handler the scheme should go back to: the current default if it is
    /// a normal app, otherwise [fallback] or any other registered handler.
    /// Never Magic itself or one of Magic's profile wrappers.
    private func normalHandler(for scheme: String, fallback: String?) -> String? {
        let probe = URL(string: "\(scheme)://")
        if let probe = probe,
           let currentURL = NSWorkspace.shared.urlForApplication(toOpen: probe),
           let current = Bundle(url: currentURL)?.bundleIdentifier,
           isNormalHandler(current) {
            return current
        }
        if let fallback = fallback, appURL(for: fallback) != nil {
            return fallback
        }
        let all = probe.map { NSWorkspace.shared.urlsForApplications(toOpen: $0) } ?? []
        return all
            .compactMap { Bundle(url: $0)?.bundleIdentifier }
            .first(where: isNormalHandler)
    }

    private func isNormalHandler(_ bundleId: String) -> Bool {
        if let own = ownBundleId, bundleId.caseInsensitiveCompare(own) == .orderedSame {
            return false
        }
        return !bundleId.contains(".magic.")
    }

    private func appURL(for bundleId: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
    }

    private func isRunning(appAt appURL: URL) -> Bool {
        let target = appURL.standardizedFileURL.resolvingSymlinksInPath()
        let targetId = Bundle(url: appURL)?.bundleIdentifier
        return NSWorkspace.shared.runningApplications.contains { app in
            if let url = app.bundleURL,
               url.standardizedFileURL.resolvingSymlinksInPath() == target {
                return true
            }
            if let id = targetId, app.bundleIdentifier == id {
                return true
            }
            return false
        }
    }

    private func deliver(_ url: URL, toAppAt appURL: URL) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { _, error in
            if let error = error {
                // Don't log the URL itself: sign-in links carry auth codes.
                NSLog("[Magic] Could not deliver \(url.scheme ?? "") link: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Menu bar launcher

/// The Maggy item in the macOS menu bar: lists profiles grouped by app
/// (with colour dots and a checkmark for running ones) and reports clicks
/// back through [onSelect].
final class StatusMenuController: NSObject {
    static let shared = StatusMenuController()

    /// Called with the profile ID when a profile is clicked.
    var onSelect: ((String) -> Void)?

    private var statusItem: NSStatusItem?
    private var entries: [[String: Any]] = []

    func install() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "m.circle", accessibilityDescription: "Maggy")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "Maggy"
        }
        statusItem = item
        rebuildMenu()
    }

    func update(entries: [[String: Any]]) {
        self.entries = entries
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        if entries.isEmpty {
            let empty = NSMenuItem(title: "No profiles yet", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            var currentApp: String?
            for entry in entries {
                guard let profileId = entry["profileId"] as? String,
                      let name = entry["name"] as? String else { continue }
                let appName = entry["appName"] as? String ?? ""

                if appName != currentApp {
                    if currentApp != nil { menu.addItem(.separator()) }
                    let header = NSMenuItem(title: appName, action: nil, keyEquivalent: "")
                    header.isEnabled = false
                    menu.addItem(header)
                    currentApp = appName
                }

                var title = name
                if let emoji = entry["emoji"] as? String, !emoji.isEmpty {
                    title = "\(emoji)  \(name)"
                }
                let item = NSMenuItem(title: title, action: #selector(profileClicked(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = profileId
                item.indentationLevel = 1
                item.state = (entry["running"] as? Bool ?? false) ? .on : .off
                if let color = entry["color"] as? Int {
                    item.image = Self.dot(argb: color)
                }
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())
        let open = NSMenuItem(title: "Open Maggy", action: #selector(openMainWindow), keyEquivalent: "")
        open.target = self
        menu.addItem(open)
        let quit = NSMenuItem(title: "Quit Maggy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApp
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    @objc private func profileClicked(_ sender: NSMenuItem) {
        guard let profileId = sender.representedObject as? String else { return }
        onSelect?(profileId)
    }

    @objc func openMainWindow() {
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        for window in NSApp.windows where window is MainFlutterWindow {
            window.makeKeyAndOrderFront(nil)
        }
    }

    private static func dot(argb: Int) -> NSImage {
        let color = NSColor(
            srgbRed: CGFloat((argb >> 16) & 0xFF) / 255,
            green: CGFloat((argb >> 8) & 0xFF) / 255,
            blue: CGFloat(argb & 0xFF) / 255,
            alpha: 1
        )
        return NSImage(size: NSSize(width: 10, height: 10), flipped: false) { rect in
            color.setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 0.5, dy: 0.5)).fill()
            return true
        }
    }
}
