# Headroom

Headroom is an open-source APFS disk analysis and space reclamation tool for macOS. It provides transparency into container storage, estimates cache rebuild costs, and uses a local quarantine vault for reversible file removal.

## Architecture

- **APFS Container Forensics:** Analyzes volume topology directly via `diskutil apfs` parsing to detail Sealed System Volume, Cryptex boot volumes, dynamic swap VM, and user data allocations.
- **Cost-Aware Safety Engine:** Classifies cleanup targets into three safety tiers with estimated CPU rebuild time and network redownload volume.
- **7-Day Quarantine Vault:** Moves candidate files to `~/.headroom/quarantine/` with an audit record instead of immediate deletion, enabling single-click restoration.
- **Dual Interface:** Native SwiftUI desktop application (`Headroom.app`) and command-line utility (`headroom`).

## Getting Started

## Installation

### Option 1: One-Line Install (Recommended — skips Gatekeeper warnings)
```bash
curl -fsSL https://syed-usman.github.io/headroom/install.sh | bash
```

### Option 2: Homebrew Cask
```bash
brew install --cask https://raw.githubusercontent.com/syed-usman/headroom/main/Casks/headroom.rb
```

### Option 3: Direct DMG Download
Download the latest disk image:
- **[Headroom.dmg](https://github.com/syed-usman/headroom/releases/latest)** (macOS 14.0+)

> **Note on macOS Gatekeeper:** Because Headroom is distributed directly without Apple Developer ID notarization, downloading via a web browser triggers Gatekeeper's quarantine. If prompted:
> - Click **"Open Anyway"** in **System Settings &gt; Privacy &amp; Security**, or
> - Run `xattr -cr /Applications/Headroom.app` in Terminal, or use Option 1 above.

### Building from Source

Requirements: macOS 14.0+, Swift 5.10+, Xcode Command Line Tools.

```bash
# Clone the repository
git clone https://github.com/syed-usman/headroom.git
cd headroom

# Compile the core library, CLI, and SwiftUI bundle
./build.sh

# Run the CLI
./.build/headroom scan

# Launch the desktop app
open Headroom.app
```

### CLI Commands

```bash
# Scan system and developer caches
./.build/headroom scan

# Display APFS container allocation ledger
./.build/headroom ledger

# Perform a dry-run cleanup
./.build/headroom clean --dry-run

# Execute cleanup to local quarantine
./.build/headroom clean

# View active quarantine records and restore items
./.build/headroom undo
./.build/headroom undo <record-id>

# Permanently purge expired quarantine items
./.build/headroom purge
```

## Contributing Rules

Rules are defined in Swift under `Sources/HeadroomCore/RulesRepository.swift`. Each rule defines:
- Target path pattern
- Safety tier (T1 Safe, T2 Redownloadable, T3 Stale / System)
- Rebuild cost metrics (CPU seconds and network transfer bytes)
- Description and validation check

To propose a new rule, submit a pull request with an updated test assertion in `Tests/HeadroomCoreTests/`.

## License

This project is released under the MIT License.
