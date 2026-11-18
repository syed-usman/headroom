import Foundation
import HeadroomCore

@main
struct HeadroomCLI {
    static func main() async {
        let args = CommandLine.arguments.dropFirst()
        let command = args.first ?? "help"

        switch command {
        case "scan":
            await runScan()
        case "ledger":
            await runLedger()
        case "clean":
            let isDryRun = args.contains("--dry-run")
            let tier1Only = args.contains("--tier-1")
            await runClean(dryRun: isDryRun, tier1Only: tier1Only)
        case "undo":
            let recordId = args.dropFirst().first
            runUndo(recordId: recordId)
        case "purge":
            runPurge()
        case "help", "--help", "-h":
            printHelp()
        default:
            print("Unknown command: \(command)")
            printHelp()
        }
    }

    static func printHelp() {
        print("""
        Headroom — APFS-accurate macOS disk-space reclaimer with rebuild costs and undo.

        USAGE:
          headroom <subcommand> [options]

        SUBCOMMANDS:
          scan              Scan reclaimable items across developers, system, and tools
          ledger            Display the System Data ledger and APFS container breakdown
          clean             Reclaim selected items safely (moves to quarantine or runs native CLI)
            --dry-run       Print the plan without executing any deletions
            --tier-1        Only clean T1: Rebuildable items (no network or credentials needed)
          undo [id]         List undo history or restore an item from quarantine
          purge             Permanently delete items in quarantine to free physical APFS blocks
          help              Show this help message
        """)
    }

    static func runScan() async {
        print("🔍 Scanning APFS container and developer caches...")
        let items = await ScannerEngine.shared.scanReclaimableItems { status in
            // Optional spinner/status update
        }

        if items.isEmpty {
            print("✨ Disk is clean! No eligible items found.")
            return
        }

        var totalAllocated: Int64 = 0
        print("\n--------------------------------------------------------------------------------")
        print(String(format: "%-30@ %-8@ %-14@ %-25@", "ITEM", "TIER", "ALLOCATED", "REBUILD COST"))
        print("--------------------------------------------------------------------------------")

        for item in items {
            totalAllocated += item.allocatedBytes
            let tierShort = item.tier.shortName
            let cost = item.rebuildCost.formattedSummary
            print(String(format: "%-30@ %-8@ %-14@ %-25@",
                         String(item.displayName.prefix(28)),
                         tierShort,
                         item.formattedAllocatedSize,
                         String(cost.prefix(25))))
        }

        print("--------------------------------------------------------------------------------")
        let totalStr = ByteCountFormatter.string(fromByteCount: totalAllocated, countStyle: .file)
        print("Total Reclaimable: \(totalStr) across \(items.count) targets.\n")
    }

    static func runLedger() async {
        print("📊 Analyzing macOS Container and System Data...")
        let ledger = await ScannerEngine.shared.generateDiskLedger()

        let total = ByteCountFormatter.string(fromByteCount: ledger.totalCapacityBytes, countStyle: .file)
        let free = ByteCountFormatter.string(fromByteCount: ledger.freeContainerBytes, countStyle: .file)
        let used = ByteCountFormatter.string(fromByteCount: ledger.usedBytes, countStyle: .file)
        let purgeable = ByteCountFormatter.string(fromByteCount: ledger.purgeableBytes, countStyle: .file)

        print("""

        APFS CONTAINER STATUS:
          Total Capacity:       \(total)
          Used Space:           \(used)
          Free Space:           \(free)
          Purgeable (by macOS): \(purgeable)

        SYSTEM DATA BREAKDOWN:
        """)

        for bucket in ledger.buckets {
            let size = bucket.formattedSize
            let mark = bucket.isActionable ? "[Actionable]" : "[System Managed]"
            print("  • \(bucket.name): \(size)  \(mark)")
            print("    \(bucket.explanation)")
            print("    Action: \(bucket.recommendedAction)\n")
        }

        if ledger.unexplainedDeltaBytes > 0 {
            let unexplained = ByteCountFormatter.string(fromByteCount: ledger.unexplainedDeltaBytes, countStyle: .file)
            print("  • Unexplained Remainder: \(unexplained)")
            print("    Space held by user files, TCC-restricted root directories, or OS staging.\n")
        }
    }

    static func runClean(dryRun: Bool, tier1Only: Bool) async {
        print("🔍 Evaluating cleanable items...")
        var items = await ScannerEngine.shared.scanReclaimableItems()

        if tier1Only {
            items = items.filter { $0.tier == .rebuildable }
        }

        guard !items.isEmpty else {
            print("✨ Nothing to clean.")
            return
        }

        // Mark items for selection
        for i in 0..<items.count {
            items[i].isSelected = true
        }

        if dryRun {
            print("\n📋 DRY-RUN PLAN (No files will be modified):")
            for item in items {
                let action = item.nativeCommand != nil ? "Native command: \(item.nativeCommand!)" : "Move to ~/.headroom/quarantine/"
                print("  - \(item.displayName) (\(item.formattedAllocatedSize)) -> \(action)")
            }
            let sum = items.reduce(0) { $0 + $1.allocatedBytes }
            print("\nEstimated space to reclaim: \(ByteCountFormatter.string(fromByteCount: sum, countStyle: .file))")
            return
        }

        print("\n🧹 Executing safe cleanup...")
        let summary = await CleanExecutor.shared.executeClean(items: items, useQuarantine: true) { status in
            print("  → \(status)")
        }

        print("\n✅ CLEANUP SUMMARY:")
        print("  Items processed:           \(summary.itemsProcessed)")
        print("  Quarantined (undoable):    \(summary.quarantinedCount)")
        print("  Native commands executed:  \(summary.nativeCommandsRun)")
        print("  Reclaimed claimed size:    \(summary.formattedClaimed)")
        print("  Actual APFS Container gain:\(summary.formattedActualDelta)")

        if !summary.errors.isEmpty {
            print("\n⚠️ Warnings/Skipped:")
            for err in summary.errors {
                print("  - \(err)")
            }
        }
        print("\nItems are stored in ~/.headroom/quarantine. Run 'headroom purge' to free blocks permanently, or 'headroom undo' to restore.")
    }

    static func runUndo(recordId: String?) {
        let qm = QuarantineManager.shared
        if let id = recordId {
            do {
                try qm.restore(recordId: id)
                print("✅ Successfully restored record \(id) to original location.")
            } catch {
                print("❌ Restore failed: \(error.localizedDescription)")
            }
        } else {
            let records = qm.getRecords()
            if records.isEmpty {
                print("Undo log is empty. No quarantined items.")
                return
            }
            print("\nQUARANTINE UNDO LOG:")
            for rec in records {
                let dateStr = DateFormatter.localizedString(from: rec.timestamp, dateStyle: .short, timeStyle: .short)
                print("  [\(rec.id.prefix(8))] \(rec.formattedSize) | \(rec.originalPath) (\(dateStr))")
            }
            print("\nTo restore an item, run: headroom undo <id>")
        }
    }

    static func runPurge() {
        let qm = QuarantineManager.shared
        let pending = qm.getPendingQuarantineBytes()
        if pending == 0 {
            print("Quarantine is already empty.")
            return
        }
        let sizeStr = ByteCountFormatter.string(fromByteCount: pending, countStyle: .file)
        print("Purging \(sizeStr) from quarantine...")
        qm.purgeAll()
        print("✅ Quarantine cleared. Physical APFS blocks released.")
    }
}
