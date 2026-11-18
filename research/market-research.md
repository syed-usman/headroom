# Win Mac cleanup by explaining, not deleting

As of November 2026, nobody owns the job of explaining what each gigabyte on a Mac is and what it would cost to get back. The proposed product can take that position, but only if it changes its emphasis. The market has two halves. Broad consumer suites (CleanMyMac 5.7, MacCleaner Pro, BuhoCleaner, MacKeeper, CCleaner) have grown outward into cloud, Gmail, malware and offers. A fast-growing long tail of developer cleaners, led by the open-source CLI Mole (74k GitHub stars), cleans dozens of toolchains but deletes permanently and has a record of destroying user data. Several pieces of the concept already exist elsewhere. CleanMyMac Smart Insights and Diskfern ship on-device LLM "explain this item". Diskwatch and Disk Forecast ship "what grew" menu-bar watchers. DaisyDisk already does clone-aware sizing. Mole already does recency- and git-aware project purging. No product combines these, and five things exist nowhere in shipping form:

- a full, reconciled breakdown of System Data
- rebuild-cost estimates
- a declarative, community-maintained macOS rules knowledge base
- staleness based on the last git commit
- a quarantine with real undo

The recommendation is to keep the classification tiers, the rules knowledge base, System Data attribution and APFS-honest measurement at the core. Demote LLM explanations to a labelled fallback. Turn the growth watcher into a watcher that says what the growth means. Treat offload as "archive and restore" rather than a headline. Ship safety and open rules as the brand. The two main threats are CleanMyMac, whose roadmap includes "smarter cleanup for AI agents" and a CLI, and Mole, which is adding a native app, agent skills and new rules almost daily.

## Users lose to one runaway item, not a pile of caches

The core pain is not generic junk. Users see a huge, unexplained "System Data" figure that Apple's Storage settings won't break down or let them delete. Apple defines System Data as files "that don't belong to any more specific category" ([Apple Support](https://support.apple.com/en-us/102624)). Howard Oakley calls it "an etcetera, a ragbag". It has **no Time Machine category**, so snapshot space lands there, and his advice is blunt: "don't trust Storage settings" ([Eclectic Light](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/)). In his December 2025 explainer, System Data took about half the SSD and "desperately needs further information, but doesn't have a button" ([Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)). Apple Community threads on Tahoe report System Data of **360 GB, 700 GB and 1.75 TB** ([thread](https://discussions.apple.com/thread/256239409); [thread](https://discussions.apple.com/thread/256228420)).

When someone does find the cause, it is nearly always one thing growing without limit:

- **Over 500 GB from Google Drive** ([Apple Community](https://discussions.apple.com/thread/256062620))
- Photoshop scratch that took System Data to about **860 GB** while the app was open and back to 18 GB when it closed ([Adobe Community](https://community.adobe.com/t5/photoshop-ecosystem-discussions/scratch-disk-issue-photoshop-is-filling-all-space-in-my-harddrive-via-system-dat-a/m-p/14243966/highlight/true))
- 240 GB of video-editor "ChunkStorage" ([Adobe Community](https://community.adobe.com/t5/premiere-pro-discussions/premiere-pro-2025-crashes-and-takes-too-much-volumes/m-p/14936280))
- VMs captured in snapshots, with one case over 400 GB ([Eclectic Light](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/))
- Pasteboard archives whose removal cut System Data from 163 GB to 17 GB ([Eclectic Light](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/))

macOS 27 added a new one. Apple Intelligence models measured at **20.67–30.16 GB**, and **Apple removed the disable toggle** ([MacRumors](https://macrumors.com/2026/09/23/apple-intelligence-30gb-some-macs-macos-27)). On a 256 GB Mac, roughly 28 GB of fixed system overhead already leaves at most about 228 GB for the Data volume ([Eclectic Light](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/)). So one VM or video project can tip the machine into a crisis.

Generic cache wiping is weaker than it looks. macOS already purges opted-in caches through `deleted`, and wiping active caches mainly makes things slower: Finder gallery view crawls until QuickLook previews rebuild ([Eclectic Light](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)). One Apple Community responder would recover only about 2.6 GB from `~/Library/Caches` ([Apple Community](https://discussions.apple.com/thread/256036043)). The value is in **attribution**: naming the owner of the GB and saying what happens if you remove it. That is exactly what the concept's tiers propose.

## The landscape splits into broad suites and a long tail of narrow tools

**Commercial suites have grown wider, not deeper.** CleanMyMac 5.7.4 (6 Nov 2026) costs **$39.95/yr per Mac**, or $89.99 one-time on the Mac App Store. Its junk pitch is "20 more types of junk" ([cleanmymac.com](https://cleanmymac.com/); [App Store](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12)). Its 2025–26 release notes add:

- Free Up Purgeable Space (Feb 2025)
- cloud cleanup for iCloud, Google Drive, OneDrive and Dropbox
- Smart Insights (Oct 2025)
- a My Activity dashboard
- a Notification Center for "offers" (Aug 2026)
- Gmail cleanup (Sep 2026)
- a Chrome extension

The notes never mention developer cleanup or Time Machine snapshots ([MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)). Macworld's 2026 verdict was "Expensive; overlaps with built-in macOS tools; occasionally flags files users need" ([Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)).

The rivals look similar:

- **MacCleaner Pro 4.0.5** is a bundle of six apps starting at $14.95/mo. It lists "system data" as a category with no breakdown ([Nektony](https://nektony.com/mac-cleaner)).
- **BuhoCleaner** costs $39.99/yr or $67.99 lifetime, and has a 3 GB free tier ([Toolradar](https://toolradar.com/blog/best-free-mac-cleaners)). Its only developer feature is an "Xcode Cache Cleaner" quick action ([Dr.Buho](https://www.drbuho.com/buhocleaner)).
- **MacKeeper** has a reputation built on auto-renewal and upsell complaints ([Nektony](https://nektony.com/reviews/mackeeper)).

None of the suite vendor pages lists Docker, node_modules, local snapshots or iOS backups as named categories.

**Visualizers show size but not meaning.** DaisyDisk is the APFS-accuracy leader:

- It counts a hard link or clone once, including partial clones ([DaisyDisk](https://daisydiskapp.com/guide/4/en/HardLinks)).
- It splits "hidden space" into purgeable, other volumes and "still hidden" ([DaisyDisk](https://daisydiskapp.com/guide/hidden-space)).
- It can force a purge, though not in its App Store edition ([DaisyDisk](https://daisydiskapp.com/guide/purgeable-space)).

Even so, users report purges that achieve little, such as deleting 142 GB of "purgeable" and getting about 5 GB back ([Apple Community](https://discussions.apple.com/thread/250490791)). GrandPerspective, OmniDiskSweeper and Disk Inventory X give treemaps or lists with no explanation ([dissectmac](https://dissectmac-com.pages.dev/blog/daisydisk-alternatives)).

**Apple's Storage settings is better than it was.** It now reports allocated rather than nominal size: a 100 GB sparse VM shows as about 62 GB. It surfaces Developer (Xcode) and Apple Intelligence space. But its recommendations amount to iCloud upsells and Empty Trash ([Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)).

**Uninstallers are in flux.**

- FreeMacSoft AppCleaner only handles apps you drag in.
- Nektony's "Remaining Files" scans for leftovers of apps already deleted ([CleanMyMac blog](https://cleanmymac.com/blog/nektony-app-cleaner-review)). In Macworld's test it removed critical items, including the App Store, and Adobe apps had to be reinstalled ([Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)).
- **Pearcleaner** (about 15.1k stars) is the leading open-source orphan finder. It is "On Hold": development "has basically stopped since end of 2025" ([Pearcleaner README](https://cdn.jsdelivr.net/gh/alienator88/Pearcleaner@main/README.md)). Its sensitivity slider, exclusion list and condition builder were all added to cope with false positives ([newreleases](https://newreleases.io/project/github/alienator88/Pearcleaner/release/3.8.1)).
- AppZapper returned as AppZapper 3000 at $18 ([9to5Mac](https://9to5mac.com/2026/09/15/appzapper-3000-the-uninstaller-apple-forgot-returns-for-the-modern-mac-era/)).

**Developer cleaners are where the energy is.** Mole (tw93) has **74,274 stars**, a GPL-3.0 licence and release V1.70.0 on 8 Nov 2026 ([GitHub API](https://api.github.com/repos/tw93/Mole)). Its dev module runs to 6,328 lines, with about 57 `clean_*` functions and 207 `safe_clean` call sites. It covers:

- AI agents (Codex, Claude Desktop, cursor-agent)
- Docker, JVM, Python, Rust, Go and Nix
- Xcode DeviceSupport and CoreSimulator caches

It also has 34 project-artifact targets ([dev.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh); [purge_shared.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/purge_shared.sh)). It checks running processes before cleaning (Xcode, Simulator, Gradle daemon, pnpm, open files in node_modules) and calls native commands such as `docker builder prune`, `go clean -cache` and `brew cleanup` ([dev.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh)). A native Mole app costs **$19 one-time** ([tw93.fun](https://tw93.fun/projects/mole.md)).

Around Mole sit:

- marker-file project cleaners: kondo (23 project types) and clean-dev-dirs (16 languages, Trash by default) ([kondo](https://github.com/tbillington/kondo); [clean-dev-dirs](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md))
- npkill (9.5k stars) with multi-ecosystem profiles ([npkill](https://github.com/voidcosmos/npkill))
- DevCleaner for Xcode, 6 categories, already lagging Xcode path changes ([#59](https://github.com/vashpan/xcode-dev-cleaner/issues/59))
- MegaCleaner, free, claiming 39 scanners and showing regeneration commands ([megacleaner.app](https://megacleaner.app/))
- Crumb, which shows "what rebuilds it" for each category ([Crumb](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/))
- the free Raycast **Dev Cache Cleaner**, which labels items Safe (green) or Review (orange), only flags artifacts older than 30 days, and shows a menu-bar reclaimable badge ([Raycast](https://www.raycast.com/Undolog/dev-cache-cleaner))

**AI-assisted tools follow three patterns.**

- **On-device explainers.** CleanMyMac Smart Insights uses Apple's Foundation Model fully on the Mac and needs macOS 26 with Apple Intelligence ([MacPaw](https://macpaw.com/news/introducing-smart-insights)). Diskfern Disk Advisor does the same, stages but never deletes, sends deletions to Trash, and costs $19.99 lifetime ([Diskfern](https://www.diskfern.com/)).
- **Hand-off to the user's own agent.** Disk Map's "Ask AI" passes a metadata report to Claude Code, Codex or ChatGPT ([Disk Map](https://diskmap.app/)). Mole ships agent skills.
- **A crowd of hobby MCP servers.** Some are read-only on purpose; one author notes that deletion tools are what you "don't want an LLM driving unsupervised" ([Glama](https://glama.ai/mcp/servers/g3rsb8mx6k)).

**Growth watchers exist but stop at the folder level.**

- Diskwatch has a "What grew" view and a 20 GB warning level ([flowdrift.io](https://flowdrift.io/diskwatch/)).
- Disk Forecast predicts the date the disk will be full and reports "what grew most this week" ([diskforecast.com](https://diskforecast.com/)).
- Disk Monitor shows the top 5 folders that grew and warns that APFS-shared sizes shouldn't be summed ([GitHub](https://github.com/dohernandez/disk-monitor)).

## Capability matrix: every feature exists somewhere, no product has them all

Ratings come from vendor pages and the sources cited above. "Partial" means limited scope. "?" means the research could not verify it. Rows are representative tools; similar tools are grouped.

| Tool (price) | Meaning tiers | Explains items | System Data breakdown | APFS-accurate sizing | Dev caches | ML models | Project staleness | Orphan leftovers | Native commands | Rebuild cost | Trash / undo | Growth watcher | Offload | Open rules |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CleanMyMac ($39.95/yr) | No | Partial (AI Smart Insights) | Partial (purgeable task) | ? | Partial (Xcode) | No | No | Yes | ? | No | Preview only | No (system menu) | No (cloud cleanup only) | No |
| MacCleaner Pro / BuhoCleaner (~$40/yr) | No | No | No (label only) | ? | Partial (Xcode action) | No | No | Yes | No | No | Confirm dialog | No (RAM/CPU monitor) | No | No |
| DaisyDisk ($9.99) | No | Partial (hidden space only) | Partial (purgeable / hidden split) | **Yes** (clones, hard links) | No | No | No | No | Partial (purge) | No | Countdown | No | No | No |
| Apple Storage settings (free) | Partial (Apple categories) | Partial | **No** (remainder) | Yes (allocated) | Partial (Xcode) | No | No | No | N/A | No | No | No | iCloud only | N/A |
| Pearcleaner (free, on hold) | No | No | No | ? | Partial (dev env manager) | No | No | **Yes** (sensitivity) | Partial (brew) | No | ? | No | No | Source open |
| Nektony App Cleaner ($34.95) | No | No | No | ? | No | No | No | Yes (false positives) | No | No | Confirm | No | No | No |
| Mole CLI + $19 app | Partial | No (agent skills) | No | No (misreports, #1023) | **Yes** (~57 functions) | **No** | Partial (7-day activity, git-tracked guard) | Yes | **Yes** | No | **Permanent** in clean/purge; log only | No (`mo status` TUI) | No | Source open, GPL, Bash |
| MegaCleaner (free) | Partial | No | No | ? | Yes (39 scanners) | ? | Partial (30+ days) | ? | Shows commands | No | Trash | No | No | No |
| Crumb / Raycast Dev Cache Cleaner | Partial (Safe/Review) | Partial ("what rebuilds it") | Partial | ? | Yes | No | Partial (age) | No | Copy command | Qualitative | ? | Badge only | No | No |
| kondo / npkill / clean-dev-dirs (free) | No | No | No | No (npkill overstates) | Project artifacts | No | mtime only | No | No | No | Mixed (kondo `rm -rf`; c-d-d Trash) | No | No | Code, not rules |
| Diskfern ($19.99 lifetime) | No | **Yes** (on-device AI) | ? | ? | ? | Partial (lists Ollama/LM Studio) | No | ? | No | No | Trash | No | No | No |
| Disk Map (free) | No | Hand-off to user's agent | No | ? | No | No | No | No | No | No | Trash | No | No | No |
| Diskwatch / Disk Forecast / Disk Monitor | No | No | No | Partial (warns about overlap) | No | No | No | No | No | No | N/A | **Yes** (folder level, forecast) | No | Partial (OSS) |
| **Proposed concept** | **Yes** | KB first, LLM fallback | **Full, reconciled** | Yes + measured delta | Yes | Yes | **Git last commit** | Yes + evidence | Yes | **Yes** | **Quarantine + undo** | **Meaning-attributed** | Yes | **Declarative KB** |

Read down the columns and the structural gaps show up as empty cells. **Rebuild cost** is the only column with nothing better than "qualitative". No tool estimates re-download size, recompile minutes or a credential requirement; MegaCleaner and Crumb only describe what rebuilds an item ([megacleaner.app](https://megacleaner.app/); [Crumb](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/)). **A full System Data breakdown** is absent everywhere; DaisyDisk's three-way hidden-space split is the closest. **Declarative open rules** don't exist for macOS. Mole's rules are Bash functions, kondo's are Rust, and user config stops at whitelists ([Mole README](https://github.com/tw93/Mole); [kondo](https://github.com/tbillington/kondo)). **Git-commit staleness** is used by no one: Mole uses file activity and only uses git to protect tracked files. **Undo** is rare. Gemini 2 and Files Magic AI have it, DaisyDisk has a countdown, and Mole keeps a log but deletes permanently ([1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026); [GitHub Mole](https://github.com/tw93/Mole)). **Offload to an external drive** appears in no incumbent's feature list. Windows Storage Sense's "dehydrate unopened synced files after 30 days" is the nearest model ([Windows Central](https://www.windowscentral.com/software-apps/windows-11/how-to-free-up-space-automatically-with-storage-sense-on-windows-11)), but that absence comes from feature-list reading, not exhaustive testing.

## Five gaps competitors leave open, and two they have already closed

**Gap 1: System Data attribution and reconciliation.** Apple reports a residual. DaisyDisk reports "still hidden". Cleaners label it without explaining it. The parts are known from Apple, Eclectic Light and DaisyDisk:

- local snapshots (Time Machine and third-party, the latter unpurgeable by DaisyDisk)
- the Spotlight index
- document versions
- swap and sleepimage
- VM disks and Docker.raw
- simulator runtimes and iOS backups
- app scratch stores
- Apple Intelligence models
- file-system overhead

([DaisyDisk](https://daisydiskapp.com/guide/hidden-space); [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)). A ledger that fills each bucket with measured bytes and reconciles the total against Storage settings and `diskutil apfs list` would be the first of its kind. It also has to be honest about what can't be touched: Apple Intelligence models, the sealed system volume and `/System/Library/CacheDelete` ([Eclectic Light](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)).

**Gap 2: measured, honest reclamation.** Under APFS, deleting a file often frees less than its size. Snapshots pin deleted blocks for up to 24 hours. In Oakley's tests macOS **failed to purge a snapshot on at least two occasions**, and Disk Utility reported purgeable as 549 KB or 94.8 GB for the same state ([Eclectic Light](https://eclecticlight.co/2026/08/24/arent-snapshots-purgeable/)). Container free space is the reliable figure ([Eclectic Light](https://eclecticlight.co/2026/08/21/the-arithmetic-of-free-space/)). Competitors get this wrong in public. Mole reported 2.98 GB freed while free space rose by 19 GB ([#1023](https://github.com/tw93/Mole/issues/1023)). Docker image pruning frees space inside `Docker.raw` without shrinking the file on the host ([Docker forums](https://forums.docker.com/t/trouble-downsizing-docker-raw-using-docker-desktop/138443)). Reporting the measured container delta, plus "pending: held by snapshot X", is a trust feature competitors don't offer.

**Gap 3: rebuild cost and a declarative rules KB.** The only mature community rule sets are on Windows: Winapp2.ini (15+ years, CC-BY-SA-4.0, per-tool "flavors", an aggressive Winapp3 tier) and BleachBit's CleanerML (XML with an XSD, `os` gating, `running` process guards) ([GitHub Winapp2](https://github.com/MoscaDotTo/Winapp2); [BleachBit docs](https://docs.bleachbit.org/cml/cleanerml.html)). Neither has fields for risk tier, rebuild cost or native command. The Winapp2 history also carries a licensing warning: Piriform asked BleachBit to drop its winapp2 import ([BleachBit forum](https://www.bleachbit.org/forum/winapp2ini-vs-cleanerml)). A macOS KB with schema, provenance, a CI linter, and fields for tier, native command, process guard and rebuild cost has no direct competitor.

**Gap 4: safety that survives heuristics.** The dominant failure mode is heuristic matching on paths that look like caches but hold user state. Mole permanently deleted Claude Code memory across eight projects ([#823](https://github.com/tw93/Mole/issues/823)). It also deleted a user LaunchAgent ([#582](https://github.com/tw93/Mole/issues/582)) and saved printers ([#731](https://github.com/tw93/Mole/issues/731)), and destroyed CLI data through an XDG dotdir heuristic ([#993](https://github.com/tw93/Mole/issues/993)). dev-cleaner deletes committed lockfiles ([README](https://raw.githubusercontent.com/jemishavasoya/dev-cleaner/main/README.md)). Separately, coding agents running unguarded `rm -rf` have wiped home directories ([Docker blog](https://www.docker.com/blog/coding-agent-horror-stories-the-rm-rf-incident/)). AI-agent dotdirs such as `~/.claude`, `~/.codex` and `~/.cursor`, which mix caches with irreplaceable state, are a new high-risk zone.

**Gap 5: growth that says what it means.** Watchers report "folder X grew". None says "Docker build cache +12 GB this week, low rebuild cost, run `docker builder prune`". None compares before and after an OS update, even though users report System Data jumping after 26.2 and macOS 27 upgrades ([Apple Community](https://discussions.apple.com/thread/256239409); [iBoysoft forum](https://iboysoft.com/forums/t/lost-around-125-gb-of-free-space-after-upgrading-my-mac-mini-to-macos-27/913)).

Two parts of the concept are **no longer differentiators**. On-device "explain this folder" shipped in CleanMyMac (Nov 2025) and Diskfern, and Apple's Foundation Model makes it a commodity on macOS 26+ ([MacPaw](https://macpaw.com/news/introducing-smart-insights); [Diskfern](https://www.diskfern.com/)). Clone- and hard-link-aware sizing already exists in DaisyDisk ([DaisyDisk](https://daisydiskapp.com/guide/4/en/HardLinks)). Both are now table stakes, not headlines. Two other gaps are smaller than they first look: ML model stores (Hugging Face, Ollama, LM Studio) are uncovered by Mole's dev module, but LLM Cleaner and Diskfern target them ([getllmcleaner.com](https://getllmcleaner.com/)). Orphan detection matters more now that Pearcleaner is stalled heading into macOS 27.

## Recommendations: rebuild the concept around trust and attribution

### Priority 0: the foundation that makes everything else credible

**Make the safety engine the product, not a setting.** Default every action to a time-limited quarantine, with Trash as a fallback, and keep a one-click undo log. Never delete permanently by default; that is the single biggest contrast with Mole. Resolve and validate absolute paths against a hard denylist before any action:

- `$HOME`, `/` and `~/Documents`
- Photos, Mail, Messages and Notes stores
- `~/Library/Mobile Documents` and `~/Library/CloudStorage`, since deletions there propagate to other devices
- keychains, TCC and Group Containers ([Mole blog](https://mole.fit/blog/what-mac-cleaners-should-never-delete.md))

Allowlist specific subpaths inside AI-agent dotdirs rather than whole directories, and treat only `Containers/<id>/Data/Library/Caches` as cleanable inside a container. Seed per-rule `blocked_by_processes` guards from Mole's list: Xcode, Simulator, xcodebuild, Gradle daemon, pnpm, uv, bun, and open files.

**Measure, don't estimate.** Scan allocated size with `getattrlistbulk`-style bulk enumeration ([healeycodes](https://healeycodes.com/optimizing-my-disk-usage-program)), deduplicate hard links and clones as DaisyDisk does, and report freed space as the measured change in container free space. Show a separate "held by snapshot" line and offer explicit `tmutil` snapshot deletion. Treat Docker.raw and VM images as a special case: prune, then compact, then verify the host file actually shrank. The scanner must work with almost no free disk and no large on-disk index, because that is when users run it; Oakley notes DaisyDisk's own caches need free space ([Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)).

**Ship the System Data ledger as the headline feature.** One screen should reconcile Apple's number bucket by bucket: snapshots by owner, Spotlight, document versions, swap, VM and Docker disks, simulator runtimes, iOS backups, app scratch, Apple Intelligence models and overhead. Each bucket gets a verdict: clean natively, clean with quarantine, or "Apple-managed, here is why and what Apple lets you do". Where a remainder can't be explained, say how large it is and why, for example that other users' homes or TCC-blocked paths need Full Disk Access. This turns the most-complained-about number in macOS into the product's demo.

**Launch the rules KB with a permissive licence and schema from day one.** Borrow CleanerML's structure (`os` gating, detection keys, process guards), Winapp2's flavors and aggressive tier, clean-dev-dirs' marker-file→target mapping, and CACHEDIR.TAG auto-detection ([HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)). Add the fields neither has: tier, native command, rebuild cost (re-download GB, compile minutes, needs network or credentials), provenance and last-verified macOS version. Mole is GPL-3.0, so use its coverage as a checklist to reach parity, not as a source to copy. Run a CI linter on every PR.

### Priority 1: parity plus a clear edge on developer and AI workloads

**Reach coverage parity with Mole across developer ecosystems, then go past it on ML models**: Hugging Face via `hf cache prune`, Ollama, LM Studio, torch and pip caches. These are often the largest single items, and HF's shared Xet blobs make `rm -rf` unsafe ([HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)). Make native commands mandatory wherever the ecosystem has one: pnpm store, `xcrun simctl runtime delete --notUsedSinceDays`, `brew cleanup`, `uv cache prune`.

**Make project awareness multi-signal.** Use last git commit date, newest mtime and open-file checks together; git alone gets abandoned branches wrong. Require marker-file detection before treating `bin/`, `vendor/` or `build/` as artifacts, and protect lockfiles and git-tracked files. Show the rebuild command and estimated cost next to each stale project.

**Turn the growth watcher into a meaning watcher.** Use FSEvents for incremental rescans (behaviour to verify against Apple docs). Attribute deltas to KB tiers, forecast the date the disk will be full as Disk Forecast does, and snapshot state before and after OS updates. Use Dev Cache Cleaner's pattern for a quiet, honest menu-bar presence: one reclaimable badge, refreshed daily. Leave out CPU/RAM gauges, which BuhoCleaner and Sensei already offer and which add nothing to the storage story.

**Rebuild orphan detection with evidence.** Pearcleaner is stalled and Nektony over-matches. Show why a file matched (bundle ID, receipt, vendor prefix), give a confidence score, and quarantine by default. This answers the controls Pearcleaner had to bolt on afterwards ([newreleases](https://newreleases.io/project/github/alienator88/Pearcleaner/release/4.4.0)).

### Priority 2: reframe, demote or drop

**Reframe LLM explanations as the KB's fallback and contribution engine, not the headline.** Run them on-device with Apple's Foundation Model, matching CleanMyMac and Diskfern on privacy. Mark any verdict without a KB rule behind it as "unverified". Never let the model generate shell commands; it picks from KB actions only. Send unknown-path explanations into a human-reviewed rule-contribution queue, so each AI query improves the KB. Separately, export a structured scan report and ship a **read-only MCP server**. That meets developers where Disk Map and Mole already are, at no inference cost to us.

**Reframe offload as "archive with guaranteed restore".** Copy clone-aware, verify by checksum, leave a stub or index, and restore with one click. Pair it with Storage Sense-style policies: per-category age thresholds, off by default for personal data and on for zero-rebuild-cost caches, plus a "keep" pin ([cloudinfra.net](https://cloudinfra.net/configure-storage-sense-using-intune/)). Only items with low rebuild cost should ever qualify for automatic action. An unverified opportunity is replacing exact duplicates with APFS clones instead of deleting them; no duplicate finder documents doing this.

**Drop what competitors already do and users don't credit:** RAM "cleaning", malware scanning, Gmail and cloud cleanup, an offers or notification center, and blanket cache wiping of `~/Library/Caches`, which macOS largely purges itself at a performance cost. Don't promise to "remove" Apple Intelligence models; explain them.

**Distribution and price.** Ship a notarized direct download as the full product, with Full Disk Access and an optional, documented SMAppService helper limited to root-owned targets. Oakley publicly criticises cleaners that obtain privileges through scripted workarounds ([Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)). The Mac App Store sandbox grants no FDA entitlement ([Apple Developer Forums](https://developer.apple.com/forums/thread/807142)), so an App Store build can only be a "lite" analyser. Price one-time in the **$19–$49** band set by Mole ($19), Diskfern ($19.99), DaisyDisk and Sensei lifetime ($59), with free rules and no telemetry.

### Competitive threats to plan against

**CleanMyMac** is the threat with the most money behind it. Its "In Progress" list names "smarter cleanup for AI agents" and a "CleanMyMac CLI for Terminal" ([MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)), and MacPaw calls Smart Insights the first of an "upcoming series" of AI tools ([MacPaw](https://macpaw.com/news/introducing-smart-insights)). Expect developer and AI-tooling cleanup with LLM explanations inside about a year. Its weaknesses are subscription pricing, an offers surface, closed rules and no measured-delta reporting. Those are the places to fight.

**Mole** is the threat with the most momentum. It has 74k stars, ships near-daily releases, sells a $19 native app and installs as a Claude Code, Codex and Cursor skill ([GitHub](https://github.com/tw93/Mole)). It wins on breadth and developer trust in open source. It loses on permanent deletion, documented data loss, misreported savings and Bash-buried rules that are hard to audit. If Mole adds a quarantine and moves its rules into a declarative format, much of this wedge closes. That argues for launching the KB early and courting contributors.

**Smaller threats.** Diskfern ($19.99, on-device AI) and the free Raycast Dev Cache Cleaner and MegaCleaner keep pushing the price of "explain plus dev cleanup" towards zero. Apple keeps improving Storage settings, so any feature that only restates Apple's categories will be absorbed.

## Conclusion

The market has inverted the original premise. "AI explains your disk" was meant to be the novelty and is now table stakes. The combination competitors keep missing is honesty about money and time: what this gigabyte is, what it costs to rebuild, how much space you actually got back, and how to undo it. A product built on a public, schema-validated macOS rules KB, with a System Data ledger that reconciles to Apple's numbers, would be the first auditable reference for what is safe to remove from a Mac. That matters beyond the app, because coding agents are now doing disk cleanup with nothing to ground them, and a KB plus MCP server gives them something to ground against.

The main uncertainty is timing. The evidence for most gaps comes from vendor pages and issue trackers rather than hands-on testing. Two absences in particular are unverified: offload, and clone-aware dedupe. Independent figures for reclaimable space are scarce; most "50–150 GB" claims come from vendor blogs ([dev.to](https://dev.to/pyrx_tech/the-complete-xcode-cleanup-guide-for-iosmacos-developers-reclaim-50-150-gb-2026-2h5j)). The window is about the time it takes CleanMyMac to ship its developer and AI-agent roadmap, or Mole to adopt Trash-by-default and declarative rules. Both are plausible within 12 months.
