import Foundation
import SwiftUI
import Observation
import HeadroomCore

@Observable
public final class AppViewModel {
    public var diskLedger: DiskLedger? = nil
    public var scannedItems: [ScannedItem] = []
    public var undoRecords: [UndoRecord] = []
    public var isScanning: Bool = false
    public var isCleaning: Bool = false
    public var statusMessage: String = "Ready"
    public var selectedTierFilter: String = "All"
    public var lastSummary: CleanExecutionSummary? = nil
    public var showSummarySheet: Bool = false

    public init() {}

    public var filteredItems: [ScannedItem] {
        if selectedTierFilter == "All" {
            return scannedItems
        }
        return scannedItems.filter { $0.tier.shortName == selectedTierFilter }
    }

    public var totalSelectedBytes: Int64 {
        scannedItems.filter { $0.isSelected }.reduce(0) { $0 + $1.allocatedBytes }
    }

    public var formattedTotalSelected: String {
        ByteCountFormatter.string(fromByteCount: totalSelectedBytes, countStyle: .file)
    }

    public var pendingQuarantineBytes: Int64 {
        undoRecords.reduce(0) { $0 + $1.sizeBytes }
    }

    public var formattedPendingQuarantine: String {
        ByteCountFormatter.string(fromByteCount: pendingQuarantineBytes, countStyle: .file)
    }

    @MainActor
    public func refreshAll() async {
        isScanning = true
        statusMessage = "Analyzing APFS container and System Data..."
        diskLedger = await ScannerEngine.shared.generateDiskLedger()

        statusMessage = "Scanning reclaimable developer and system items..."
        scannedItems = await ScannerEngine.shared.scanReclaimableItems { msg in
            Task { @MainActor in
                self.statusMessage = msg
            }
        }

        undoRecords = QuarantineManager.shared.getRecords()
        isScanning = false
        statusMessage = "Scan complete. \(scannedItems.count) items discovered."
    }

    @MainActor
    public func executeClean(useQuarantine: Bool = true) async {
        guard totalSelectedBytes > 0 else { return }
        isCleaning = true
        statusMessage = "Cleaning selected items..."

        let summary = await CleanExecutor.shared.executeClean(
            items: scannedItems,
            useQuarantine: useQuarantine
        ) { msg in
            Task { @MainActor in
                self.statusMessage = msg
            }
        }

        self.lastSummary = summary
        self.showSummarySheet = true
        self.isCleaning = false
        self.statusMessage = "Cleanup finished. Actual APFS gain: \(summary.formattedActualDelta)"

        await refreshAll()
    }

    @MainActor
    public func toggleItemSelection(id: String) {
        if let idx = scannedItems.firstIndex(where: { $0.id == id }) {
            scannedItems[idx].isSelected.toggle()
        }
    }

    @MainActor
    public func selectAll(select: Bool) {
        for i in 0..<scannedItems.count {
            scannedItems[i].isSelected = select
        }
    }

    @MainActor
    public func restoreItem(recordId: String) {
        do {
            try QuarantineManager.shared.restore(recordId: recordId)
            undoRecords = QuarantineManager.shared.getRecords()
            statusMessage = "Item successfully restored."
        } catch {
            statusMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    @MainActor
    public func purgeQuarantineItem(recordId: String) {
        try? QuarantineManager.shared.purge(recordId: recordId)
        undoRecords = QuarantineManager.shared.getRecords()
    }

    @MainActor
    public func pruneSnapshots() async {
        isCleaning = true
        statusMessage = "Pruning local APFS snapshots..."
        let result = await ScannerEngine.shared.pruneLocalSnapshots()
        isCleaning = false
        statusMessage = result.success ? "Local snapshots pruned successfully." : "Snapshot status: \(result.message)"
        await refreshAll()
    }

    @MainActor
    public func emptyTrash() async {
        isCleaning = true
        statusMessage = "Emptying user Trash..."
        let home = (FileManager.default.homeDirectoryForCurrentUser.path as NSString).standardizingPath
        let trashPath = "\(home)/.Trash"
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: trashPath) {
            for item in contents {
                try? FileManager.default.removeItem(atPath: "\(trashPath)/\(item)")
            }
        }
        isCleaning = false
        statusMessage = "Trash emptied. Physical blocks released."
        await refreshAll()
    }

    @MainActor
    public func purgeAllQuarantine() {
        QuarantineManager.shared.purgeAll()
        undoRecords = QuarantineManager.shared.getRecords()
        statusMessage = "Quarantine purged. Physical APFS blocks released."
    }
}
