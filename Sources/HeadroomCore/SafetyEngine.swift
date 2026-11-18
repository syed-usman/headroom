import Foundation
import AppKit

public struct SafetyVerdict: Sendable {
    public let isSafe: Bool
    public let reason: String

    public static let safe = SafetyVerdict(isSafe: true, reason: "Verified safe by safety engine.")
    public static func unsafe(_ reason: String) -> SafetyVerdict {
        SafetyVerdict(isSafe: false, reason: reason)
    }
}

public final class SafetyEngine: Sendable {
    public static let shared = SafetyEngine()

    private let homePath: String

    public init() {
        self.homePath = (FileManager.default.homeDirectoryForCurrentUser.path as NSString).standardizingPath
    }

    public var denylistedExactPaths: Set<String> {
        let home = homePath
        return [
            "/",
            "/System",
            "/Applications",
            "/Library",
            "/usr",
            "/bin",
            "/sbin",
            "/var",
            "/private",
            "/Volumes",
            home,
            "\(home)/Desktop",
            "\(home)/Documents",
            "\(home)/Downloads",
            "\(home)/Pictures",
            "\(home)/Movies",
            "\(home)/Music",
            "\(home)/Library",
            "\(home)/Library/Mobile Documents",
            "\(home)/Library/CloudStorage",
            "\(home)/Library/Keychains",
            "\(home)/Library/Messages",
            "\(home)/Library/Mail",
            "\(home)/Library/Notes"
        ]
    }

    public func verifyPathSafety(_ targetPath: String) -> SafetyVerdict {
        let standardized = (targetPath as NSString).standardizingPath
        let resolved = (URL(fileURLWithPath: standardized).resolvingSymlinksInPath().path as NSString).standardizingPath

        // 1. Check exact root and sensitive folder matches
        if denylistedExactPaths.contains(standardized) || denylistedExactPaths.contains(resolved) {
            return .unsafe("Critical system or personal user directory is strictly protected: \(standardized)")
        }

        // 2. Reject paths outside of /Library, /Users, or /private/var/folders
        let isUserPath = resolved.hasPrefix(homePath)
        let isLibraryPath = resolved.hasPrefix("/Library/")
        let isVarFolders = resolved.hasPrefix("/private/var/folders/")
        let isTmp = resolved.hasPrefix("/tmp/") || resolved.hasPrefix("/private/tmp/")

        guard isUserPath || isLibraryPath || isVarFolders || isTmp else {
            return .unsafe("Path is outside permissible user or system cache boundaries: \(resolved)")
        }

        // 3. Cloud storage protection: deletions would propagate to other devices or cloud
        if resolved.contains("/Library/CloudStorage/") || resolved.contains("/Library/Mobile Documents/") {
            return .unsafe("Cloud synced folder: deletions would propagate to remote cloud storage. Offload via provider instead.")
        }

        // 4. Dotdir protection: protect full AI directories (~/.claude, ~/.cursor, etc) unless subpath is cache
        let dangerousDotdirs = ["/.claude", "/.cursor", "/.codex", "/.ssh", "/.gnupg"]
        for dotdir in dangerousDotdirs {
            if resolved.hasSuffix(dotdir) {
                return .unsafe("Root configuration folder \(dotdir) is protected. Only approved cache subpaths can be cleaned.")
            }
        }

        // 5. Never delete critical lockfiles or git metadata
        let filename = (resolved as NSString).lastPathComponent
        let protectedFilenames: Set<String> = [
            ".git", ".gitignore", "Cargo.lock", "package-lock.json",
            "pnpm-lock.yaml", "yarn.lock", "Podfile.lock", "flake.lock"
        ]
        if protectedFilenames.contains(filename) {
            return .unsafe("Project lockfile or repository metadata is guarded: \(filename)")
        }

        return .safe
    }

    public func checkRunningProcesses(for rule: CleanupRule) -> [String] {
        guard !rule.blockingProcesses.isEmpty else { return [] }
        let runningApps = NSWorkspace.shared.runningApplications
        var activeConflicting: [String] = []

        for proc in rule.blockingProcesses {
            let lower = proc.lowercased()
            let isRunning = runningApps.contains { app in
                if let name = app.localizedName?.lowercased(), name.contains(lower) { return true }
                if let bundle = app.bundleIdentifier?.lowercased(), bundle.contains(lower) { return true }
                return false
            }
            if isRunning {
                activeConflicting.append(proc)
            }
        }
        return activeConflicting
    }
}
