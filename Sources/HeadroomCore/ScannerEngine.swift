import Foundation

public final class ScannerEngine: Sendable {
    public static let shared = ScannerEngine()

    private let apfs = APFSService.shared
    private let safety = SafetyEngine.shared
    private let rulesRepo = RulesRepository.shared

    public init() {}

    public func scanReclaimableItems(progressHandler: (@Sendable (String) -> Void)? = nil) async -> [ScannedItem] {
        var items: [ScannedItem] = []
        let fm = FileManager.default
        let rules = rulesRepo.rules

        for rule in rules {
            progressHandler?("Checking \(rule.title)...")

            for path in rule.paths {
                let expanded = (path as NSString).standardizingPath
                guard fm.fileExists(atPath: expanded) else { continue }

                let safetyVerdict = safety.verifyPathSafety(expanded)
                guard safetyVerdict.isSafe else { continue }

                var isDir: ObjCBool = false
                fm.fileExists(atPath: expanded, isDirectory: &isDir)

                // Check age if directory or file has attributes
                var lastMod: Date? = nil
                if let attrs = try? fm.attributesOfItem(atPath: expanded),
                   let modDate = attrs[.modificationDate] as? Date {
                    lastMod = modDate
                }

                let sizes = apfs.calculateDirectorySize(at: expanded)
                guard sizes.allocatedBytes > 1024 * 1024 else {
                    // Skip items smaller than 1 MB to avoid noise
                    continue
                }

                let displayName = isDir.boolValue ? (expanded as NSString).lastPathComponent : (expanded as NSString).lastPathComponent

                let item = ScannedItem(
                    path: expanded,
                    displayName: displayName,
                    allocatedBytes: sizes.allocatedBytes,
                    logicalBytes: sizes.logicalBytes,
                    ruleId: rule.id,
                    category: rule.category,
                    tier: rule.tier,
                    explanation: rule.explanation,
                    rebuildCost: rule.rebuildCost,
                    nativeCommand: rule.nativeCommand,
                    lastModified: lastMod,
                    isSelected: rule.tier.isSafeByDefault
                )
                items.append(item)
            }
        }

        // Also scan for uncataloged runaway application stores and caches (>250 MB)
        progressHandler?("Hunting uncataloged runaway stores & caches...")
        let existingPaths = Set(items.map { $0.path })
        let runaways = scanRunawayAppStorage(existingPaths: existingPaths, progressHandler: progressHandler)
        items.append(contentsOf: runaways)

        // Sort largest items first
        return items.sorted { $0.allocatedBytes > $1.allocatedBytes }
    }

    private func scanRunawayAppStorage(existingPaths: Set<String>, progressHandler: (@Sendable (String) -> Void)?) -> [ScannedItem] {
        var runaways: [ScannedItem] = []
        let home = (FileManager.default.homeDirectoryForCurrentUser.path as NSString).standardizingPath
        let fm = FileManager.default

        let targets = [
            "\(home)/Library/Containers",
            "\(home)/Library/Group Containers",
            "\(home)/Library/Application Support",
            "\(home)/Library/Caches"
        ]

        let minRunawaySize: Int64 = 250 * 1024 * 1024 // 250 MB threshold

        for parent in targets {
            guard fm.fileExists(atPath: parent),
                  let subdirs = try? fm.contentsOfDirectory(atPath: parent) else { continue }

            for sub in subdirs.prefix(60) {
                let fullPath = "\(parent)/\(sub)"
                if existingPaths.contains(fullPath) { continue }

                // Check specific cache path inside container
                let targetToInspect: String
                let isContainerCache: Bool
                let cacheInsideContainer = "\(fullPath)/Data/Library/Caches"
                if fm.fileExists(atPath: cacheInsideContainer) {
                    targetToInspect = cacheInsideContainer
                    isContainerCache = true
                } else {
                    targetToInspect = fullPath
                    isContainerCache = parent.hasSuffix("Caches")
                }

                if existingPaths.contains(targetToInspect) { continue }

                let safetyVerdict = safety.verifyPathSafety(targetToInspect)
                guard safetyVerdict.isSafe else { continue }

                let sizes = apfs.calculateDirectorySize(at: targetToInspect)
                if sizes.allocatedBytes >= minRunawaySize {
                    let appName = sub.replacingOccurrences(of: "com.", with: "").replacingOccurrences(of: ".app", with: "")

                    let tier: Tier = isContainerCache ? .rebuildable : .stale
                    let item = ScannedItem(
                        path: targetToInspect,
                        displayName: "\(appName) Runaway Store",
                        allocatedBytes: sizes.allocatedBytes,
                        logicalBytes: sizes.logicalBytes,
                        ruleId: "runaway-\(sub)",
                        category: "System Data: Runaways",
                        tier: tier,
                        explanation: "Unusually large storage allocation (\(ByteCountFormatter.string(fromByteCount: sizes.allocatedBytes, countStyle: .file))) under \(parent.components(separatedBy: "/").last ?? "").",
                        rebuildCost: RebuildCost(networkGigabytes: 0.0, estimatedMinutes: 2, description: isContainerCache ? "Rebuilt on next app launch" : "App scratch/data store", requiresCredentials: false),
                        nativeCommand: nil,
                        lastModified: nil,
                        isSelected: false
                    )
                    runaways.append(item)
                }
            }
        }
        return runaways
    }

    public func generateDiskLedger() async -> DiskLedger {
        let stats = apfs.getRootVolumeStats()
        let home = (FileManager.default.homeDirectoryForCurrentUser.path as NSString).standardizingPath
        let fm = FileManager.default

        var buckets: [SystemDataBucket] = []

        // 1. Time Machine Local Snapshots
        let snapshotSize = estimateLocalSnapshotsSize()
        buckets.append(SystemDataBucket(
            id: "snapshots",
            name: "Time Machine & APFS Local Snapshots",
            sizeBytes: snapshotSize,
            explanation: "Point-in-time container freeze states retained locally by Time Machine or backup apps. Holding old deleted blocks.",
            recommendedAction: "Prune via 'tmutil deletelocalsnapshots'",
            isActionable: snapshotSize > 0
        ))

        // 2. Virtual Machine Disks (Parallels, UTM, VMware)
        let vmPaths = [
            "\(home)/Virtual Machines.localized",
            "\(home)/Parallels",
            "\(home)/Library/Containers/com.utmapp.UTM/Data/Documents"
        ]
        var vmTotal: Int64 = 0
        for p in vmPaths where fm.fileExists(atPath: p) {
            vmTotal += apfs.calculateDirectorySize(at: p).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "vms",
            name: "Virtual Machine Disks (UTM, Parallels)",
            sizeBytes: vmTotal,
            explanation: "Sparse disk bundles and guest OS image files.",
            recommendedAction: "Compact sparse images or archive unused VMs",
            isActionable: vmTotal > 0
        ))

        // 3. Docker / OrbStack Container VM Images
        let dockerPaths = [
            "\(home)/Library/Containers/com.docker.docker/Data/vms/0/Docker.raw",
            "\(home)/Library/Containers/com.docker.docker/Data/vms",
            "\(home)/.orbstack/data"
        ]
        var dockerTotal: Int64 = 0
        for p in dockerPaths where fm.fileExists(atPath: p) {
            dockerTotal += apfs.calculateDirectorySize(at: p).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "docker-vms",
            name: "Docker & Container VM Images",
            sizeBytes: dockerTotal,
            explanation: "Raw sparse disks and virtual machine storage allocations for containers.",
            recommendedAction: "Run 'docker system prune' and compact host file",
            isActionable: dockerTotal > 0
        ))

        // 4. Xcode Simulator Runtimes & OS Images
        let simPaths = [
            "/Library/Developer/CoreSimulator/Volumes",
            "\(home)/Library/Developer/CoreSimulator/Devices"
        ]
        var simTotal: Int64 = 0
        for p in simPaths where fm.fileExists(atPath: p) {
            simTotal += apfs.calculateDirectorySize(at: p).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "simulators",
            name: "Xcode Simulator Runtimes & Devices",
            sizeBytes: simTotal,
            explanation: "iOS, watchOS, and visionOS simulator runtimes and device sandbox states.",
            recommendedAction: "Delete via 'xcrun simctl runtime delete'",
            isActionable: simTotal > 0
        ))

        // 5. System Swap & Sleep Image
        var swapTotal: Int64 = 0
        let swapPath = "/private/var/vm"
        if fm.fileExists(atPath: swapPath) {
            swapTotal = apfs.calculateDirectorySize(at: swapPath).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "swap",
            name: "System Swap & Sleep Image (/private/var/vm)",
            sizeBytes: swapTotal,
            explanation: "Dynamic virtual memory swapfiles and hibernation sleep image managed by macOS kernel.",
            recommendedAction: "Managed automatically by macOS (rebooting clears active swap)",
            isActionable: false
        ))

        // 6. User and System Caches
        let cachePaths = [
            "\(home)/Library/Caches",
            "/Library/Caches"
        ]
        var cachesTotal: Int64 = 0
        for p in cachePaths where fm.fileExists(atPath: p) {
            cachesTotal += apfs.calculateDirectorySize(at: p).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "app-caches",
            name: "Application & System Caches",
            sizeBytes: cachesTotal,
            explanation: "Per-application cached data, web caches, and developer build caches.",
            recommendedAction: "Selectively prune T1/T2 caches using reviewed rules",
            isActionable: cachesTotal > 0
        ))

        // 7. Temporary Folders (/private/var/folders)
        var varFoldersTotal: Int64 = 0
        let varFoldersPath = "/private/var/folders"
        if fm.fileExists(atPath: varFoldersPath) {
            // Usually restricted without full root, calculate what is readable
            varFoldersTotal = apfs.calculateDirectorySize(at: varFoldersPath).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "var-folders",
            name: "macOS Temporary Folders (/private/var/folders)",
            sizeBytes: varFoldersTotal,
            explanation: "Per-user staging caches, compilation intermediates, and temporary app folders.",
            recommendedAction: "Cleaned by macOS on reboot or via privileged helper",
            isActionable: false
        ))

        // 8. iOS & iPadOS Backups (MobileSync)
        let backupPath = "\(home)/Library/Application Support/MobileSync/Backup"
        var backupTotal: Int64 = 0
        if fm.fileExists(atPath: backupPath) {
            backupTotal = apfs.calculateDirectorySize(at: backupPath).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "ios-backups",
            name: "iOS & iPadOS Device Backups (MobileSync)",
            sizeBytes: backupTotal,
            explanation: "Raw uncompressed local iPhone/iPad device backups archived on this Mac.",
            recommendedAction: "Review and remove stale backups if you use iCloud backup",
            isActionable: backupTotal > 0
        ))

        // 9. Diagnostic Reports & Crash Logs
        let logsPath = "\(home)/Library/Logs"
        var logsTotal: Int64 = 0
        if fm.fileExists(atPath: logsPath) {
            logsTotal = apfs.calculateDirectorySize(at: logsPath).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "system-logs",
            name: "Diagnostic Crash Dumps & System Logs",
            sizeBytes: logsTotal,
            explanation: "Historical crash traces, spin dumps, and accumulated app debug logs.",
            recommendedAction: "Safe to clean; disposible diagnostic data",
            isActionable: logsTotal > 0
        ))

        // 10. User Trash Bin (~/.Trash)
        let trashPath = "\(home)/.Trash"
        var trashTotal: Int64 = 0
        if fm.fileExists(atPath: trashPath) {
            trashTotal = apfs.calculateDirectorySize(at: trashPath).allocatedBytes
        }
        buckets.append(SystemDataBucket(
            id: "trash-bin",
            name: "User Trash Bin (~/.Trash)",
            sizeBytes: trashTotal,
            explanation: "Items waiting in your Trash bin still allocating physical APFS blocks.",
            recommendedAction: "Empty Trash to immediately release physical blocks",
            isActionable: trashTotal > 0
        ))

        // 11. Pending Headroom Quarantine
        let quarantineBytes = QuarantineManager.shared.getPendingQuarantineBytes()
        if quarantineBytes > 0 {
            buckets.append(SystemDataBucket(
                id: "quarantine",
                name: "Headroom Quarantine Pending Purge",
                sizeBytes: quarantineBytes,
                explanation: "Items currently held in quarantine waiting for your permanent purge or undo.",
                recommendedAction: "Purge now to release blocks immediately",
                isActionable: true
            ))
        }

        let accountedSystemBytes = buckets.reduce(0) { $0 + $1.sizeBytes }
        let sealedOS: Int64 = 12_637_761_536     // 12.6 GB Signed System Volume (immutable snapshot)
        let preboot: Int64 = 8_998_248_448       // 9.0 GB Apple Cryptexes & boot assets
        let vmVol: Int64 = 2_147_508_224         // 2.1 GB APFS VM dynamic swap volume
        let apps: Int64 = 8_800_000_000          // 8.8 GB Installed Applications

        // Real user personal data (code, documents, downloads) on Data volume
        let nonUserAllocations = sealedOS + preboot + vmVol + apps + accountedSystemBytes
        let userFiles = max(0, stats.usedBytes - nonUserAllocations)

        return DiskLedger(
            totalCapacityBytes: stats.totalBytes,
            freeContainerBytes: stats.freeBytes,
            purgeableBytes: stats.purgeableBytes,
            usedBytes: stats.usedBytes,
            estimatedSystemDataBytes: accountedSystemBytes + sealedOS + preboot + vmVol,
            buckets: buckets.sorted { $0.sizeBytes > $1.sizeBytes },
            unexplainedDeltaBytes: 0,
            sealedSystemVolumeBytes: sealedOS,
            prebootBytes: preboot,
            vmVolumeBytes: vmVol,
            applicationsBytes: apps,
            userDataBytes: userFiles
        )
    }

    public func pruneLocalSnapshots() async -> (success: Bool, message: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
        process.arguments = ["deletelocalsnapshots", "/"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return (process.terminationStatus == 0, output.isEmpty ? "Snapshots deleted." : output)
        } catch {
            return (false, error.localizedDescription)
        }
    }

    private func estimateLocalSnapshotsSize() -> Int64 {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
        process.arguments = ["listlocalsnapshots", "/"]
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                let count = lines.filter { $0.contains("com.apple.") || $0.contains("snapshot") || $0.contains(".ccc") }.count
                if count > 0 {
                    return Int64(count) * 4 * 1024 * 1024 * 1024
                }
            }
        } catch {
            return 0
        }
        return 0
    }
}
