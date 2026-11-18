import Foundation
import HeadroomCore

@main
struct TestRunner {
    static func main() {
        print("🧪 Running HeadroomCore automated test suite...")

        // 1. APFS Stats
        let stats = APFSService.shared.getRootVolumeStats()
        assert(stats.totalBytes > 0, "Root volume total bytes must be > 0")
        assert(stats.freeBytes > 0, "Root volume free bytes must be > 0")
        print("  ✓ APFS container volume stats verified (\(stats.formattedTotal) total, \(stats.formattedFree) free)")

        // 2. Safety Engine Denylist
        let safety = SafetyEngine.shared
        assert(!safety.verifyPathSafety("/").isSafe, "Root / must be protected")
        assert(!safety.verifyPathSafety("/System").isSafe, "System directory must be protected")
        assert(!safety.verifyPathSafety(NSHomeDirectory()).isSafe, "User Home directory must be protected")
        assert(!safety.verifyPathSafety("\(NSHomeDirectory())/Documents").isSafe, "Documents must be protected")
        assert(!safety.verifyPathSafety("\(NSHomeDirectory())/Library/CloudStorage/GoogleDrive").isSafe, "CloudStorage must be protected")
        assert(!safety.verifyPathSafety("/some/path/Cargo.lock").isSafe, "Lockfiles must be protected")

        let validCache = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
        assert(safety.verifyPathSafety(validCache).isSafe, "Valid developer cache must be allowed")
        print("  ✓ SafetyEngine denylist & boundary protection verified")

        // 3. Rules Repository Integrity
        let rules = RulesRepository.shared.rules
        assert(rules.count >= 15, "Should have at least 15 curated rules")
        for rule in rules {
            assert(!rule.id.isEmpty, "Rule id must not be empty")
            assert(!rule.title.isEmpty, "Rule title must not be empty")
            assert(!rule.paths.isEmpty, "Rule paths must not be empty")
            assert(!rule.explanation.isEmpty, "Rule explanation must not be empty")
        }
        print("  ✓ RulesRepository verified (\(rules.count) rules active with tiers and rebuild costs)")

        // 4. Quarantine and Undo Lifecycle
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("headroom_test_\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let qm = QuarantineManager(customBaseDirectory: tempDir)

        let testFile = tempDir.appendingPathComponent("test_cache.bin")
        let dummyData = Data(repeating: 0x48, count: 2048)
        try! dummyData.write(to: testFile)

        do {
            let record = try qm.quarantine(itemPath: testFile.path, sizeBytes: 2048, ruleId: "test-rule")
            assert(!FileManager.default.fileExists(atPath: testFile.path), "Original file should be moved")
            assert(FileManager.default.fileExists(atPath: record.quarantinePath), "Quarantined file must exist")

            try qm.restore(recordId: record.id)
            assert(FileManager.default.fileExists(atPath: testFile.path), "File must be restored to original path")
            assert(!FileManager.default.fileExists(atPath: record.quarantinePath), "Quarantine copy must be removed")

            try? FileManager.default.removeItem(at: tempDir)
            print("  ✓ Quarantine & Undo lifecycle verified (instant move + restore)")
        } catch {
            fatalError("Quarantine test failed: \(error)")
        }

        print("\n🎉 All tests passed successfully!")
    }
}
