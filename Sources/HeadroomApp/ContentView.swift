import SwiftUI
import HeadroomCore

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedTab: String = "ledger"
    @State private var hoveredTab: String? = nil

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Precision Technical Header
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.auroraGradient)
                            .frame(width: 32, height: 32)
                            .shadow(color: Theme.neonIndigo.opacity(0.6), radius: 8, x: 0, y: 0)
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("HEADROOM")
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .tracking(2.0)
                            .foregroundStyle(.white)
                        Text("APFS FORENSICS // 2.0")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(0.5)
                            .foregroundStyle(Theme.neonCyan)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 20)

                // Step-by-Step Guided Navigation Items
                VStack(spacing: 4) {
                    SidebarButton(
                        id: "ledger",
                        title: "1. Audit & Ledger",
                        icon: "chart.pie.fill",
                        badge: nil,
                        accentColor: Theme.neonCyan,
                        isSelected: selectedTab == "ledger",
                        isHovered: hoveredTab == "ledger"
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = "ledger" }
                    }
                    .onHover { h in hoveredTab = h ? "ledger" : nil }

                    SidebarButton(
                        id: "reclaim",
                        title: "2. Reclaim Space",
                        icon: "sparkles",
                        badge: viewModel.scannedItems.isEmpty ? nil : "\(viewModel.scannedItems.count)",
                        accentColor: Theme.neonPurple,
                        isSelected: selectedTab == "reclaim",
                        isHovered: hoveredTab == "reclaim"
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = "reclaim" }
                    }
                    .onHover { h in hoveredTab = h ? "reclaim" : nil }

                    SidebarButton(
                        id: "quarantine",
                        title: "3. Quarantine Vault",
                        icon: "arrow.uturn.backward.circle.fill",
                        badge: viewModel.undoRecords.isEmpty ? nil : "\(viewModel.undoRecords.count)",
                        accentColor: Theme.neonEmerald,
                        isSelected: selectedTab == "quarantine",
                        isHovered: hoveredTab == "quarantine"
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = "quarantine" }
                    }
                    .onHover { h in hoveredTab = h ? "quarantine" : nil }
                }
                .padding(.horizontal, 10)

                Spacer()

                // Bottom Engine Status Module
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isScanning ? Theme.neonAmber : Theme.neonEmerald)
                            .frame(width: 7, height: 7)
                            .shadow(color: (viewModel.isScanning ? Theme.neonAmber : Theme.neonEmerald).opacity(0.8), radius: 4)

                        Text(viewModel.isScanning ? "APFS BUSY" : "SAFETY ENGINE ONLINE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(0.5)
                            .foregroundStyle(.white.opacity(0.85))

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                    Button(action: {
                        Task { await viewModel.refreshAll() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11, weight: .bold))
                                .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                .animation(viewModel.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isScanning)
                            Text(viewModel.isScanning ? "ANALYZING..." : "RE-INDEX APFS")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .tracking(0.8)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(LinearGradient(colors: [Theme.neonIndigo.opacity(0.7), Theme.neonPurple.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Theme.neonCyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isScanning || viewModel.isCleaning)
                }
                .padding(12)
            }
            .background(Theme.bgDeepSpace)
            .navigationSplitViewColumnWidth(min: 220, ideal: 235, max: 260)
        } detail: {
            ZStack {
                Theme.bgDeepSpace.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Guided Step Workflow Bar
                    HStack(spacing: 12) {
                        StepWorkflowPill(
                            stepNumber: "STEP 01",
                            title: "AUDIT LEDGER",
                            icon: "chart.pie.fill",
                            accentColor: Theme.neonCyan,
                            isActive: selectedTab == "ledger",
                            isCompleted: viewModel.diskLedger != nil
                        ) {
                            withAnimation { selectedTab = "ledger" }
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.25))

                        StepWorkflowPill(
                            stepNumber: "STEP 02",
                            title: "RECLAIM SPACE",
                            icon: "sparkles",
                            accentColor: Theme.neonPurple,
                            isActive: selectedTab == "reclaim",
                            isCompleted: false,
                            badge: viewModel.scannedItems.isEmpty ? nil : "\(viewModel.scannedItems.count) Found"
                        ) {
                            withAnimation { selectedTab = "reclaim" }
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.25))

                        StepWorkflowPill(
                            stepNumber: "STEP 03",
                            title: "QUARANTINE VAULT",
                            icon: "lock.shield.fill",
                            accentColor: Theme.neonEmerald,
                            isActive: selectedTab == "quarantine",
                            isCompleted: false,
                            badge: viewModel.undoRecords.isEmpty ? nil : "\(viewModel.undoRecords.count)"
                        ) {
                            withAnimation { selectedTab = "quarantine" }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.35))
                    .overlay(
                        Rectangle().frame(height: 1).foregroundStyle(Color.white.opacity(0.06)),
                        alignment: .bottom
                    )

                    // Main Content Routing
                    switch selectedTab {
                    case "ledger":
                        BlingLedgerView(viewModel: viewModel) {
                            withAnimation { selectedTab = "reclaim" }
                        }
                    case "reclaim":
                        BlingReclaimView(viewModel: viewModel) {
                            withAnimation { selectedTab = "quarantine" }
                        }
                    case "quarantine":
                        BlingQuarantineView(viewModel: viewModel)
                    default:
                        BlingLedgerView(viewModel: viewModel) {
                            withAnimation { selectedTab = "reclaim" }
                        }
                    }

                    // Bottom Precision Terminal Status Bar
                    HStack(spacing: 12) {
                        if viewModel.isScanning || viewModel.isCleaning {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "terminal.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.neonCyan)
                        }

                        Text(viewModel.statusMessage)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)

                        Spacer()

                        if viewModel.pendingQuarantineBytes > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "archivebox.fill")
                                    .foregroundStyle(Theme.neonAmber)
                                Text("QUARANTINE: \(viewModel.formattedPendingQuarantine)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Theme.neonAmber)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.neonAmber.opacity(0.15))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .overlay(
                        Rectangle().frame(height: 1).foregroundStyle(Color.white.opacity(0.06)),
                        alignment: .top
                    )
                }
            }
        }
        .task {
            if viewModel.diskLedger == nil {
                await viewModel.refreshAll()
            }
        }
        .sheet(isPresented: $viewModel.showSummarySheet) {
            if let summary = viewModel.lastSummary {
                BlingCleanSummarySheet(summary: summary) {
                    viewModel.showSummarySheet = false
                    withAnimation { selectedTab = "quarantine" }
                }
            }
        }
    }
}

// Guided Step Workflow Pill Component
struct StepWorkflowPill: View {
    let stepNumber: String
    let title: String
    let icon: String
    let accentColor: Color
    let isActive: Bool
    let isCompleted: Bool
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isActive ? accentColor : Color.white.opacity(0.06))
                        .frame(width: 22, height: 22)
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isActive ? .white : (isCompleted ? accentColor : .white.opacity(0.4)))
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(stepNumber)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(isActive ? accentColor : .white.opacity(0.4))
                    Text(title)
                        .font(.system(size: 11, weight: isActive ? .bold : .medium, design: .monospaced))
                        .foregroundStyle(isActive ? .white : .white.opacity(0.7))
                }

                if let b = badge {
                    Text(b)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(isActive ? .white : accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isActive ? Color.white.opacity(0.25) : accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? Color.white.opacity(0.08) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isActive ? accentColor.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// Sidebar Button Component
struct SidebarButton: View {
    let id: String
    let title: String
    let icon: String
    let badge: String?
    let accentColor: Color
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : (isHovered ? accentColor : Color.white.opacity(0.55)))
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .monospaced))
                    .foregroundStyle(isSelected ? Color.white : (isHovered ? Color.white : Color.white.opacity(0.75)))

                Spacer()

                if let b = badge {
                    Text(b)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? Color.white : accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(isSelected ? Color.white.opacity(0.25) : accentColor.opacity(0.18))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        isSelected ?
                        AnyShapeStyle(LinearGradient(colors: [accentColor.opacity(0.8), accentColor.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                        AnyShapeStyle(isHovered ? Color.white.opacity(0.06) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? Color.white.opacity(0.25) : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: isSelected ? accentColor.opacity(0.35) : Color.clear, radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 1. SYSTEM DATA LEDGER VIEW
struct BlingLedgerView: View {
    var viewModel: AppViewModel
    let onNavigateToReclaim: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let ledger = viewModel.diskLedger {
                    // Top Hero Section
                    HStack(spacing: 16) {
                        BlingStorageDonutCard(ledger: ledger)
                            .frame(maxWidth: 320)

                        VStack(spacing: 10) {
                            BlingHeroStatCard(
                                title: "RECLAIMABLE DETECTED",
                                value: viewModel.formattedTotalSelected.isEmpty ? "0 KB" : viewModel.formattedTotalSelected,
                                subtitle: "\(viewModel.scannedItems.count) actionable targets cataloged",
                                icon: "sparkles",
                                glowColor: Theme.neonPurple
                            )

                            BlingHeroStatCard(
                                title: "SYSTEM DATA FOOTPRINT",
                                value: ByteCountFormatter.string(fromByteCount: ledger.estimatedSystemDataBytes, countStyle: .file),
                                subtitle: "\(ledger.buckets.count) system buckets identified & active",
                                icon: "internaldrive.fill",
                                glowColor: Theme.neonCyan
                            )

                            BlingHeroStatCard(
                                title: "AVAILABLE APFS HEADROOM",
                                value: ByteCountFormatter.string(fromByteCount: ledger.freeContainerBytes, countStyle: .file),
                                subtitle: "Total Container \(ByteCountFormatter.string(fromByteCount: ledger.totalCapacityBytes, countStyle: .file))",
                                icon: "chart.bar.fill",
                                glowColor: Theme.neonEmerald
                            )
                        }
                    }

                    // APFS Architectural Demystification Card
                    BlingForensicBreakdownCard(ledger: ledger)

                    // System Data Dissection Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SYSTEM DATA RECOVERY MATRIX")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .tracking(1.0)
                                    .foregroundStyle(.white)
                                Text("Real-time block breakdown & direct remediation triggers for macOS system storage.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                            Spacer()
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(ledger.buckets) { bucket in
                                BlingBucketRow(
                                    bucket: bucket,
                                    totalSystemBytes: ledger.estimatedSystemDataBytes,
                                    onPruneSnapshots: { Task { await viewModel.pruneSnapshots() } },
                                    onEmptyTrash: { Task { await viewModel.emptyTrash() } },
                                    onNavigateReclaim: onNavigateToReclaim
                                )
                            }
                        }
                    }

                    // Next Step Flow Banner
                    Button(action: onNavigateToReclaim) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PROCEED TO STEP 2: RECLAIM SPACE")
                                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                    .tracking(0.8)
                                    .foregroundStyle(.white)
                                Text("\(viewModel.scannedItems.count) targets ready for review with instant rebuild estimates.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.neonCyan)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [Theme.neonIndigo.opacity(0.7), Theme.neonPurple.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10).stroke(Theme.neonCyan.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                } else {
                    VStack(spacing: 14) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Reading APFS blocks & building ledger...")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, minHeight: 380)
                }
            }
            .padding(22)
        }
    }
}

// Forensic Breakdown Card: Explains what is the OS, what is user data, and where the 135 GB lives
struct BlingForensicBreakdownCard: View {
    let ledger: DiskLedger

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.neonCyan)
                Text("APFS ARCHITECTURE & STORAGE EXPLANATION")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.0)
                    .foregroundStyle(.white)
                Spacer()
            }

            Text("Where does your storage actually go? An APFS Container is shared across specialized roles:")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 8) {
                ForensicRow(
                    label: "macOS Sealed System Volume (SSV)",
                    size: ByteCountFormatter.string(fromByteCount: ledger.sealedSystemVolumeBytes, countStyle: .file),
                    badge: "IMMUTABLE OS",
                    badgeColor: Theme.neonEmerald,
                    description: "Apple's read-only operating system files (/System). Cryptographically sealed by Apple CA; cannot be edited without making Mac unbootable."
                )

                ForensicRow(
                    label: "Preboot & Apple Cryptexes",
                    size: ByteCountFormatter.string(fromByteCount: ledger.prebootBytes, countStyle: .file),
                    badge: "APPLE ASSETS",
                    badgeColor: Theme.neonCyan,
                    description: "Secure bootloader, Apple Intelligence local models, and system framework assets managed directly by macOS."
                )

                ForensicRow(
                    label: "Virtual Memory Swap Volume (VM)",
                    size: ByteCountFormatter.string(fromByteCount: ledger.vmVolumeBytes, countStyle: .file),
                    badge: "DYNAMIC SWAP",
                    badgeColor: Theme.neonAmber,
                    description: "macOS kernel page swapfiles and sleepimage. Cleared and re-initialized automatically on reboot."
                )

                ForensicRow(
                    label: "Installed Applications (/Applications)",
                    size: ByteCountFormatter.string(fromByteCount: ledger.applicationsBytes, countStyle: .file),
                    badge: "APPLICATIONS",
                    badgeColor: Theme.neonPurple,
                    description: "Binaries of user-installed software (Xcode, browsers, developer tools)."
                )

                ForensicRow(
                    label: "User Repositories & Documents",
                    size: ByteCountFormatter.string(fromByteCount: ledger.userDataBytes, countStyle: .file),
                    badge: "PERSONAL DATA",
                    badgeColor: .white,
                    description: "Your local code repositories (~/Documents/code), project files, and personal user data on the Data volume."
                )
            }
        }
        .padding(16)
        .blingCard(glowColor: Theme.neonCyan)
    }
}

struct ForensicRow: View {
    let label: String
    let size: String
    let badge: String
    let badgeColor: Color
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(badgeColor)
                .frame(width: 6, height: 6)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(label)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)

                    Text(badge)
                        .font(.system(size: 8, weight: .heavy, design: .monospaced))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(badgeColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                    Spacer()

                    Text(size)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(.vertical, 3)
    }
}

// Glowing Circular Arc Storage Donut Card
struct BlingStorageDonutCard: View {
    let ledger: DiskLedger

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("CONTAINER UTILIZATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(Theme.neonCyan)
                Spacer()
            }

            ZStack {
                let total = max(1, Double(ledger.totalCapacityBytes))
                let usedRatio = min(1.0, Double(ledger.usedBytes) / total)
                let purgeRatio = min(1.0, Double(ledger.purgeableBytes) / total)

                // Track
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 14)
                    .frame(width: 150, height: 150)

                // Purgeable
                if purgeRatio > 0 {
                    Circle()
                        .trim(from: CGFloat(usedRatio), to: CGFloat(min(1.0, usedRatio + purgeRatio)))
                        .stroke(
                            Theme.amberGradient,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                }

                // Used space
                Circle()
                    .trim(from: 0, to: CGFloat(usedRatio))
                    .stroke(
                        Theme.auroraGradient,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Theme.neonPurple.opacity(0.4), radius: 8)

                // Center readout
                VStack(spacing: 1) {
                    Text(ByteCountFormatter.string(fromByteCount: ledger.freeContainerBytes, countStyle: .file))
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.neonEmerald)
                    Text("FREE HEADROOM")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("of \(ByteCountFormatter.string(fromByteCount: ledger.totalCapacityBytes, countStyle: .file))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.vertical, 6)

            HStack(spacing: 14) {
                LegendIndicator(title: "Used", color: Theme.neonIndigo, size: ByteCountFormatter.string(fromByteCount: ledger.usedBytes, countStyle: .file))
                LegendIndicator(title: "Free", color: Theme.neonEmerald, size: ByteCountFormatter.string(fromByteCount: ledger.freeContainerBytes, countStyle: .file))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .blingCard(glowColor: Theme.neonCyan)
    }
}

struct LegendIndicator: View {
    let title: String
    let color: Color
    let size: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                Text(size)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
        }
    }
}

// Hero Stat Card
struct BlingHeroStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let glowColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(glowColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(glowColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.5))

                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(12)
        .blingCard(glowColor: glowColor)
    }
}

// Interactive Actionable Bucket Row
struct BlingBucketRow: View {
    let bucket: SystemDataBucket
    let totalSystemBytes: Int64
    let onPruneSnapshots: () -> Void
    let onEmptyTrash: () -> Void
    let onNavigateReclaim: () -> Void
    @State private var isHovered: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(bucket.isActionable ? Theme.neonCyan.opacity(0.12) : Color.white.opacity(0.04))
                    .frame(width: 36, height: 36)
                Image(systemName: iconForBucket(bucket.id))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(bucket.isActionable ? Theme.neonCyan : Color.white.opacity(0.45))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(bucket.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text(bucket.formattedSize)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(bucket.isActionable ? Theme.neonCyan : .white.opacity(0.7))
                }

                Text(bucket.explanation)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            // Action Triggers
            if bucket.id == "snapshots" && bucket.sizeBytes > 0 {
                Button(action: onPruneSnapshots) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash.circle.fill")
                        Text("Prune Snapshots")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.neonRose.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.neonRose, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else if bucket.id == "trash-bin" && bucket.sizeBytes > 0 {
                Button(action: onEmptyTrash) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                        Text("Empty Trash")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.neonEmerald.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.neonEmerald, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else if bucket.isActionable && bucket.sizeBytes > 0 {
                Button(action: onNavigateReclaim) {
                    HStack(spacing: 4) {
                        Text("Review in Step 2")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.neonCyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.neonCyan.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.neonCyan, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .blingCard(glowColor: bucket.isActionable ? Theme.neonCyan : Color.white.opacity(0.15), isHovered: isHovered)
        .onHover { h in isHovered = h }
    }

    private func iconForBucket(_ id: String) -> String {
        switch id {
        case "snapshots": return "clock.arrow.circlepath"
        case "vms": return "desktopcomputer"
        case "docker-vms": return "shippingbox.fill"
        case "simulators": return "iphone.gen3"
        case "swap": return "memorychip.fill"
        case "app-caches": return "externaldrive.badge.timemachine"
        case "ios-backups": return "arrow.down.doc.fill"
        case "system-logs": return "doc.text.magnifyingglass"
        case "trash-bin": return "trash.fill"
        case "quarantine": return "archivebox.fill"
        default: return "folder.fill"
        }
    }
}

// MARK: - 2. RECLAIM SPACE VIEW
struct BlingReclaimView: View {
    var viewModel: AppViewModel
    let onNavigateToVault: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // PROMINENT ACTIONS HEADER BAR
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Big Prominent Glowing "SELECT ALL" Button
                    Button(action: {
                        viewModel.selectAll(select: true)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("SELECT ALL TARGETS (\(ByteCountFormatter.string(fromByteCount: viewModel.scannedItems.reduce(0) { $0 + $1.allocatedBytes }, countStyle: .file)))")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [Theme.neonIndigo, Theme.neonPurple], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: Theme.neonIndigo.opacity(0.6), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.neonCyan.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Button("DESELECT ALL") {
                        viewModel.selectAll(select: false)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    Button("SELECT SAFE (T1 ONLY)") {
                        for i in 0..<viewModel.scannedItems.count {
                            viewModel.scannedItems[i].isSelected = (viewModel.scannedItems[i].tier == .rebuildable)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.neonEmerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Theme.neonEmerald.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.neonEmerald.opacity(0.3), lineWidth: 1))

                    Spacer()
                }

                // Tier Filter Pills
                HStack(spacing: 6) {
                    FilterPill(title: "ALL", isSelected: viewModel.selectedTierFilter == "All") {
                        viewModel.selectedTierFilter = "All"
                    }
                    FilterPill(title: "T1: REBUILDABLE", isSelected: viewModel.selectedTierFilter == "T1") {
                        viewModel.selectedTierFilter = "T1"
                    }
                    FilterPill(title: "T2: DOWNLOADABLE", isSelected: viewModel.selectedTierFilter == "T2") {
                        viewModel.selectedTierFilter = "T2"
                    }
                    FilterPill(title: "T3: STALE & RUNAWAYS", isSelected: viewModel.selectedTierFilter == "T3") {
                        viewModel.selectedTierFilter = "T3"
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.25))

            Divider().foregroundStyle(Color.white.opacity(0.06))

            // Items List
            if viewModel.filteredItems.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.neonEmerald)

                    Text("No Reclaimable Targets in Filter")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text("All scanned developer directories and runaway stores are clean.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredItems) { item in
                            BlingItemRow(item: item) {
                                viewModel.toggleItemSelection(id: item.id)
                            }
                        }
                    }
                    .padding(16)
                }
            }

            // Bottom Action Footer
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("TARGET RECLAIM:")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(0.8)
                            .foregroundStyle(.white.opacity(0.5))

                        Text(viewModel.formattedTotalSelected)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.neonCyan)
                    }

                    Text("Protected with 7-day quarantine & instant undo")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.neonEmerald)
                }

                Spacer()

                Button(action: {
                    Task { await viewModel.executeClean(useQuarantine: true) }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text("EXECUTE SAFE CLEAN")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .tracking(0.8)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.auroraGradient)
                            .shadow(color: Theme.neonIndigo.opacity(0.5), radius: 10, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.totalSelectedBytes == 0 || viewModel.isCleaning)
                .opacity((viewModel.totalSelectedBytes == 0 || viewModel.isCleaning) ? 0.35 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.07, green: 0.08, blue: 0.12))
            .overlay(
                Rectangle().frame(height: 1).foregroundStyle(Color.white.opacity(0.08)),
                alignment: .top
            )
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .monospaced))
                .tracking(0.5)
                .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Theme.neonIndigo.opacity(0.7) : Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(isSelected ? Theme.neonCyan.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// Glowing Item Row Card
struct BlingItemRow: View {
    let item: ScannedItem
    let onToggle: () -> Void
    @State private var isHovered: Bool = false
    @State private var showDetails: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(item.isSelected ? Theme.neonIndigo : Color.white.opacity(0.04))
                            .frame(width: 20, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(item.isSelected ? Theme.neonCyan : Color.white.opacity(0.18), lineWidth: 1.2)
                            )
                        if item.isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Item Information
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(item.displayName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)

                        BlingTierBadge(tier: item.tier)

                        Spacer()

                        Text(item.formattedAllocatedSize)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(item.isSelected ? Theme.neonCyan : .white)
                    }

                    Text(item.explanation)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))

                    // Rebuild and Path Pills
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.neonAmber)
                            Text(item.rebuildCost.formattedSummary)
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.neonAmber.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        if let cmd = item.nativeCommand {
                            HStack(spacing: 4) {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Theme.neonCyan)
                                Text(cmd)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(Theme.neonCyan)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.neonCyan.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }

                        Spacer()

                        Button(action: { withAnimation { showDetails.toggle() } }) {
                            Text(showDetails ? "HIDE PATH" : "INSPECT PATH")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if showDetails {
                HStack {
                    Text(item.path)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Theme.neonCyan.opacity(0.8))
                        .textSelection(.enabled)
                    Spacer()
                }
                .padding(.top, 2)
                .padding(.leading, 32)
            }
        }
        .padding(10)
        .blingCard(glowColor: item.isSelected ? Theme.neonIndigo : Theme.neonCyan, isHovered: isHovered)
        .onHover { h in isHovered = h }
    }
}

// Bling Tier Badge
struct BlingTierBadge: View {
    let tier: Tier

    var body: some View {
        Text(tier.shortName)
            .font(.system(size: 9, weight: .heavy, design: .monospaced))
            .foregroundStyle(tierColor)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(tierColor.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(tierColor.opacity(0.3), lineWidth: 1)
            )
    }

    private var tierColor: Color {
        switch tier {
        case .rebuildable: return Theme.neonEmerald
        case .redownloadable: return Theme.neonCyan
        case .stale: return Theme.neonAmber
        case .orphaned: return Theme.neonPurple
        case .personal: return Theme.neonRose
        case .systemManaged: return .gray
        case .unknown: return .secondary
        }
    }
}

// MARK: - 3. QUARANTINE & UNDO VIEW
struct BlingQuarantineView: View {
    var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("QUARANTINE ISOLATION VAULT")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(1.0)
                        .foregroundStyle(.white)
                    Text("Zero data loss: Files reside here until explicit purge. 1-click instant rollback.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer()

                if !viewModel.undoRecords.isEmpty {
                    Button(role: .destructive, action: {
                        viewModel.purgeAllQuarantine()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                            Text("PURGE ALL BLOCKS")
                        }
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [Theme.neonRose, Color.red], startPoint: .leading, endPoint: .trailing))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .background(Color.black.opacity(0.25))

            Divider().foregroundStyle(Color.white.opacity(0.06))

            if viewModel.undoRecords.isEmpty {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.neonEmerald.opacity(0.1))
                            .frame(width: 64, height: 64)
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Theme.neonEmerald)
                    }

                    Text("Vault Is Empty")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text("Reclaimed items will appear here with instant non-destructive rollback.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.undoRecords) { rec in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Theme.neonEmerald.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Theme.neonEmerald)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rec.originalPath)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    HStack(spacing: 6) {
                                        Text(rec.formattedSize)
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundStyle(Theme.neonCyan)
                                        Text("•")
                                            .foregroundStyle(.white.opacity(0.3))
                                        Text(DateFormatter.localizedString(from: rec.timestamp, dateStyle: .short, timeStyle: .short))
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundStyle(.white.opacity(0.45))
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    viewModel.restoreItem(recordId: rec.id)
                                }) {
                                    Text("RESTORE")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Theme.neonEmerald)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Theme.neonEmerald.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6).stroke(Theme.neonEmerald.opacity(0.4), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)

                                Button(action: {
                                    viewModel.purgeQuarantineItem(recordId: rec.id)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(10)
                            .blingCard(glowColor: Theme.neonEmerald)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - 4. CELEBRATION SHEET
struct BlingCleanSummarySheet: View {
    let summary: CleanExecutionSummary
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.emeraldGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: Theme.neonEmerald.opacity(0.5), radius: 16)
                Image(systemName: "checkmark")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.top, 4)

            VStack(spacing: 2) {
                Text("APFS OPERATION COMPLETE")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .tracking(1.0)
                    .foregroundStyle(.white)
                Text("Container free delta verified. Blocks isolated in quarantine.")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
            }

            VStack(spacing: 10) {
                HStack {
                    Text("Total Storage Removed:")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(summary.formattedClaimed)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                HStack {
                    Text("Physical APFS Container Gain:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.neonEmerald)
                    Spacer()
                    Text(summary.formattedActualDelta)
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Theme.neonEmerald)
                }

                HStack {
                    Text("Quarantined (Safe Undo):")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(summary.quarantinedCount) items")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.neonCyan)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1)
            )

            Button(action: onDismiss) {
                Text("DONE")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .tracking(1.0)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.auroraGradient)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(minWidth: 400)
        .background(Theme.bgDeepSpace)
    }
}
