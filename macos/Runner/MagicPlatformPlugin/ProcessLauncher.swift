import Cocoa
import ServiceManagement

/// Thin wrapper around Process for launching app instances.
struct ProcessLauncher {

    /// Launch a process and return a dictionary with pid/success/errorMessage.
    static func launch(
        executablePath: String,
        arguments: [String],
        environment: [String: String],
        workingDirectory: String?
    ) -> [String: Any] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        // Merge caller environment with the provided overrides.
        var env = ProcessInfo.processInfo.environment
        for (key, value) in environment {
            env[key] = value
        }
        process.environment = env

        if let wd = workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: wd)
        }

        do {
            try process.run()
            return [
                "pid": Int(process.processIdentifier),
                "success": true,
            ]
        } catch {
            return [
                "pid": -1,
                "success": false,
                "errorMessage": error.localizedDescription,
            ]
        }
    }

    /// Check whether a process with the given PID is still running.
    static func isRunning(pid: Int32) -> Bool {
        // kill(pid, 0) returns 0 if the process exists and we have permission.
        return kill(pid, 0) == 0
    }

    /// Launch an .app bundle as a new instance through LaunchServices.
    /// Unlike `open -na`, this reports the app's own PID and passes the
    /// environment through. [completion] is called on the main queue.
    static func launchApp(
        appPath: String,
        arguments: [String],
        environment: [String: String],
        completion: @escaping ([String: Any]) -> Void
    ) {
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        config.arguments = arguments
        if !environment.isEmpty {
            config.environment = environment
        }
        config.activates = true

        NSWorkspace.shared.openApplication(
            at: URL(fileURLWithPath: appPath),
            configuration: config
        ) { app, error in
            DispatchQueue.main.async {
                if let app = app {
                    completion(["pid": Int(app.processIdentifier), "success": true])
                } else {
                    completion([
                        "pid": -1,
                        "success": false,
                        "errorMessage": error?.localizedDescription ?? "Launch failed",
                    ])
                }
            }
        }
    }

    /// Match running regular apps to profiles by their launch arguments.
    /// [markers] maps profile ID -> data directory. Returns profile ID -> PID.
    /// [pids] must be gathered on the main thread; this can run anywhere.
    static func findRunningProfiles(pids: [pid_t], markers: [String: String]) -> [String: Int] {
        var found: [String: Int] = [:]
        for pid in pids {
            if found.count == markers.count { break }
            guard let args = processArguments(pid: pid) else { continue }
            let joined = args.joined(separator: "\n")
            for (profileId, dataDirectory) in markers where found[profileId] == nil {
                if !dataDirectory.isEmpty && joined.contains(dataDirectory) {
                    found[profileId] = Int(pid)
                }
            }
        }
        return found
    }

    /// PIDs of running apps that show in the Dock. Call on the main thread.
    static func regularAppPids() -> [pid_t] {
        return NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.processIdentifier > 0 }
            .map { $0.processIdentifier }
    }

    /// Read a process's argv (including argv[0]) via sysctl KERN_PROCARGS2.
    static func processArguments(pid: pid_t) -> [String]? {
        var argMax: Int32 = 0
        var argMaxSize = MemoryLayout<Int32>.size
        var argMaxMib: [Int32] = [CTL_KERN, KERN_ARGMAX]
        guard sysctl(&argMaxMib, 2, &argMax, &argMaxSize, nil, 0) == 0, argMax > 0 else {
            return nil
        }

        var size = Int(argMax)
        var buffer = [UInt8](repeating: 0, count: size)
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0,
              size > MemoryLayout<Int32>.size else {
            return nil
        }

        // Layout: argc (Int32), exec path, NUL padding, argv[0..argc-1], env...
        var argc: Int32 = 0
        withUnsafeMutableBytes(of: &argc) { dest in
            for i in 0..<MemoryLayout<Int32>.size { dest[i] = buffer[i] }
        }

        var index = MemoryLayout<Int32>.size
        while index < size && buffer[index] != 0 { index += 1 }  // exec path
        while index < size && buffer[index] == 0 { index += 1 }  // padding

        var args: [String] = []
        var start = index
        while index < size && args.count < Int(argc) {
            if buffer[index] == 0 {
                args.append(String(decoding: buffer[start..<index], as: UTF8.self))
                start = index + 1
            }
            index += 1
        }
        return args
    }

    /// Bring the app with [pid] to the front.
    static func activate(pid: pid_t) -> Bool {
        guard let app = NSRunningApplication(processIdentifier: pid) else { return false }
        if #available(macOS 14.0, *) {
            NSApp.yieldActivation(to: app)
            return app.activate(options: [.activateAllWindows])
        } else {
            return app.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
    }

    /// Ask the app with [pid] to quit, like Cmd-Q.
    static func terminate(pid: pid_t) -> Bool {
        return NSRunningApplication(processIdentifier: pid)?.terminate() ?? false
    }

    // MARK: Any running app

    /// Running Dock apps: bundle ID -> number of instances. Main thread.
    static func runningAppCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
            if let id = app.bundleIdentifier {
                counts[id, default: 0] += 1
            }
        }
        return counts
    }

    /// Quit (or force quit) every running instance of [bundleId].
    /// Never quits Maggy itself. Returns how many instances were signalled.
    static func quitApps(bundleId: String, force: Bool) -> Int {
        if bundleId == Bundle.main.bundleIdentifier { return 0 }
        var count = 0
        for app in NSRunningApplication.runningApplications(withBundleIdentifier: bundleId) {
            let ok = force ? app.forceTerminate() : app.terminate()
            if ok { count += 1 }
        }
        return count
    }

    // MARK: Login item & boot time

    /// Register/unregister Maggy itself as a login item (macOS 13+).
    static func setLoginItem(enabled: Bool) -> String {
        let service = SMAppService.mainApp
        do {
            if enabled {
                if service.status != .enabled {
                    try service.register()
                }
            } else if service.status == .enabled || service.status == .requiresApproval {
                try service.unregister()
            }
        } catch {
            if service.status == .requiresApproval { return "requiresApproval" }
            return "error: \(error.localizedDescription)"
        }
        switch service.status {
        case .enabled: return "enabled"
        case .requiresApproval: return "requiresApproval"
        case .notRegistered: return "notRegistered"
        case .notFound: return "notFound"
        @unknown default: return "unknown"
        }
    }

    /// When the Mac last booted, in seconds since 1970.
    static func bootTime() -> Int {
        var boot = timeval()
        var size = MemoryLayout<timeval>.stride
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        guard sysctl(&mib, 2, &boot, &size, nil, 0) == 0 else { return 0 }
        return Int(boot.tv_sec)
    }
}
