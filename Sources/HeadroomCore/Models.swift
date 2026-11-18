import Foundation

public enum Tier: String, Codable, CaseIterable, Sendable {
    case rebuildable = "T1: Rebuildable"
    case redownloadable = "T2: Re-downloadable"
    case stale = "T3: Stale"
    case orphaned = "T4: Orphaned"
    case personal = "T5: Personal"
    case systemManaged = "T0: System-Managed"
    case unknown = "T?: Unknown"

    public var shortName: String {
        switch self {
        case .rebuildable: return "T1"
        case .redownloadable: return "T2"
        case .stale: return "T3"
        case .orphaned: return "T4"
        case .personal: return "T5"
        case .systemManaged: return "T0"
        case .unknown: return "T?"
        }
    }

    public var description: String {
        switch self {
        case .rebuildable: return "Regenerated automatically by local compilers; no network required."
        case .redownloadable: return "Comes back via network download, costing time and bandwidth."
        case .stale: return "Build outputs of inactive or archived projects."
        case .orphaned: return "Left behind by apps that are no longer installed."
        case .personal: return "Irreplaceable personal documents and data."
        case .systemManaged: return "Owned by macOS; only system controls can touch these."
        case .unknown: return "Unclassified files requiring review."
        }
    }

    public var isSafeByDefault: Bool {
        switch self {
        case .rebuildable: return true
        default: return false
        }
    }
}

public struct RebuildCost: Codable, Sendable, Equatable {
    public let networkGigabytes: Double
    public let estimatedMinutes: Int
    public let description: String
    public let requiresCredentials: Bool

    public init(networkGigabytes: Double = 0.0, estimatedMinutes: Int = 1, description: String = "", requiresCredentials: Bool = false) {
        self.networkGigabytes = networkGigabytes
        self.estimatedMinutes = estimatedMinutes
        self.description = description
        self.requiresCredentials = requiresCredentials
    }

    public var formattedSummary: String {
        var parts: [String] = []
        if networkGigabytes > 0 {
            parts.append(String(format: "%.1f GB download", networkGigabytes))
        }
        if estimatedMinutes > 0 {
            parts.append("~\(estimatedMinutes) min rebuild")
        }
        if requiresCredentials {
            parts.append("needs login")
        }
        return parts.isEmpty ? "Near-instant rebuild" : parts.joined(separator: ", ")
    }
}

public enum RuleRisk: String, Codable, Sendable {
    case low
    case medium
    case high
}

public struct CleanupRule: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let tier: Tier
    public let explanation: String
    public let paths: [String]
    public let markers: [String]
    public let nativeCommand: String?
    public let blockingProcesses: [String]
    public let minAgeDays: Int
    public let rebuildCost: RebuildCost
    public let risk: RuleRisk

    public init(
        id: String,
        title: String,
        category: String,
        tier: Tier,
        explanation: String,
        paths: [String],
        markers: [String] = [],
        nativeCommand: String? = nil,
        blockingProcesses: [String] = [],
        minAgeDays: Int = 0,
        rebuildCost: RebuildCost = RebuildCost(),
        risk: RuleRisk = .low
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.tier = tier
        self.explanation = explanation
        self.paths = paths
        self.markers = markers
        self.nativeCommand = nativeCommand
        self.blockingProcesses = blockingProcesses
        self.minAgeDays = minAgeDays
        self.rebuildCost = rebuildCost
        self.risk = risk
    }
}

public struct ScannedItem: Identifiable, Sendable, Equatable {
    public var id: String { path }
    public let path: String
    public let displayName: String
    public let allocatedBytes: Int64
    public let logicalBytes: Int64
    public let ruleId: String
    public let category: String
    public let tier: Tier
    public let explanation: String
    public let rebuildCost: RebuildCost
    public let nativeCommand: String?
    public let lastModified: Date?
    public var isSelected: Bool

    public init(
        path: String,
        displayName: String,
        allocatedBytes: Int64,
        logicalBytes: Int64,
        ruleId: String,
        category: String,
        tier: Tier,
        explanation: String,
        rebuildCost: RebuildCost,
        nativeCommand: String? = nil,
        lastModified: Date? = nil,
        isSelected: Bool = false
    ) {
        self.path = path
        self.displayName = displayName
        self.allocatedBytes = allocatedBytes
        self.logicalBytes = logicalBytes
        self.ruleId = ruleId
        self.category = category
        self.tier = tier
        self.explanation = explanation
        self.rebuildCost = rebuildCost
        self.nativeCommand = nativeCommand
        self.lastModified = lastModified
        self.isSelected = isSelected
    }

    public var formattedAllocatedSize: String {
        ByteCountFormatter.string(fromByteCount: allocatedBytes, countStyle: .file)
    }
}

public struct SystemDataBucket: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sizeBytes: Int64
    public let explanation: String
    public let recommendedAction: String
    public let isActionable: Bool

    public init(
        id: String,
        name: String,
        sizeBytes: Int64,
        explanation: String,
        recommendedAction: String,
        isActionable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.sizeBytes = sizeBytes
        self.explanation = explanation
        self.recommendedAction = recommendedAction
        self.isActionable = isActionable
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}

public struct DiskLedger: Sendable {
    public let totalCapacityBytes: Int64
    public let freeContainerBytes: Int64
    public let purgeableBytes: Int64
    public let usedBytes: Int64
    public let estimatedSystemDataBytes: Int64
    public let buckets: [SystemDataBucket]
    public let unexplainedDeltaBytes: Int64

    // Detailed APFS Container Topology Breakdown
    public let sealedSystemVolumeBytes: Int64
    public let prebootBytes: Int64
    public let vmVolumeBytes: Int64
    public let applicationsBytes: Int64
    public let userDataBytes: Int64

    public init(
        totalCapacityBytes: Int64,
        freeContainerBytes: Int64,
        purgeableBytes: Int64,
        usedBytes: Int64,
        estimatedSystemDataBytes: Int64,
        buckets: [SystemDataBucket],
        unexplainedDeltaBytes: Int64,
        sealedSystemVolumeBytes: Int64 = 12_637_761_536,
        prebootBytes: Int64 = 8_998_248_448,
        vmVolumeBytes: Int64 = 2_147_508_224,
        applicationsBytes: Int64 = 8_800_000_000,
        userDataBytes: Int64 = 200_000_000_000
    ) {
        self.totalCapacityBytes = totalCapacityBytes
        self.freeContainerBytes = freeContainerBytes
        self.purgeableBytes = purgeableBytes
        self.usedBytes = usedBytes
        self.estimatedSystemDataBytes = estimatedSystemDataBytes
        self.buckets = buckets
        self.unexplainedDeltaBytes = unexplainedDeltaBytes
        self.sealedSystemVolumeBytes = sealedSystemVolumeBytes
        self.prebootBytes = prebootBytes
        self.vmVolumeBytes = vmVolumeBytes
        self.applicationsBytes = applicationsBytes
        self.userDataBytes = userDataBytes
    }

    public var totalExplainedInBuckets: Int64 {
        buckets.reduce(0) { $0 + $1.sizeBytes }
    }
}

public struct UndoRecord: Identifiable, Codable, Sendable {
    public let id: String
    public let originalPath: String
    public let quarantinePath: String
    public let sizeBytes: Int64
    public let timestamp: Date
    public let ruleId: String

    public init(
        id: String = UUID().uuidString,
        originalPath: String,
        quarantinePath: String,
        sizeBytes: Int64,
        timestamp: Date = Date(),
        ruleId: String
    ) {
        self.id = id
        self.originalPath = originalPath
        self.quarantinePath = quarantinePath
        self.sizeBytes = sizeBytes
        self.timestamp = timestamp
        self.ruleId = ruleId
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}
