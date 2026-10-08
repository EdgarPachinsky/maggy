import Cocoa

/// Discovers installed applications on macOS using public APIs.
struct AppDiscovery {

    /// Scans standard application directories and returns metadata for each app.
    ///
    /// Call from a background queue: reading bundles and exporting icons is
    /// slow. [progress] is called once per app with (index, total, name),
    /// on the calling queue.
    static func discover(
        progress: ((Int, Int, String) -> Void)? = nil
    ) -> [[String: Any?]] {
        let fileManager = FileManager.default
        let searchPaths = [
            "/Applications",
            "/System/Applications",
            NSHomeDirectory() + "/Applications",
        ]

        // Collect candidates first so progress can report a total.
        var candidates: [(path: String, item: String)] = []
        for searchPath in searchPaths {
            guard let contents = try? fileManager.contentsOfDirectory(
                atPath: searchPath
            ) else { continue }
            for item in contents where item.hasSuffix(".app") {
                candidates.append(((searchPath as NSString).appendingPathComponent(item), item))
            }
        }

        let cacheDir = fileManager.temporaryDirectory
            .appendingPathComponent("magic_icons", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        var seen = Set<String>()
        var results: [[String: Any?]] = []

        for (index, candidate) in candidates.enumerated() {
            let appPath = candidate.path
            let fallbackName = (candidate.item as NSString).deletingPathExtension
            progress?(index + 1, candidates.count, fallbackName)

            guard let bundle = Bundle(path: appPath),
                  let bundleId = bundle.bundleIdentifier else { continue }

            if seen.contains(bundleId) { continue }
            seen.insert(bundleId)

            let displayName = bundle.infoDictionary?["CFBundleDisplayName"] as? String
                ?? bundle.infoDictionary?["CFBundleName"] as? String
                ?? fallbackName

            let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String

            let executablePath = bundle.executablePath

            let iconPath = exportIcon(
                appPath: appPath,
                to: cacheDir.appendingPathComponent("\(bundleId).png")
            )

            results.append([
                "bundleIdentifier": bundleId,
                "displayName": displayName,
                "appPath": appPath,
                "version": version,
                "iconPath": iconPath,
                "executablePath": executablePath,
            ])
        }

        return results
    }

    /// Export the app icon to a PNG for Flutter to display. Reuses the cached
    /// PNG when it is newer than the app bundle.
    private static func exportIcon(appPath: String, to dest: URL) -> String? {
        let fileManager = FileManager.default
        if let cached = try? fileManager.attributesOfItem(atPath: dest.path)[.modificationDate] as? Date,
           let appDate = try? fileManager.attributesOfItem(atPath: appPath)[.modificationDate] as? Date,
           cached >= appDate {
            return dest.path
        }

        let icon = NSWorkspace.shared.icon(forFile: appPath)
        guard let tiff = icon.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            return nil
        }
        do {
            try png.write(to: dest)
            return dest.path
        } catch {
            return nil
        }
    }
}
