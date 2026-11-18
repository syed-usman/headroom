# Project Handover: Headroom (macOS APFS Forensics & Disk Reclaimer)
**Target Agent:** Claude  
**Target Repository:** Personal Website & Engineering Blog  
**Objective:** Integrate "Headroom" as a flagship portfolio project entry, technical case study, and featured engineering blog post to highlight senior-level systems programming, product craftsmanship, and macOS platform expertise.

---

## 1. Executive Summary & Context

The author, **Syed Usman** ([@syed-usman](https://github.com/syed-usman)), has engineered and published **Headroom**, a native macOS disk-space reclaimer and APFS forensics utility. 

Unlike traditional "cleaner" utilities that rely on predatory subscriptions, aggressive marketing, and blind `rm -rf` operations, Headroom solves the notorious **"System Data"** black box on macOS using native APFS block-level container forensics, a rebuild-cost safety engine, and a 7-day reversible quarantine vault.

### Core Project Links
- **GitHub Repository:** [https://github.com/syed-usman/headroom](https://github.com/syed-usman/headroom)
- **Live Landing Page:** [https://syed-usman.github.io/headroom/](https://syed-usman.github.io/headroom/)
- **Latest Release (v0.1.0 DMG):** [https://github.com/syed-usman/headroom/releases/tag/v0.1.0](https://github.com/syed-usman/headroom/releases/tag/v0.1.0)
- **Direct Installer Download:** [https://syed-usman.github.io/headroom/downloads/Headroom.dmg](https://syed-usman.github.io/headroom/downloads/Headroom.dmg)
- **License:** MIT License (100% Free & Open Source)

---

## 2. Key Engineering & Product Highlights (Resume / Portfolio Angles)

When integrating Headroom into the personal website and portfolio, highlight these specific capabilities to demonstrate senior engineering competence:

1. **Low-Level macOS & APFS Systems Forensics:**
   - Deep integration with APFS volume topologies via `diskutil apfs` parsing.
   - Decodes Apple’s cryptographic **Sealed System Volume (SSV)** (~12.6 GB snapshot), **Preboot Cryptexes** (~9.0 GB for OS micro-patches), and dynamic **VM Swap** allocations (~2.1 GB) to definitively explain why Finder's "System Data" gauge misleads users.

2. **Novel "Rebuild Cost" Safety Architecture:**
   - Solves the developer dilemma where deleting a 20 GB cache forces a 45-minute project rebuild or 5 GB re-download over slow Wi-Fi.
   - Computes real-time CPU compilation cost (seconds/minutes) and network re-download bandwidth estimates for every cleanable target before execution.

3. **7-Day Reversible Quarantine Vault:**
   - Zero destructive data loss. Instead of immediate file destruction, items are atomically moved to `~/.headroom/quarantine/` with structured metadata logs.
   - Supports 1-click restoration to their original filesystem paths or automated expiration after 7 days.

4. **Decoupled Swift Architecture:**
   - **`HeadroomCore`:** Pure Swift foundation handling APFS parsing, rules evaluation, safety classification, and quarantine lifecycle.
   - **`HeadroomApp`:** Native SwiftUI application with an obsidian/titanium dark mode interface, guided 3-step workflow, and custom CoreGraphics canvas charts.
   - **`HeadroomCLI` (`headroom`):** Fully functional, scriptable terminal binary for automation and CI environments.

5. **Direct Distribution vs. App Store Compromises:**
   - Intentionally bypassed Mac App Store sandboxing to provide genuine Full Disk Access (FDA) capabilities, snapshot pruning (`tmutil`), and root developer cache management without sacrificing user privacy (100% offline, zero telemetry).

---

## 3. Technology Stack

- **Language:** Swift 5.10+
- **UI Framework:** SwiftUI (macOS 14.0+ Sonoma & macOS 15.0+ Sequoia)
- **Graphics & Assets:** AppKit, CoreGraphics programmatic icon synthesis, Retina ICNS compilation
- **Core APIs:** APFS File System APIs, `Process`, `FileManager`, `URLResourceValues`
- **CI/CD & DevOps:** GitHub Actions (Automated macOS builds, multi-platform test runner, automated GitHub Pages deployment, GitHub Releases)
- **Distribution:** Standalone Universal DMG installer with `/Applications` drag-and-drop staging

---

## 4. Suggested Content Additions for the Website

Claude should assess the current blog/website stack (e.g. Next.js, Astro, Hugo, Jekyll, Tailwind, MDX) and add the following two components:

### A. Portfolio Project Card / Entry
- **Project Name:** Headroom
- **Category:** macOS Systems Programming / Developer Tools / Open Source
- **Role:** Creator & Lead Engineer
- **Timeline:** 2026
- **Short Summary (1-2 sentences):**  
  *An open-source macOS APFS forensics and disk reclamation utility that demystifies Apple's opaque "System Data" allocations, calculates cache rebuild costs, and safely isolates files in a 7-day quarantine vault.*
- **Key Tags:** `Swift`, `SwiftUI`, `APFS`, `macOS Internals`, `Systems Architecture`, `Open Source`
- **CTAs:**
  - `View on GitHub` $\rightarrow$ `https://github.com/syed-usman/headroom`
  - `Live Demo / Website` $\rightarrow$ `https://syed-usman.github.io/headroom/`
  - `Download .dmg (v0.1.0)` $\rightarrow$ `https://syed-usman.github.io/headroom/downloads/Headroom.dmg`

---

### B. In-Depth Engineering Blog Post / Case Study
*(Claude should draft or populate an MDX/Markdown post in the blog directory, using the structure below)*

**Suggested Title:**  
*Deconstructing macOS "System Data": How I Engineered an APFS Forensics Tool in Native Swift*

**Suggested Slug:** `/blog/building-headroom-apfs-macos-disk-reclaimer`

**Article Outline & Key Talking Points:**

1. **The Frustration: The Opaque "System Data" Black Box**
   - The common Mac user and developer experience: SSD filling up, System Settings displaying massive chunks of "System Data" with no delete button or explanation.
   - Why traditional visualizers (DaisyDisk, GrandPerspective) fall short: they visualize folder size but have no domain knowledge of developer toolchains or APFS snapshots.

2. **Reverse Engineering APFS Container Topology**
   - Explaining Apple's APFS architecture:
     - The **Sealed System Volume (SSV)**: An immutable cryptographic snapshot mounted at `/` (12.6 GB) that cannot change or leak.
     - **Cryptexes & Preboot**: Security micro-updates without full OS reinstalls (9.0 GB).
     - **Dynamic VM Swap**: Memory swap volume (2.1 GB+) dynamically allocated by macOS unified memory.
     - **Data Volume Runaways**: Why Docker `Docker.raw` disks, Xcode `DerivedData`, simulator runtimes, and local HuggingFace/Ollama weights get lumped into the "System Data" gray bar.

3. **Engineering the Rebuild Cost Metric**
   - The hidden cost of disk cleaning: deleting package caches or build artifacts saves disk space but costs 30+ minutes of developer compile time.
   - How Headroom calculates cost:
     $$\text{Cost} = f(\text{Rebuild CPU Seconds}, \text{Network Transfer Bytes})$$
   - Classifying targets into Tier 1 (Safe Discard), Tier 2 (High Rebuild Cost), and Tier 3 (System Sensitive).

4. **Safety by Design: The 7-Day Quarantine Vault**
   - Why `rm -rf` in disk utilities is unacceptable.
   - Architectural implementation of atomic moves into `~/.headroom/quarantine/` with JSON metadata manifests, enabling 1-click restores to exact POSIX paths.

5. **Building the Dual Interface: SwiftUI + CLI**
   - Architectural clean separation between the shared engine (`HeadroomCore`), the dark titanium SwiftUI desktop client, and the headless `headroom` terminal CLI.
   - Zero third-party dependencies: pure Swift standard library and macOS platform SDKs.

6. **Key Takeaways & Open Source Links**
   - Invitation to explore the codebase, star the repo, or download the DMG.

---

## 5. Visual Assets Reference

When building visual cards or banners on the site, Claude can utilize the following assets:
- **App Icon (Retina Master):** Available in the Headroom repository at [`docs/assets/icon.png`](https://raw.githubusercontent.com/syed-usman/headroom/main/docs/assets/icon.png)
- **App Screenshots / Mockups:** Reference the interactive mock views in [`docs/index.html`](https://github.com/syed-usman/headroom/blob/main/docs/index.html).

---

## 6. Action Plan for Claude

1. **Analyze Site Architecture:** Check the repo structure of the personal website (e.g. `pages/projects/`, `content/blog/`, `src/data/projects.ts`, etc.).
2. **Add Project Entry:** Insert Headroom into the featured projects list with badges, summary, and links.
3. **Publish Blog Post:** Create the markdown/MDX post covering the technical deep-dive.
4. **Cross-Link & Test:** Verify all links point to `https://github.com/syed-usman/headroom` and `https://syed-usman.github.io/headroom/`.
