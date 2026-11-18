# Headroom — Product Spec Sheet

| | |
|---|---|
| **Product** | Headroom (working name): a macOS disk-space reclaimer that explains every gigabyte and what it costs to get back |
| **Status** | Draft v0.1 |
| **Date** | 2026-11-08 |
| **Platform** | macOS 15 Sequoia and later, Apple silicon first. On-device AI needs macOS 26 or later with Apple Intelligence |
| **Distribution** | Notarized direct download only (Developer ID signed & Apple notarized; bypasses Mac App Store sandbox to guarantee Full Disk Access, privileged helpers, and native CLI execution) |
| **Research basis** | [`research/market-research.md`](research/market-research.md), with raw notes and sources in [`research/notes/`](research/notes/) |

---

## 1. One-line positioning

> **Headroom tells you what each gigabyte on your Mac is, what it costs to rebuild, and how much space you actually got back, and lets you undo it.**

Other cleaners say "47 GB of junk found". Headroom says: "Xcode simulator runtimes, 38 GB. Re-downloaded on demand, about 7 GB per runtime. Not used in 140 days. Removed with `simctl`. Undo available for 7 days."

## 2. Problem

- Users with 256 GB and 512 GB Macs lose 50–150+ GB to space they can't explain. The worst of it sits in Apple's **"System Data"**, which Apple defines as a remainder and won't break down. Users report 360 GB, 700 GB and 1.75 TB on Tahoe.
- The space is usually **one runaway item**, not a pile of caches: Google Drive at 500 GB+, Photoshop scratch at about 860 GB, VMs kept in snapshots at 400 GB+, `Docker.raw`, simulators at 20–150 GB, pasteboard archives at 146 GB. macOS 27 adds 20–30 GB of Apple Intelligence models with no off switch.
- The existing tools fall short in different ways:
  - **Visualizers** (DaisyDisk, GrandPerspective) show sizes but not meaning.
  - **Suites** (CleanMyMac, MacCleaner Pro, BuhoCleaner) cover generic caches and have grown into cloud, Gmail and offers, not deeper storage coverage.
  - **Developer cleaners** (Mole, kondo, npkill) cover toolchains but delete permanently, misreport savings, and have destroyed user data.
- Today the workable path is a person plus ChatGPT or Claude running `du` and `rm` one folder at a time. It works, but it is slow and unsafe, and nothing carries over to the next time.

## 3. Target users

| Persona | Typical machine | Main space users | What they need |
|---|---|---|---|
| **Developer** (primary) | 512 GB MacBook Pro | Xcode, Docker, node_modules, Rust/Gradle, simulators, ML models, AI-agent dotdirs | Safe, deep dev cleanup with rebuild cost; project awareness |
| **AI and ML tinkerer** | 512 GB to 1 TB | Ollama, LM Studio, Hugging Face caches, Python envs | Model inventory, dedupe-aware deletion |
| **Creative pro** | 512 GB to 1 TB | Photoshop and Premiere scratch, render caches, sound libraries | Find runaway app stores; archive old projects |
| **Mainstream user with a full disk** | 256 GB Air | System Data, iOS backups, Messages, Downloads, Apple Intelligence | An explanation of System Data, one safe button, no scareware |

## 4. Goals and non-goals

**Goals**
1. Account for **every byte** on the Data volume, including System Data, and reconcile the total to Apple's figures.
2. Reclaim space **safely**: nothing is permanently deleted by default, and every action can be undone.
3. Report **measured** reclaimed space: the real change in container free space.
4. Be the **reference knowledge base** for what is safe to remove on macOS: open, schema-validated and community-maintained.
5. Prevent recurrence by **watching growth** and explaining what grew.

**Non-goals**
- RAM "cleaning", CPU and temperature gauges, malware or antivirus scanning, privacy "cleaning".
- Gmail and cloud-storage cleanup, an offers or notification center, upsell flows.
- Blanket wiping of `~/Library/Caches`. macOS purges these itself, and wiping them makes the system slower.
- Modifying the sealed system volume, or "removing" Apple Intelligence models. Headroom explains these instead.
- Windows and Linux support in v1. The rules KB format should stay OS-gated so it can extend later.

## 5. Product principles

1. **Explain before you delete.** Every item shows what it is, who owns it, its tier, its rebuild cost and the evidence behind the verdict.
2. **The knowledge base first, AI second.** Verdicts come from reviewed rules. AI only explains unknowns, is labelled "unverified", and never writes commands.
3. **Native first.** Use the owning tool's own cleanup command where one exists (`simctl`, `docker`, `brew`, `hf`, `pnpm`, `uv`, `tmutil`) rather than `rm -rf`.
4. **Measure, don't estimate.** Show allocated sizes, deduplicate clones and hard links, and report the before/after free-space change.
5. **Reversible by default.** Use quarantine, then Trash, then permanent deletion, in that order. Permanent deletion only happens on explicit request.
6. **Open and auditable.** The rules are public, there is no telemetry by default, and the privileged helper is documented.

## 6. Classification model (tiers)

Every scanned byte is assigned to exactly one tier. The tier drives the default action and whether automation is allowed.

| Tier | Name | Definition | Examples | Default action | Automation allowed |
|---|---|---|---|---|---|
| **T1** | Rebuildable | Regenerated automatically, with no network needed | DerivedData, compiler caches, Electron Code Cache, QuickLook thumbnails | Clean (quarantine) | Yes |
| **T2** | Re-downloadable | Comes back via network, costing time and GB | Simulator runtimes, Docker images, HF/Ollama models, package-manager stores, `.ipsw` | Suggest, showing download cost | Opt-in, with an age threshold |
| **T3** | Stale | Build output of inactive projects or unused envs | `node_modules` and `target/` in repos with no commit for 6+ months, old conda envs | Suggest | Opt-in |
| **T4** | Orphaned | Left behind by apps that are no longer installed | `Application Support/<gone app>`, Containers, LaunchAgents of removed apps | Suggest, with match evidence | No |
| **T5** | Personal | User-created or irreplaceable | Videos, Documents, Photos, iOS backups, Messages attachments | Surface only, or offer to archive | Never |
| **T0** | System-managed | Owned by macOS; only Apple's own controls apply | Apple Intelligence models, sealed system volume, Spotlight index, swap, staged OS updates | Explain, and link to Apple's controls | Never |
| **T?** | Unknown | No matching rule | — | Explain (AI, unverified); queue for a rule | Never |

---

## 7. Feature specification

Priorities: **P0** = MVP must-have, **P1** = v1.0, **P2** = after v1.0.

### F1. Scanner and APFS-accurate measurement (P0)

**Requirements**
- Use bulk enumeration (`getattrlistbulk`) and handle the ERANGE edge case when the buffer is exactly filled. Use parallel traversal, with a target of a full scan of 1M files in under 60 seconds on an M-series Mac. *(Benchmark to be set.)*
- Report **allocated** size (the `totalFileAllocatedSize` equivalent), not logical size.
- Count each hard link once and each clone once, including partial clones. This matches DaisyDisk, the current accuracy leader.
- Detect sparse files (`Docker.raw`, VM images) and report their logical and physical sizes separately.
- Track purgeable space, other APFS volumes in the container, and local snapshots separately.
- Work with **almost no free space**: no large on-disk index, and a scan cache that degrades gracefully.
- Run incremental rescans driven by FSEvents.

**Acceptance criteria**
- The scanned total plus unexplained space matches the container's used space within a reasonable ~5% tolerance, accounting for APFS purgeable allocations and ongoing filesystem write activity.
- Sizes for a cloned 10 GB file pair show 10 GB, not 20 GB.

### F2. System Data ledger (P0, headline feature)

One screen that rebuilds Apple's "System Data" figure bucket by bucket and reconciles it with Storage settings and `diskutil apfs list`.

| Bucket | Source | Typical action |
|---|---|---|
| Local snapshots (Time Machine) | `tmutil listlocalsnapshots` | Delete via `tmutil` (native) |
| Local snapshots (third-party: CCC, etc.) | APFS snapshot list | Explain owner; link to that app |
| VM disks (Parallels, UTM, VMware) | Rules KB | Archive or compact |
| `Docker.raw` / OrbStack `data.img` | Rules KB | Prune → compact → verify shrink |
| Simulator runtimes and devices | `simctl` | Native delete |
| iOS/iPadOS backups, `.ipsw` | MobileSync, iTunes paths | Archive or delete |
| App scratch and runaway stores | Rules KB + growth watcher | Per-rule |
| Cloud-sync caches (Drive, Dropbox, OneDrive) | CloudStorage, provider caches | Explain; use the provider's offload, **never delete synced files** |
| Swap, sleepimage | `/private/var/vm` | Explain (T0) |
| Spotlight index | `.Spotlight-V100` | Explain; offer re-index guidance |
| Document versions | `.DocumentRevisions-V100` | Explain (T0) |
| Apple Intelligence models | Asset paths | Explain (T0); can't be removed in macOS 27 |
| Logs, diagnostic reports, `/private/var/folders` | Rules KB | Clean T1 subsets |
| Clipboard and pasteboard archives | Rules KB | Clean, with an explanation |
| File-system overhead | Calculated | Explain |
| **Unexplained remainder** | Calculated | Show the size and the reason (needs FDA, other users' homes, TCC-blocked) |

**Acceptance criteria:** the sum of mapped buckets and the unmapped remainder explains Apple's System Data figure within a realistic 5–10% margin of error (reflecting dynamic swap and purgeable snapshot churn), and every mapped bucket has an actionable verdict.

### F3. Rules knowledge base (P0)

A public, declarative, schema-validated rules repository: the core asset and the community moat.

**Schema (draft)**

```yaml
id: xcode-simulator-runtimes
version: 3
title: Xcode simulator runtimes
owner: { app: Xcode, bundle_id: com.apple.dt.Xcode }
os: { min: "15.0", verified_on: ["26.2", "27.0"] }
detect:
  paths:
    - /Library/Developer/CoreSimulator/Volumes/*
    - ~/Library/Developer/CoreSimulator/Devices/*
  markers: []                 # e.g. Cargo.toml → target/
  cachedir_tag: false         # honour CACHEDIR.TAG
  requires_installed: com.apple.dt.Xcode   # optional gating
tier: re-downloadable
explanation: >
  Simulator OS images used to run iOS/watchOS/visionOS apps in Simulator.
  Xcode re-downloads a runtime the next time you target it.
rebuild_cost:
  network_gb: 7               # per item, approximate
  minutes: 10
  needs_credentials: false
  side_effects: "Simulator devices on this runtime are removed."
guards:
  blocked_by_processes: [Simulator, xcodebuild, Xcode]
  min_age_days: 30
action:
  native: "xcrun simctl runtime delete --notUsedSinceDays {{min_age_days}}"
  fallback: quarantine        # quarantine | trash | none
  post_verify: "xcrun simctl runtime list"
risk: low                     # low | medium | high
provenance: { author: "@contributor", reviewed_by: ["@maintainer"], sources: ["https://…"] }
```

**Requirements**
- JSON Schema plus a CI linter on every PR: path safety (no rule may match a denylisted path), required fields, test fixtures.
- Fields that neither Winapp2 nor CleanerML has: `tier`, `rebuild_cost`, `native`, `guards`, `post_verify`, `verified_on`, `provenance`.
- Borrow from prior art: CleanerML's OS gating and running-process guards, Winapp2's "flavors" and aggressive tier, clean-dev-dirs' marker-file → target mapping, CACHEDIR.TAG auto-detection.
- **License: permissive (CC0 or CC-BY-4.0) from day one.** Mole is GPL-3.0, so use it as a coverage checklist only and never copy its code or rules.
- Signed rule bundles; the app updates rules independently of app releases.
- Target: **≥150 rules at v1.0**, enough to match Mole's ~57 dev cleanup functions and 34 project-artifact targets and go beyond them on ML and creative apps.

### F4. Safety engine (P0, brand-defining)

- **Quarantine by default.** Items move to a same-volume quarantine (instant, no copy) and are kept for N days (default 7). Space is reported as "pending" until the quarantine is purged. The user can choose "purge now" to get the space immediately.
- **Undo log.** Every action records the item, size, rule ID, command run, timestamp and restore path, with one-click restore.
- **Hard denylist**, checked against the resolved absolute path before every action:
  - `/`, `$HOME`, `~/Documents`, `~/Desktop`
  - Photos, Mail, Messages and Notes stores
  - `~/Library/Mobile Documents` and `~/Library/CloudStorage`, because deletions there propagate to other devices
  - Keychains, the TCC database, MDM profiles, Group Containers
  - Staged OS updates, the sealed system volume
- **Path hygiene.** Quote and canonicalize every path, never pass paths through shell expansion, refuse `~`-literal and empty variables, and refuse symlinks that escape the target root. This avoids the `rm -rf ~/` failures seen with coding agents.
- **Containers.** Only `Containers/<id>/Data/Library/Caches` is cleanable.
- **AI-agent dotdirs** (`~/.claude`, `~/.codex`, `~/.cursor`, etc.): explicit allowlisted subpaths only, never whole directories. *(Mole permanently deleted Claude Code memory, issue #823.)*
- **Process guards** per rule. Seed list: Xcode, Simulator, xcodebuild, Gradle daemon, pnpm, uv, bun, Docker, plus a check for open files.
- **Git guard.** Never touch git-tracked files or lockfiles (`*.lock`, `Podfile.lock`, `pubspec.lock`, `package-lock.json`).
- **Dry-run everywhere.** The UI preview and the CLI `--dry-run` produce identical plans.

### F5. Cleanup execution and honest reporting (P0)

- Run each rule's native command where defined. Otherwise apply its fallback (quarantine or Trash).
- **Report measured free space:** read container free space before and after, and show the change. If the change is smaller than expected, explain why (held by snapshot X, sparse file not compacted, quarantine pending, purgeable).
- **Docker and VM flow:** prune inside the VM, compact the host image, then verify the host file actually shrank. Report failure plainly if it didn't.
- **Snapshots:** list snapshots by owner and offer explicit `tmutil deletelocalsnapshots`. Explain that third-party snapshots must be managed in their own app.
- Never claim reclaimed space for purgeable caches macOS would remove on its own. Show those separately as "macOS-managed".

### F6. Developer and ML coverage (P1, launch rule catalogue)

| Ecosystem | Items | Native command |
|---|---|---|
| Xcode | DerivedData, Archives (old), iOS DeviceSupport, simulator devices and runtimes, previews, docs cache | `simctl delete unavailable`, `simctl runtime delete` |
| Docker / OrbStack / Colima | Images, build cache, volumes (opt-in), `Docker.raw` compaction | `docker system/builder prune` |
| JavaScript | node_modules (stale), npm, pnpm and yarn caches and stores, bun cache, `.next`, `.turbo`, `.parcel-cache` | `npm cache clean`, `pnpm store prune` |
| Python | pip, uv and poetry caches, stale venvs, conda pkgs and envs, `__pycache__` | `uv cache prune`, `conda clean -a` |
| Rust / Go / JVM | `target/` (stale), cargo registry, Go build and mod cache, Gradle caches and daemons, `.m2` | `cargo cache`, `go clean -cache`, Gradle |
| Homebrew | Old versions, downloads, **runaway logs** | `brew cleanup -s` |
| ML models | Hugging Face hub (Xet-shared blobs), Ollama, LM Studio, torch hub, diffusers | `hf cache prune`, `ollama rm` |
| AI agents and IDEs | Claude, Codex and Cursor caches (allowlisted subpaths), VS Code and JetBrains caches, extension caches | — |
| Mobile and other | CocoaPods, Carthage, Flutter, Android SDK, emulators, Unity, Nix | `pod cache clean`, etc. |
| Creative | Photoshop scratch, Premiere/AE media cache and ChunkStorage, Final Cut render files, Logic and GarageBand libraries | Guarded (app must be closed) |

### F7. Project awareness (P1)

- Discover projects under user-chosen roots by marker files (`package.json`, `Cargo.toml`, `*.xcodeproj`, `pyproject.toml`, `build.gradle`, …).
- Combine several staleness signals: **last git commit date** (unique to Headroom), newest source mtime, open-file check, and a "recently opened in an IDE" hint.
- Only treat `build/`, `bin/`, `vendor/` or `dist/` as artifacts when a marker file confirms the project type.
- Per project, show the artifact size, the rebuild command (`npm ci`, `cargo build`), an estimated rebuild time and size, and a pin to protect it.

### F8. Orphan detection (P1)

- Match leftovers against installed apps by bundle ID, receipt (`pkgutil`), team ID, vendor prefix and LaunchAgent label.
- Show the **evidence** and a **confidence score** for each match, quarantine by default, and keep a user exclusion list.
- Context: Pearcleaner, the open-source leader, has been on hold since late 2025. Nektony over-matches; in Macworld's test it removed the App Store.

### F9. Growth watcher and menu bar (P1)

- Run a daily background delta scan driven by FSEvents and attribute growth to **rules and tiers, not just folders**. Example: "Docker build cache +12 GB this week. Low rebuild cost. [Prune]".
- Forecast when the disk will be full.
- Take automatic **before/after snapshots around macOS updates** ("System Data +38 GB after 27.0: Apple Intelligence 22 GB, …").
- Flag runaway items: alert when any single item grows by more than X GB per day (Photoshop scratch, Drive cache, Homebrew log).
- Keep the menu bar quiet: one reclaimable-GB badge and free space. No CPU or RAM gauges.

### F10. Explain unknowns: on-device AI (P2, reframed)

- Use Apple's on-device Foundation Model (macOS 26+). Nothing leaves the Mac by default. Optional cloud models need explicit opt-in and send **metadata only**: path, size, file types, bundle IDs, dates.
- Label every AI verdict **"Unverified — no rule"**. The model **never generates commands**; it can only map an item to existing KB actions or suggest a tier.
- "Contribute rule" turns an AI explanation into a draft rule PR in the human-reviewed queue, so each AI query grows the KB.
- Context: CleanMyMac Smart Insights and Diskfern already ship on-device explanations. This is table stakes, not a headline.

### F11. Archive and offload (P2)

- Copy to an external drive or NAS clone-aware, verify by checksum, then remove locally, leaving an index entry or optional stub. Restore with one click.
- Eligible items: T5 personal data (old projects, videos, iOS backups, VMs) and T2 assets the user wants kept offline (model files).
- Unverified: no incumbent offers this. *(Research gap; confirm before marketing it as unique.)*

### F12. Policies and automation (P2)

- Storage Sense-style policies with age thresholds per category: T1 on by default, T2 and T3 opt-in, T4 and T5 never automatic.
- A "keep" pin on any item, project or rule.
- Trigger options: on a schedule, when free space drops below X GB, or after OS updates.
- Auto mode only applies rules with `risk: low`.

### F13. CLI, scan report and read-only MCP server (P1 CLI, P2 MCP)

- `headroom scan | plan | clean --tier 1 --dry-run | undo <id> | ledger | watch`, using the same engine and rules as the app.
- Exportable structured scan report (JSON or Markdown) to hand to any agent.
- **Read-only MCP server** exposing scan, ledger, explain and plan, so coding agents get grounded answers. Execution stays in Headroom behind user confirmation; agents can't delete.

### F14. Clone-aware deduplication (P2, experimental)

- Replace exact duplicate files with APFS clones instead of deleting either copy. The space is reclaimed and both paths keep working.
- Unverified: no duplicate finder documents doing this. Validate before promising it.

---

## 8. Gap register: what the market doesn't do

| # | Gap | Evidence | Closest competitor today | Headroom answer | Feature | Confidence |
|---|---|---|---|---|---|---|
| G1 | **No full System Data breakdown** | Apple calls it a remainder and has no Time Machine category; Oakley: "desperately needs further information" | DaisyDisk: three-way "hidden space" split | Reconciled bucket ledger | F2 | High |
| G2 | **No rebuild-cost estimates** | No tool quantifies re-download GB or rebuild minutes | MegaCleaner and Crumb: qualitative "what rebuilds it" | `rebuild_cost` in every rule | F3, F7 | High |
| G3 | **No declarative, community rules KB for macOS** | Mole's rules are Bash, kondo's are Rust; Winapp2 and CleanerML are Windows-centric | None | Open, schema-validated, permissively licensed KB | F3 | High |
| G4 | **No git-commit-based staleness** | Mole uses 7-day activity and only uses git to protect tracked files; others use mtime | Mole (partial) | Multi-signal staleness including last commit | F7 | High |
| G5 | **No real undo; permanent deletion common** | Mole deletes permanently; DaisyDisk has a countdown only; Gemini 2 and Files Magic are the rare exceptions | Diskfern and clean-dev-dirs (Trash) | Quarantine plus undo log by default | F4 | High |
| G6 | **Dishonest or inaccurate "freed" numbers** | Mole reported 2.98 GB when the real gain was 19 GB (#1023); `Docker.raw` doesn't shrink; snapshots pin blocks | None | Measured container free-space change, with reasons for any shortfall | F5 | High |
| G7 | **Heuristic deletion destroys user data** | Mole deleted Claude Code memory, a LaunchAgent, printers and XDG data; dev-cleaner deletes lockfiles; Nektony removed the App Store | — | Denylist, allowlisted subpaths, process and git guards | F4 | High |
| G8 | **Growth watchers don't say what grew** | Diskwatch, Disk Forecast and Disk Monitor stop at the folder level | Disk Forecast (forecast) | Rule-attributed growth, OS-update diffs, runaway alerts | F9 | High |
| G9 | **ML model stores poorly covered** | Mole has no HF or Ollama rules; HF Xet-shared blobs make `rm -rf` unsafe | LLM Cleaner, Diskfern (partial) | Native `hf cache prune`, Ollama and LM Studio rules | F6 | Medium |
| G10 | **Orphan detection is stalled or over-matches** | Pearcleaner on hold since late 2025; Nektony false positives | Nektony Remaining Files | Evidence-based matching with confidence scores | F8 | Medium |
| G11 | **Suites miss key space users** | No suite vendor page names Docker, node_modules, local snapshots or iOS backups | CleanMyMac (Xcode only) | Full dev and system coverage | F2, F6 | Medium |
| G12 | **AI agents clean disks with no grounding** | Agent `rm -rf` incidents; hobby MCP servers with no KB | Disk Map hand-off, Mole skills | KB-backed read-only MCP server and scan report | F13 | Medium |
| G13 | **No archive with guaranteed restore** | Not in any incumbent feature list | Storage Sense (Windows) | Verified archive with one-click restore | F11 | Low (unverified) |
| G14 | **No clone-based dedupe** | No duplicate finder documents it | — | Replace duplicates with clones | F14 | Low (unverified) |
| G15 | **Trust deficit** | Scareware history, fake CleanMyMac installers with malware, subscriptions, MacKeeper renewal complaints | Open-source tools (Mole, Pearcleaner, OnyX) | Open rules, no telemetry, one-time price, documented helper | §11, §12 | High |
| G16 | **Scanner fails when the disk is full** | DaisyDisk's own caches need free space (Oakley) | — | Low-footprint scan mode | F1 | Medium |

## 9. Table stakes: competitors already do these, so match them, not headline them

| Capability | Who ships it | Headroom stance |
|---|---|---|
| On-device "explain this item" AI | CleanMyMac Smart Insights, Diskfern | Fallback for unknowns only (F10) |
| Clone- and hard-link-aware sizing | DaisyDisk | Required (F1) |
| Folder-level "what grew" plus disk-full forecast | Diskwatch, Disk Forecast, Disk Monitor | Exceeded by rule attribution (F9) |
| Recent-activity guard on project purge | Mole (7 days) | Exceeded by multi-signal staleness (F7) |
| Process-running checks, native commands | Mole | Required, declared per rule (F3, F4) |
| Safe/Review labels, menu-bar badge | Raycast Dev Cache Cleaner | Included (F9) |
| Leftovers of deleted apps | Nektony, Pearcleaner | Included, with evidence (F8) |
| Preview before delete | All | Required |
| Treemap or visual explorer | DaisyDisk, GrandPerspective | Secondary view, grouped by meaning, not path |

## 10. Explicitly out of scope

RAM cleaning · malware scanning · Gmail and cloud cleanup · offers or notification center · blanket `~/Library/Caches` wipes · CPU and temperature monitors · "removing" Apple Intelligence models · any permanent deletion by default · AI-generated shell commands.

---

## 11. Technical architecture

| Component | Tech | Notes |
|---|---|---|
| **Core engine** | Swift package (`HeadroomCore`) | Scanner, measurement, rules evaluator, planner, executor, undo log. Shared by the app, CLI and MCP server |
| **App UI** | SwiftUI | Overview by meaning, System Data ledger, item detail, projects, history and undo, settings |
| **Menu bar agent** | SwiftUI `MenuBarExtra` and a login item | Growth watcher, badge, alerts |
| **Privileged helper** | `SMAppService` daemon (macOS 13+) | Optional; limited to root-owned targets (snapshots, `/Library` caches). Narrow XPC API, publicly documented. No scripted privilege workarounds |
| **CLI** | Swift executable (`headroom`) | Same engine; Homebrew tap |
| **MCP server** | Read-only, over stdio | scan, ledger, explain, plan |
| **Rules KB** | Separate public repo: YAML, JSON Schema, CI linter, fixtures | Signed bundles fetched by the app |
| **AI** | Apple Foundation Models framework | On-device; optional cloud opt-in, metadata only |
| **Storage** | SQLite (scan index, history), small footprint | Must run in near-zero free space |

**Permissions:** Full Disk Access (required for a complete ledger, explained in onboarding), helper approval (`SMAppService` privileged helper for root-owned targets and local snapshots), and no network access needed except for rule updates.

**Distribution model:** Exclusively direct notarized download via developer website (Sparkle auto-updates). The Mac App Store is intentionally bypassed: App Sandbox rules prohibit Full Disk Access entitlements, disallow root-level `SMAppService` helpers, and block execution of external host CLIs (`docker`, `brew`, `xcrun simctl`), which would fatally compromise the product's core utility.

## 12. Business model

- **App pricing:** Direct checkout via Lemon Squeezy / Paddle as a one-time purchase in the **$29–$39** band (comparable to indie Mac utilities like Diskfern $19.99, DaisyDisk $9.99, and Sensei $59).
- **Feature gating:**
  - **Free tier:** Full APFS scan, System Data ledger breakdown, and safe T1 automatic rebuildable cleanup (DerivedData, compiler caches). Drives organic developer adoption.
  - **Paid tier:** T2–T4 deep reclamation (Docker/VM compaction, Simulator runtimes, ML models, stale project roots), background growth watcher, and archive/restore engine.
- **Rules KB:** Permissive open-source to foster community contributions and establish the reference database for macOS cleanup.
- **No telemetry** by default, no subscriptions, no dark patterns or scareware upsells.
- **Enterprise / Team tier (future):** Team seat licensing / MDM-deployable policies for developer organizations.

## 13. Competitive threats and response

| Threat | Signal | Our edge | Response |
|---|---|---|---|
| **CleanMyMac** (MacPaw) | Roadmap: "smarter cleanup for AI agents" and a CLI; Smart Insights is the first of an "upcoming series" of AI tools | Subscription, offers surface, closed rules, no measured reporting | Launch the open KB and System Data ledger first; compete on honesty and one-time pricing |
| **Mole** (open source, 74k★, $19 app) | Near-daily releases, agent skills, native app | Permanent deletion, documented data loss, misreported savings, GPL Bash rules | Safety engine, measured reporting, declarative KB that is easy to contribute to; court contributors early |
| Diskfern, MegaCleaner, Raycast extensions | Pushing the price of "explain plus dev cleanup" towards zero | Narrow scope | System-wide ledger, watcher, depth |
| Apple Storage settings | Steady improvement (allocated sizes, Developer and Apple Intelligence categories) | No System Data breakdown, weak recommendations | Never just restate Apple's categories |

**Window:** about 12 months, before CleanMyMac ships its developer and agent roadmap or Mole adopts Trash-by-default and declarative rules.

## 14. Success metrics

- **Reclaim:** conservative, safe space recovery rather than aggressive over-cleaning (reasonable target of 10–20 GB on typical 512 GB developer Macs, prioritizing system stability and zero workflow breakage over vanity numbers).
- **Accuracy:** System Data ledger accounts for Apple's figures within a realistic 5–10% margin; reported "freed" space strictly matches measured APFS container delta without claiming purgeable or OS-managed cache bloat.
- **Safety:** zero confirmed data-loss or broken workflow incidents; undo used in under 2% of actions (signaling conservative, trustworthy defaults).
- **KB:** rule count, number of external contributors, median PR review time, and the share of scanned bytes covered by rules (target ≥ 90% of non-personal cache/temp bytes).
- **Retention:** share of users with the watcher enabled after 30 days.

## 15. Milestones

| Milestone | Scope |
|---|---|
| **M0: CLI prototype** | F1 scanner, F3 schema with about 40 rules, F4 quarantine and undo, F5 measured reporting, `scan/plan/clean/undo`. Validate on the author's own Mac against the earlier manual cleanup with Claude |
| **M1: MVP app** | SwiftUI overview by meaning, F2 System Data ledger, public KB repo and linter, about 100 rules |
| **M2: v1.0** | F6 full dev and ML catalogue (≥150 rules), F7 projects, F8 orphans, F9 watcher, privileged helper, notarized release, pricing |
| **M3: v1.x** | F10 on-device explain plus contribution queue, F13 MCP server, F11 archive, F12 policies, F14 clone dedupe (experimental) |

## 16. Risks and open questions

**Risks**
- A KB rule that is wrong can cause data loss at scale. Mitigations: review requirements, `risk` levels, quarantine by default, staged rollout of rules.
- macOS changes paths every release (DevCleaner already lags Xcode). Mitigation: a `verified_on` field and CI on beta macOS.
- Full Disk Access onboarding friction, and distrust of any privileged helper.
- Competitors could adopt the open KB directly. This is acceptable: it becomes the standard, and the app wins on UX and safety.

**Open questions and unverified research claims**
- Is offloading to an external drive truly absent from competitors? Is clone-based dedupe? *(Hands-on testing needed.)*
- Do GrandPerspective and OmniDiskSweeper handle clones correctly? Does CleanMyMac report APFS-accurate sizes?
- Is Apple Intelligence space counted under "macOS" or "System Data" in macOS 27?
- Exact FSEvents behaviour for low-overhead incremental growth tracking.
- Free/paid split and final price point.
- Minimum macOS version: 15 (wider reach) or 26 (on-device AI everywhere)?
- Product name (Headroom, Reclaim, Ballast) and trademark check.

---

## Appendix A: Competitor capability matrix

See [`research/market-research.md` → Capability matrix](research/market-research.md#capability-matrix-every-feature-exists-somewhere-no-product-has-them-all) for the full 13-tool matrix with sources.

## Appendix B: Competitor quick reference (Nov 2026)

| Tool | Type | Price | Strength | Weakness |
|---|---|---|---|---|
| CleanMyMac 5.7.4 | Suite | $39.95/yr; $89.99 one-time (App Store) | Brand, Smart Insights AI, purgeable task | Wide not deep, offers, subscription, flags needed files |
| MacCleaner Pro 4.0.5 | Suite | from $14.95/mo | Six-app bundle | "System data" label only |
| BuhoCleaner | Suite | $39.99/yr; $67.99 lifetime | Xcode quick action | Generic |
| MacKeeper | Suite | Subscription | — | Renewal and upsell complaints |
| DaisyDisk | Visualizer | $9.99 | APFS-accurate, hidden-space split | No meaning; force-purge not in App Store version |
| Apple Storage settings | Built-in | Free | Allocated sizes, Developer category | System Data is a remainder |
| Pearcleaner | OSS uninstaller | Free | Orphan search | On hold since late 2025 |
| Nektony App Cleaner | Uninstaller | $34.95 | Remaining Files | False positives |
| Mole | OSS CLI + app | Free / $19 | Breadth, process guards, native commands, 74k★ | Permanent delete, data-loss bugs, misreported savings |
| kondo / npkill / clean-dev-dirs | OSS dev | Free | Project artifacts | mtime only; `rm -rf` (kondo) |
| DevCleaner for Xcode | OSS dev | Free | Xcode categories | Can't remove simulators, lags Xcode |
| MegaCleaner / Crumb | Dev | Free / paid | "What rebuilds it" | Qualitative only |
| Raycast Dev Cache Cleaner | Extension | Free | Safe/Review, age gate, badge | Narrow |
| Diskfern | AI analyser | $19.99 lifetime | On-device AI, Trash-only | Narrow cleanup |
| Disk Map | Analyser | Free | Hands off to the user's own AI agent | No cleanup engine |
| Diskwatch / Disk Forecast | Watchers | Paid / free | What grew, forecast | Folder level only |
