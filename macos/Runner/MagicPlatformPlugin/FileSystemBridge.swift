import Cocoa

/// File-system utilities exposed to Dart.
struct FileSystemBridge {

    /// Calculate the total size (in bytes, as allocated on disk) of a
    /// directory tree, including hidden files. Symlinks are not followed.
    static func directorySize(path: String) -> Int {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [
            .isRegularFileKey, .totalFileAllocatedSizeKey, .fileSizeKey,
        ]
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: keys,
            options: []
        ) else { return 0 }

        var total: Int = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.isRegularFile == true else { continue }
            total += values.totalFileAllocatedSize ?? values.fileSize ?? 0
        }
        return total
    }

    /// Reveal a file or directory in Finder.
    static func revealInFinder(path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Set [targetAppPath]'s Finder/Dock icon to [sourceAppPath]'s icon with
    /// a coloured badge (ARGB [color]) in the bottom-right showing [label].
    @discardableResult
    static func setBadgedIcon(
        targetAppPath: String,
        sourceAppPath: String,
        color argb: Int,
        label: String
    ) -> Bool {
        let base = NSWorkspace.shared.icon(forFile: sourceAppPath)
        let badgeColor = NSColor(
            srgbRed: CGFloat((argb >> 16) & 0xFF) / 255,
            green: CGFloat((argb >> 8) & 0xFF) / 255,
            blue: CGFloat(argb & 0xFF) / 255,
            alpha: 1
        )

        let image = NSImage(size: NSSize(width: 512, height: 512), flipped: false) { rect in
            base.draw(in: rect)

            let diameter = rect.width * 0.42
            let margin = rect.width * 0.05
            let badge = NSRect(
                x: rect.maxX - diameter - margin,
                y: rect.minY + margin,
                width: diameter,
                height: diameter
            )
            NSColor.white.setFill()
            NSBezierPath(ovalIn: badge).fill()
            badgeColor.setFill()
            NSBezierPath(ovalIn: badge.insetBy(dx: diameter * 0.07, dy: diameter * 0.07)).fill()

            let text = NSAttributedString(string: label, attributes: [
                .font: NSFont.systemFont(ofSize: diameter * 0.48, weight: .bold),
                .foregroundColor: NSColor.white,
            ])
            let textSize = text.size()
            text.draw(at: NSPoint(
                x: badge.midX - textSize.width / 2,
                y: badge.midY - textSize.height / 2
            ))
            return true
        }

        let ok = NSWorkspace.shared.setIcon(image, forFile: targetAppPath, options: [])
        // Nudge Finder/Dock to pick up the new icon.
        NSWorkspace.shared.noteFileSystemChanged(targetAppPath)
        return ok
    }
}
