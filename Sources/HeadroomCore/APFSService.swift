import Foundation
import Darwin

public final class APFSService: @unchecked Sendable {
    public static let shared = APFSService()

    private init() {}

    public struct VolumeStats: Sendable {
        public let totalBytes: Int64
        public let freeBytes: Int64
        public let purgeableBytes: Int64
        public let usedBytes: Int64

        public var formattedFree: String {
            ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
        }
        public var formattedTotal: String {
            ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
        }
        public var formattedUsed: String {
            ByteCountFormatter.string(fromByteCount: usedBytes, countStyle: .file)
        }
    }

    public func getRootVolumeStats() -> VolumeStats {
        var stat = statfs()
        let result = statfs("/", &stat)
        guard result == 0 else {
            return VolumeStats(totalBytes: 0, freeBytes: 0, purgeableBytes: 0, usedBytes: 0)
        }

        let blockSize = Int64(stat.f_bsize)
        let total = Int64(stat.f_blocks) * blockSize
        let free = Int64(stat.f_bavail) * blockSize
        let used = total > free ? (total - free) : 0

        // Get purgeable space via Foundation URL resource values if possible
        var purgeable: Int64 = 0
        let rootURL = URL(fileURLWithPath: "/")
        if let values = try? rootURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityForOpportunisticUsageKey]) {
            if let opp = values.volumeAvailableCapacityForOpportunisticUsage,
               let imp = values.volumeAvailableCapacityForImportantUsage {
                let diff = opp - imp
                if diff > 0 {
                    purgeable = diff
                }
            }
        }

        return VolumeStats(
            totalBytes: total,
            freeBytes: free,
            purgeableBytes: purgeable,
            usedBytes: used
        )
    }

    public func getDirectAllocatedSize(at url: URL, seenInodes: inout Set<UInt64>) -> (allocatedBytes: Int64, logicalBytes: Int64) {
        var totalAllocated: Int64 = 0
        var totalLogical: Int64 = 0

        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return (0, 0)
        }

        if !isDir.boolValue {
            let sizes = singleFileAllocatedSize(path: url.path, seenInodes: &seenInodes)
            return (sizes.allocated, sizes.logical)
        }

        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return (0, 0)
        }

        for case let fileURL as URL in enumerator {
            let sizes = singleFileAllocatedSize(path: fileURL.path, seenInodes: &seenInodes)
            totalAllocated += sizes.allocated
            totalLogical += sizes.logical
        }

        return (totalAllocated, totalLogical)
    }

    public func calculateDirectorySize(at path: String) -> (allocatedBytes: Int64, logicalBytes: Int64) {
        var seen = Set<UInt64>()
        return getDirectAllocatedSize(at: URL(fileURLWithPath: path), seenInodes: &seen)
    }

    private func singleFileAllocatedSize(path: String, seenInodes: inout Set<UInt64>) -> (allocated: Int64, logical: Int64) {
        var fileStat = stat()
        guard lstat(path, &fileStat) == 0 else {
            return (0, 0)
        }

        // Inode deduplication to avoid double counting hardlinks and APFS clones
        let inode = UInt64(fileStat.st_ino)
        if seenInodes.contains(inode) {
            return (0, 0)
        }
        seenInodes.insert(inode)

        // st_blocks is 512-byte blocks allocated by the filesystem
        let allocated = Int64(fileStat.st_blocks) * 512
        let logical = Int64(fileStat.st_size)
        return (allocated > 0 ? allocated : logical, logical)
    }
}
