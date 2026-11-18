import Foundation

public final class QuarantineManager: @unchecked Sendable {
    public static let shared = QuarantineManager()

    private let fileManager = FileManager.default
    private var baseQuarantineDirectory: URL
    private var journalFileURL: URL
    private let lock = NSLock()

    public init(customBaseDirectory: URL? = nil) {
        if let custom = customBaseDirectory {
            self.baseQuarantineDirectory = custom.appendingPathComponent("quarantine", isDirectory: true)
            self.journalFileURL = custom.appendingPathComponent("undo_journal.json")
        } else {
            let home = fileManager.homeDirectoryForCurrentUser
            let standardHeadroomDir = home.appendingPathComponent(".headroom", isDirectory: true)

            // Verify if user home directory is writable, fallback to /tmp/headroom if in sandboxed test
            do {
                try fileManager.createDirectory(at: standardHeadroomDir, withIntermediateDirectories: true)
                self.baseQuarantineDirectory = standardHeadroomDir.appendingPathComponent("quarantine", isDirectory: true)
                self.journalFileURL = standardHeadroomDir.appendingPathComponent("undo_journal.json")
            } catch {
                let fallback = URL(fileURLWithPath: "/tmp/headroom_quarantine")
                try? fileManager.createDirectory(at: fallback, withIntermediateDirectories: true)
                self.baseQuarantineDirectory = fallback.appendingPathComponent("quarantine", isDirectory: true)
                self.journalFileURL = fallback.appendingPathComponent("undo_journal.json")
            }
        }

        try? fileManager.createDirectory(at: baseQuarantineDirectory, withIntermediateDirectories: true)
    }

    public func getRecords() -> [UndoRecord] {
        lock.lock()
        defer { lock.unlock() }

        guard fileManager.fileExists(atPath: journalFileURL.path),
              let data = try? Data(contentsOf: journalFileURL),
              let records = try? JSONDecoder().decode([UndoRecord].self, from: data) else {
            return []
        }
        return records
    }

    private func saveRecords(_ records: [UndoRecord]) {
        lock.lock()
        defer { lock.unlock() }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(records) {
            try? data.write(to: journalFileURL)
        }
    }

    public func quarantine(itemPath: String, sizeBytes: Int64, ruleId: String) throws -> UndoRecord {
        let originalURL = URL(fileURLWithPath: itemPath)
        guard fileManager.fileExists(atPath: itemPath) else {
            throw NSError(domain: "HeadroomQuarantine", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item does not exist: \(itemPath)"])
        }

        let recordId = UUID().uuidString
        let folderName = "\(Int(Date().timeIntervalSince1970))_\(recordId.prefix(8))"
        let destFolder = baseQuarantineDirectory.appendingPathComponent(folderName, isDirectory: true)
        try fileManager.createDirectory(at: destFolder, withIntermediateDirectories: true)

        let destURL = destFolder.appendingPathComponent(originalURL.lastPathComponent)
        try fileManager.moveItem(at: originalURL, to: destURL)

        let record = UndoRecord(
            id: recordId,
            originalPath: itemPath,
            quarantinePath: destURL.path,
            sizeBytes: sizeBytes,
            timestamp: Date(),
            ruleId: ruleId
        )

        var records = getRecords()
        records.insert(record, at: 0)
        saveRecords(records)

        return record
    }

    public func restore(recordId: String) throws {
        var records = getRecords()
        guard let index = records.firstIndex(where: { $0.id == recordId }) else {
            throw NSError(domain: "HeadroomQuarantine", code: 404, userInfo: [NSLocalizedDescriptionKey: "Record not found in undo journal."])
        }

        let record = records[index]
        let quarentinedURL = URL(fileURLWithPath: record.quarantinePath)
        let originalURL = URL(fileURLWithPath: record.originalPath)

        guard fileManager.fileExists(atPath: quarentinedURL.path) else {
            records.remove(at: index)
            saveRecords(records)
            throw NSError(domain: "HeadroomQuarantine", code: 410, userInfo: [NSLocalizedDescriptionKey: "Quarantined files have already been purged or moved."])
        }

        // Ensure parent directory of original destination exists
        let parentDir = originalURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)

        if fileManager.fileExists(atPath: originalURL.path) {
            throw NSError(domain: "HeadroomQuarantine", code: 409, userInfo: [NSLocalizedDescriptionKey: "Original path already has a file or directory: \(record.originalPath)"])
        }

        try fileManager.moveItem(at: quarentinedURL, to: originalURL)

        records.remove(at: index)
        saveRecords(records)
    }

    public func purge(recordId: String) throws {
        var records = getRecords()
        guard let index = records.firstIndex(where: { $0.id == recordId }) else { return }
        let record = records[index]

        let quarantinedURL = URL(fileURLWithPath: record.quarantinePath)
        let parentDir = quarantinedURL.deletingLastPathComponent()

        try? fileManager.removeItem(at: quarantinedURL)
        try? fileManager.removeItem(at: parentDir)

        records.remove(at: index)
        saveRecords(records)
    }

    public func purgeAll() {
        let records = getRecords()
        for record in records {
            try? purge(recordId: record.id)
        }
    }

    public func getPendingQuarantineBytes() -> Int64 {
        let records = getRecords()
        return records.reduce(0) { $0 + $1.sizeBytes }
    }
}
