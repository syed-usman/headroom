import Foundation

public struct CleanExecutionSummary: Sendable {
    public let itemsProcessed: Int
    public let claimedReclaimedBytes: Int64
    public let actualContainerDeltaBytes: Int64
    public let quarantinedCount: Int
    public let nativeCommandsRun: Int
    public let errors: [String]

    public var formattedClaimed: String {
        ByteCountFormatter.string(fromByteCount: claimedReclaimedBytes, countStyle: .file)
    }

    public var formattedActualDelta: String {
        ByteCountFormatter.string(fromByteCount: actualContainerDeltaBytes, countStyle: .file)
    }
}

public final class CleanExecutor: Sendable {
    public static let shared = CleanExecutor()

    private let apfs = APFSService.shared
    private let safety = SafetyEngine.shared
    private let quarantine = QuarantineManager.shared
    private let rulesRepo = RulesRepository.shared

    public init() {}

    public func executeClean(
        items: [ScannedItem],
        useQuarantine: Bool = true,
        progressHandler: (@Sendable (String) -> Void)? = nil
    ) async -> CleanExecutionSummary {
        let beforeStats = apfs.getRootVolumeStats()
        var claimedBytes: Int64 = 0
        var quarantinedCount = 0
        var nativeCommandsRun = 0
        var errors: [String] = []
        var processedCount = 0

        for item in items where item.isSelected {
            progressHandler?("Cleaning \(item.displayName)...")

            // 1. Safety check
            let safetyVerdict = safety.verifyPathSafety(item.path)
            guard safetyVerdict.isSafe else {
                errors.append("Skipped \(item.displayName): \(safetyVerdict.reason)")
                continue
            }

            // 2. Process check
            if let rule = rulesRepo.rule(withId: item.ruleId) {
                let blocking = safety.checkRunningProcesses(for: rule)
                if !blocking.isEmpty {
                    errors.append("Skipped \(item.displayName): \(blocking.joined(separator: ", ")) is running. Please close it first.")
                    continue
                }
            }

            // 3. Execution: Native tool command or Quarantine
            if let nativeCmd = item.nativeCommand, !nativeCmd.isEmpty, canRunNative(nativeCmd) {
                let success = runNativeCommand(nativeCmd)
                if success {
                    nativeCommandsRun += 1
                    claimedBytes += item.allocatedBytes
                    processedCount += 1
                } else {
                    // Fallback to quarantine if native command fails
                    doQuarantine(item: item, claimedBytes: &claimedBytes, quarantinedCount: &quarantinedCount, processedCount: &processedCount, errors: &errors)
                }
            } else if useQuarantine {
                doQuarantine(item: item, claimedBytes: &claimedBytes, quarantinedCount: &quarantinedCount, processedCount: &processedCount, errors: &errors)
            } else {
                // Direct removal if user explicitly chose not to quarantine
                do {
                    try FileManager.default.removeItem(atPath: item.path)
                    claimedBytes += item.allocatedBytes
                    processedCount += 1
                } catch {
                    errors.append("Failed removing \(item.displayName): \(error.localizedDescription)")
                }
            }
        }

        let afterStats = apfs.getRootVolumeStats()
        let actualDelta = max(0, afterStats.freeBytes - beforeStats.freeBytes)

        return CleanExecutionSummary(
            itemsProcessed: processedCount,
            claimedReclaimedBytes: claimedBytes,
            actualContainerDeltaBytes: actualDelta,
            quarantinedCount: quarantinedCount,
            nativeCommandsRun: nativeCommandsRun,
            errors: errors
        )
    }

    private func doQuarantine(
        item: ScannedItem,
        claimedBytes: inout Int64,
        quarantinedCount: inout Int,
        processedCount: inout Int,
        errors: inout [String]
    ) {
        do {
            _ = try quarantine.quarantine(itemPath: item.path, sizeBytes: item.allocatedBytes, ruleId: item.ruleId)
            claimedBytes += item.allocatedBytes
            quarantinedCount += 1
            processedCount += 1
        } catch {
            errors.append("Could not quarantine \(item.displayName): \(error.localizedDescription)")
        }
    }

    private func canRunNative(_ command: String) -> Bool {
        let binary = command.components(separatedBy: " ").first ?? ""
        return FileManager.default.isExecutableFile(atPath: "/usr/bin/\(binary)") ||
               FileManager.default.isExecutableFile(atPath: "/usr/local/bin/\(binary)") ||
               FileManager.default.isExecutableFile(atPath: "/opt/homebrew/bin/\(binary)") ||
               binary == "xcrun" || binary == "brew" || binary == "docker"
    }

    private func runNativeCommand(_ command: String) -> Bool {
        let parts = command.components(separatedBy: " ")
        guard let binary = parts.first else { return false }
        let args = Array(parts.dropFirst())

        let process = Process()
        if binary == "xcrun" {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        } else if FileManager.default.isExecutableFile(atPath: "/opt/homebrew/bin/\(binary)") {
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/\(binary)")
        } else if FileManager.default.isExecutableFile(atPath: "/usr/local/bin/\(binary)") {
            process.executableURL = URL(fileURLWithPath: "/usr/local/bin/\(binary)")
        } else {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [binary] + args
        }

        if process.executableURL?.path != "/usr/bin/env" {
            process.arguments = args
        }

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
