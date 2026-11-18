# AI-assisted and newer-generation disk cleanup tools (macOS focus, Nov 2026)

## Which tools use LLMs, how (local vs cloud), and what is their privacy approach?

### Takeaway
LLM use in disk cleanup has split into three patterns. (1) **On-device "explain this item"** inside polished apps: CleanMyMac Smart Insights and Diskfern Disk Advisor, both on Apple's Foundation Model and both needing macOS 26 with Apple Intelligence. (2) **Hand-off to a coding agent the user already has**: Disk Map "Ask AI", Mole skills/plugins, and many MCP servers. (3) **Cloud-API classifiers** that send only metadata. The safe designs converge on a few rules: the LLM explains and stages, a human confirms, and deletion goes to Trash. "Explain unknown paths" is already shipping in commercial apps. Nobody I found combines it with a community rules KB, rebuild-cost estimates or an undo log.

### Cited Findings
**Commercial apps**
- **CleanMyMac Smart Insights** (announced Nov 4, 2025): you click a button on an unfamiliar item and Apple Intelligence explains its purpose, whether it is safe to remove, and what happens if you keep or delete it. It appears in the Cleanup, Protection, Performance and Applications modules. It runs on the Apple Foundation Model entirely on the Mac ("no data ever leaves the device"), with thumbs-up/down feedback. It needs Apple Silicon, macOS Tahoe 26 and Apple Intelligence enabled. MacPaw calls it the first of an "upcoming series" of AI tools — [MacPaw](https://macpaw.com/news/introducing-smart-insights)
- The CleanMyMac redesign (Oct 2024) added an "Assistant": health and security reports, maintenance reminders, and answers to how-to questions. This is mostly app guidance, not file-level LLM classification — [MacRumors](https://www.macrumors.com/2024/10/16/macpaw-releases-redesigned-cleanmymac/); [MacPaw Assistant page](https://macpaw.com/cleanmymac/cleanup-assistant). MacPaw's 2025 goals included a Space Lens revamp — [MacRumors](https://www.macrumors.com/2024/10/16/macpaw-releases-redesigned-cleanmymac/)
- **MacPaw Eney**: a separate AI agent app teased at CES 2025. It is reported to run small on-device models built with Liquid AI and to use the cloud only for heavy tasks — [Korben](https://korben.info/en/eney-ai-assistant-cleanmymac-makers-runs-on-mac.html)
- **Diskfern Disk Advisor AI**: answers questions about a scan ("what is safe to delete") with reasons, using "Apple's on-device model". File names, paths and sizes are analysed on the Mac. It can stage items but does not remove anything itself; removal needs confirmation and goes to Trash by default. It needs macOS 26 with Apple Intelligence and comes with Pro Lifetime ($19.99) or Family Lifetime ($49.99) — [Diskfern](https://www.diskfern.com/)
- **Disk Map** (free, macOS 15+, v1.4): its "Ask AI" sends a report of folder names, sizes and dates plus a prompt to an agent you already use (Claude Code, Codex, Cursor, Grok) or to a chat app (Claude, ChatGPT). Terminal agents can browse folders themselves and "ask before changing anything". Disk Map itself has no account, analytics or uploads. Its own suggestions wait for "Apply Selected" and go to Trash — [Disk Map](https://diskmap.app/)
- **LLM Cleaner**: a commercial macOS app aimed at local AI model files (Ollama, LM Studio and similar). It claims "No model files, file names, paths or scan results ever leave your disk" — [getllmcleaner.com](https://getllmcleaner.com/). Diskfern's material also lists ~/.ollama/models and ~/.lmstudio/models as hidden space hogs — [search result summary via diskfern.com](https://www.diskfern.com/)
- App Store "AI" cleaners exist (Smart Cleaner AI, CleanMyDisk Ai, Duplicate Storage Cleaner AI). Smart Cleaner AI claims scanning, "AI categorization" and cleanup happen locally — [Smart Cleaner AI](https://dijitalworlds.com/maccleaner-ai/); [CleanMyDisk Ai](https://apps.apple.com/hn/app/cleanmydisk-ai/id6739762920?mt=12). I did not verify what "AI" means in these apps.

**Open source and agent tooling**
- **Mole (tw93/Mole)**: open-source macOS CLI `mo` with about 74.3k GitHub stars, GPL-3.0, macOS 12+. Commands: `clean`, `uninstall`, `optimize`, `analyze`, `status`, `purge` (node_modules/target), `installer`, `slim`, `history`. Safety features: `--dry-run`, `--whitelist`, protected system paths, confirmations, and an operations log at `~/Library/Logs/mole/operations.log` viewable with `mo history`. `uninstall`, `analyze` and `slim` move items to Trash, but `clean`, `purge` and `installer` **delete permanently**. Mole installs as a skill/plugin for Claude Code, Codex and Cursor, plus an `llms.txt`. Agents are told to show `--dry-run` output first and leave uninstalls and admin steps to the user. A paid native Mole app is sold separately — [GitHub](https://github.com/tw93/Mole)
- **mac-disk-clean (dvaladares)**: an "LLM-guided Mac disk cleaner" runbook for AI coding assistants built on Mole, claiming 50+ GB reclaimed — [GitHub](https://github.com/dvaladares/mac-disk-clean)
- **ai-disk-cleanup (CoderDayton)**: a Python tool using OpenAI-compatible APIs to categorize files. Per its listing, "only file metadata transmitted, never file contents", with an offline rule-based fallback. The repo returned 404 when fetched in Nov 2026, so it may be deleted or renamed — [GitHub (listing)](https://github.com/CoderDayton/ai-disk-cleanup)
- Claude Code skills: `macos-cleaner` (fernandezbaptiste) — [Tessl](https://tessl.io/registry/skills/github/fernandezbaptiste/claude-code-skills/macos-cleaner); `macos-disk-cleanup` — [sabemos.ai](https://sabemos.ai/academy/skills/macos-disk-cleanup)

**MCP servers (a crowded niche, mostly small hobby projects)**
- **diskclean-mcp** (PyPI): lets Claude Desktop, Claude Code or any MCP client scan and clean reclaimable space on a Mac. The destructive step is gated by "four independent guardrails" and needs a recent scan — [PyPI](https://pypi.org/project/diskclean-mcp/). The page would not render, so I could not see the guardrail details.
- **unix-disk-mcp** (juliusdehner): macOS and Linux. The AI can only suggest and stage deletions; the user deletes manually. Config lives in `~/.config/unix-disk-mcp/config.json` — [LobeHub](https://lobehub.com/zh/mcp/juliusdehner-unix-disk-mcp)
- **mac-disk-cleaner** (minLaoGe): scans large files, AI model weights, caches and duplicates. It moves items to Trash or permanently deletes them after confirmation — [Glama](https://glama.ai/mcp/servers/minLaoGe/mac-disk-cleaner)
- **DiskCleanKit MCP**: drives the commercial DiskCleanKit app — [Glama](https://glama.ai/mcp/servers/namtran/diskcleankit-mcp)
- **Disk Insights MCP** and **disk-space-mcp** are read-only. The Disk Insights author notes that tools able to delete files "are exactly the tools you don't want an LLM driving unsupervised" — [Glama](https://glama.ai/mcp/servers/g3rsb8mx6k); [Glama](https://glama.ai/mcp/servers/fjmn2001/disk-space-mcp)
- **disk-clean-mcp** (npm, Superandyfre): read-only analysis suggesting targets by size, type, recency and duplicates — [claudemarket](https://claudemarket.ai/mcp/Superandyfre/disk-clean-mcp)
- PolicyLayer rates Claude Code Toolkit's `clean_claude_directory` tool "Critical Risk" (destructive) and recommends gating it — [PolicyLayer](https://policylayer.com/tools/asifkibria-claude-code-toolkit/clean-claude-directory)

**Raycast extensions**
- **Dev Cache Cleaner** (Undolog): first released May 12, 2026, updated Aug 27, 2026 for Raycast 2. It covers 6 categories: package-manager caches, 22 build-artifact types, Xcode/iOS, Docker, language caches, and system caches/logs. Items are labelled **Safe (green)** if re-created on the next install, or **Review (orange)**: Xcode Archives, Docker volumes, simulator runtimes, app caches. Build artifacts are flagged only above a minimum age (default 30 days). A menu-bar badge shows reclaimable total, refreshed daily. It has a "copy clean command" action. Rebuild cost is described only qualitatively — [Raycast](https://www.raycast.com/Undolog/dev-cache-cleaner)
- Others: **Disk Usage** (du-based, needs Full Disk Access) — [Raycast](https://raycast.com/easymikey/disk-usage); **Mole** front end (unofficial) — [Raycast](https://www.raycast.com/jlrochin/mole); **kill node modules** — [Raycast](https://raycast.com/NicolasMontone/kill-node-modules); **Mint** (shows data only from the Mint app, no deletion, no FDA for Raycast) — [Raycast](https://www.raycast.com/dzg-studio/mint-mac-care)

### Inferences
- With Apple's Foundation Model, privacy-preserving "explain this path" is basically a commodity on macOS 26 (CleanMyMac, Diskfern). Our differentiator has to be grounding: KB rules, native commands, rebuild cost. An LLM alone is not enough.
- The common agent pattern is now "app produces a metadata report, the user's own agent reasons over it" (Disk Map, Mole skills, MCP). We could export a structured scan report or ship an MCP server so we don't have to run inference ourselves.
- Dev Cache Cleaner's Safe/Review split plus minimum age is a cheap, well-understood UX for a risk tier.
- The best designs share three rules: the LLM never deletes, deletions are staged, and the default is Trash. Mole permanently deletes in `clean`/`purge`, which is a gap our undo log can fill.

### Gaps
- I couldn't fetch the diskclean-mcp guardrail details or the unix-disk-mcp tool list (the pages would not render or redirected).
- I couldn't confirm what models the App Store "AI" cleaners use, or whether their claims hold.
- I found no Show HN thread specifically for an LLM disk analyzer; searches returned only product pages.
- I could not determine Diskfern's launch date.

## Which tools have community-maintained cleaning definitions, and what are their format, size and governance? What lessons apply to us?

### Takeaway
Two mature community rule sets exist, both in the Windows/BleachBit world. **Winapp2.ini** has 15+ years of history, is CC-BY-SA-4.0, and ships "flavors" for each consuming tool. **BleachBit CleanerML** is XML with an XSD, cross-platform `os` attributes, and running-process checks. Neither has a formal governance document. Both have license and liability issues: CCleaner pushback, and irreversible-deletion disclaimers. Nothing comparable exists for macOS that I found. Mole's built-in rules are the closest de facto equivalent.

### Cited Findings
- **CleanerML format**: XML elements `cleaner` (optional `os`) → `option` → `action`. `command` can be `delete`, `truncate`, `ini`, `json`, `sqlite.vacuum`, `winreg`, `process`, or app-specific ones such as `chrome.history`. Search types are `file`, `glob`, `walk.files`, `walk.all`, `walk.top` and `deep` (deep scans of the same directory are merged). Filters are `regex`/`nregex` (relative path), `wholeregex`/`nwholeregex` (full path) and `type` f/d. `running` aborts cleaning if an exe or pathname is running. `var` supports ~, env vars and multi-value expansion. `os` values are bsd, darwin, linux, netbsd, openbsd, unix and windows. CleanerML can be exported to gettext for translation. There is an XSD for validation. There are no dedicated safety/warning tags — [BleachBit docs](https://docs.bleachbit.org/cml/cleanerml.html)
- BleachBit imports winapp2.ini, "giving Windows users 2400+ additional cleaners", but only one winapp2.ini file can be used. The docs recommend CleanerML for new contributions because it is "cross-platform, not legally encumbered" and richer — [BleachBit docs](https://docs.bleachbit.org/doc/winapp2ini.html); [contributing](https://docs.bleachbit.org/cml/contributing.html)
- **Winapp2.ini**: a "massive, community-driven database of declarative cleaning routines" mapping apps to temp files, caches, logs and MRUs. It is compatible with CCleaner, BleachBit, System Ninja, Avira, R-Wipe & Clean, HDCleaner, FluentCleaner and Tron. It has thousands of contributions over 15+ years and about 3,220 commits. Keys include `Detect`/`DetectFile`, `Warning`, `Section` and `LangSecRef`. Flavors: base, CCleaner (less overlap), CCleaner 7, a BleachBit flavor that passes BleachBit's sanity checker, System Ninja, Tron/FluentCleaner, and an aggressive **Winapp3.ini**. Licence is CC-BY-SA-4.0. Contributions go through CONTRIBUTING.md, with Discussions and PRs. The **winapp2ool** tool downloads and trims rules for each app, shows changelogs, and has "Transmute" for custom entries. The disclaimer warns that rules can delete files and registry keys irreversibly and recommends backups and reading changelogs before updating — [GitHub](https://github.com/MoscaDotTo/Winapp2)
- Piriform (CCleaner) asked BleachBit to remove its winapp2.ini import feature, and does not endorse importing "CCleaner data" — [BleachBit forum/news results](https://www.bleachbit.org/forum/winapp2ini-vs-cleanerml)
- In practice governance is loose. Forum posts (roughly 2014–2017) say contributors submit CleanerML to a BleachBit-associated repository or send entries to the winapp2 maintainers, and one BleachBit moderator also maintains Winapp2 — [BleachBit forum](https://www.bleachbit.org/node/1421); [BleachBit](https://www.bleachbit.org/forum/winapp2ini-vs-cleanerml)

### Inferences (lessons for our KB)
- Use a declarative, schema-validated format (like the XSD) with `os` gating, a detection key (only show a rule if the app is installed), running-process guards, and a `Warning` field. Then add what both formats lack: a structured **risk tier**, **rebuild cost** (time, network, re-download size), a **native cleanup command** (e.g. `brew cleanup`, `xcrun simctl delete unavailable`, `docker system prune`), and provenance/last-verified metadata.
- Tiers matter: Winapp3 is a separate "aggressive" set. A tiered KB (safe / review / aggressive) works well.
- Pick a clear, permissive licence from day one and avoid copying proprietary rule data. The CCleaner–BleachBit conflict shows the risk.
- Ship a sanity checker/linter in CI and per-consumer "flavors" or exports, like winapp2ool.
- A KB with LLM fallback: a KB hit should take priority over the LLM; LLM answers on unknown paths could feed a contribution queue for human review.

### Gaps
- I couldn't get a current count of CleanerML rules or a written review policy for either repo.
- I found no macOS-specific community cleaning-definition project.

## What is worth borrowing from Storage Sense-style automatic policies?

### Takeaway
Windows Storage Sense is policy-based and conservative: opt-in age thresholds for each location (Downloads off by default), a "Cleanup recommendations" review list, cloud dehydration of unopened synced files, and admin policy control. Several of its ideas map directly onto Mac offload and growth features.

### Cited Findings
- Storage Sense covers the Recycle Bin, Downloads, temporary system files and OneDrive content — [TweakTown](https://www.tweaktown.com/guides/11411/i-set-up-storage-sense-once-and-havent-worried-about-disk-space-since/index.html)
- Downloads are **never** cleaned by default. The Settings dropdown offers Never, 1, 14, 30 or 60 days; Intune accepts 0–365 days (0 = never). Group Policy "Configure Storage Sense Downloads cleanup threshold" applies on Pro, Enterprise and Education — [cloudinfra.net](https://cloudinfra.net/configure-storage-sense-using-intune/); [Windows Central](https://www.windowscentral.com/software-apps/windows-11/how-to-free-up-space-automatically-with-storage-sense-on-windows-11)
- OneDrive integration: synced files unopened for a set period (default 30 days) become online-only. Files pinned "Always keep on this device" are exempt. Cloud-only content is never deleted — [Windows Central](https://www.windowscentral.com/software-apps/windows-11/how-to-free-up-space-automatically-with-storage-sense-on-windows-11)
- "Cleanup recommendations" (Settings > System > Storage) lists temp files, large/unused files, synced files and unused apps for one-click review — [Windows Central](https://www.windowscentral.com/software-apps/windows-11/how-to-free-up-space-automatically-with-storage-sense-on-windows-11)
- Note: most of these sources are third-party how-to sites, not Microsoft docs.

### Inferences
- Borrow these: per-category age thresholds with safe defaults (off for user content, on for caches); a "pin/keep" exemption flag; "dehydrate instead of delete" for iCloud/Dropbox-synced files (offload); a run trigger "when free space < X" or on a schedule; and a review-list mode as an alternative to auto-run.
- Rebuild cost could set auto-policy eligibility: only items with zero or low rebuild cost (package caches) qualify for automatic cleanup.

### Gaps
- I didn't verify the "run when disk space is low" trigger against Microsoft's primary docs in this pass.

## What gaps and complaints exist in AI-based cleanup (hallucinated safety, deleting wrong things)?

### Takeaway
The documented failures are mostly **agents running unguarded `rm -rf`** rather than LLMs mislabelling a cache. Tilde and variable expansion bugs have wiped home directories. The successful chat-based cleanup stories rely on the human running every command and on reversible staging. This supports a design where the LLM explains, deterministic code executes, and every action is undoable.

### Cited Findings
- Dec 2025: a Reddit user reported Claude Code running `rm -rf tests/ patches/ plan/ ~/`, wiping their Mac home directory with no dry-run or confirmation — [Gigazine](https://gigazine.net/gsc_news/en/20251216-claude-code-cli-mac-deleted); [Docker blog](https://www.docker.com/blog/coding-agent-horror-stories-the-rm-rf-incident/)
- GitHub issue #10077 (Oct 2025): the agent had created a directory literally named `~`, and a later unquoted `rm -rf ~` expanded to the real home directory. The reporter lost "weeks/months of work" — [claudeissues](https://claudeissues.com/issue/10077-bug-critical-claude-code-executed-rm-rf-deleting-entire-home-directory)
- Other reports: a Linux env var not persisting between Bash calls led to `rm -rf "$HOME"` — [claudeissues #75859](https://claudeissues.com/issue/75859-claude-code-ran-rm-rf-against-home-due-to-env-var-not-persisting-between-bash-to); an Aug 2026 report of a WSL2 home directory deleted in auto mode with no prompt — [claudeissues #88462](https://claudeissues.com/issue/88462-data-loss-claude-code-ran-rm-rf-on-home-in-auto-mode-destructive-code-hidden-ins); Windows 8.3 short-name alias deletions — [vibegraveyard](https://vibegraveyard.ai/story/claude-code-windows-path-alias-recursive-deletions/)
- Community mitigations are hooks that block `rm -rf ~` patterns, but pattern blocking can't catch variables or subshells — [DEV](https://dev.to/yurukusa/claude-code-deleted-my-entire-home-directory-heres-what-i-built-to-prevent-it-14e)
- **What works (ChatGPT case study, MacRumors, Oct 2, 2026)**: a user prepping an Intel to M5 migration used ChatGPT Plus. ChatGPT gave mostly read-only Terminal commands, the user pasted the output back, and the user ran all deletions, going from about 64 GB to 214 GB free. Removed items included old launch agents/daemons, privileged helpers, kexts, Dashboard widgets, X11 and old app folders. For kexts the user moved them aside, rebooted and tested. Asking "what is this?" for each item and having past chat context helped. The user valued the friction ("read every shell command before running it"). No hallucinations were reported. Replies criticised migrating old junk rather than the AI's accuracy — [MacRumors](https://forums.macrumors.com/threads/using-chatgpt-as-a-smart-mac-app-cleaner.2490949/)
- Tool authors themselves flag the risk: the Disk Insights MCP author says deletion tools are what you "don't want an LLM driving unsupervised" — [Glama](https://glama.ai/mcp/servers/g3rsb8mx6k); the mac-disk-clean README warns that it runs shell commands — [GitHub](https://github.com/dvaladares/mac-disk-clean); the Winapp2 disclaimer says its deletions can be irreversible — [GitHub](https://github.com/MoscaDotTo/Winapp2)

### Inferences
- Product rules that follow from this: (1) the LLM never generates shell commands to execute; it picks from KB/native commands only. (2) Resolve and validate absolute paths with a denylist ($HOME, /, ~/Documents and so on) before executing anything. (3) Default to Trash or staging plus an undo log. (4) Label LLM-only safety verdicts as "unverified" when no KB rule backs them.
- "Hallucinated safety" isn't well documented yet. It is a plausible risk without many public incidents, so present it as a design concern rather than a proven pattern.

### Gaps
- I found no Reddit thread documenting ChatGPT or Claude wrongly calling a specific Mac folder "safe" (searches returned app listings). No public evaluation of LLM accuracy at classifying macOS paths exists that I could find.

## Are there growth-monitoring or alerting tools that detect which folder grew?

### Takeaway
Yes. A 2025–2026 wave of small indie Mac menu-bar apps does "what grew since the last scan": Disk Monitor, Diskwatch and Disk Forecast. Dev Cache Cleaner shows a reclaimable-space badge. Classic monitors (Mister Plimsoll, Storage Menu Bar) only alert on free-space thresholds.

### Cited Findings
- **Disk Monitor** (open source, dohernandez): a native menu-bar app showing free space, the top 5 measured folders and growth between scans. Badges distinguish low space, large growth and incomplete measurement. It warns that folder sizes may overlap or share APFS storage, so they shouldn't be summed — [GitHub](https://github.com/dohernandez/disk-monitor)
- **Diskwatch** (commercial, macOS 14+, v1.3.0 Oct 2026): a "What grew" view of folders and files that gained space since an earlier scan. The default warning level is 20 GB (orange icon, red below half). It asks for Full Disk Access — [flowdrift.io](https://flowdrift.io/diskwatch/)
- **Disk Forecast** (free, open source): forecasts the date the disk will be full and reports growth by folder. It notifies with "what grew most this week" when the disk is forecast to be full within a week or space is low — [diskforecast.com](https://diskforecast.com/)
- **Storage Menu Bar** (App Store, macOS 14+): per-volume used/free space, folder map and warnings, with no apparent growth tracking — [App Store](https://apps.apple.com/qa/app/storage-menu-bar/id6821715348?mt=12). **Mister Plimsoll**: per-volume threshold alerts — [misterplimsoll.app](https://misterplimsoll.app/)
- Dev Cache Cleaner: a menu-bar badge with reclaimable total, refreshed daily — [Raycast](https://www.raycast.com/Undolog/dev-cache-cleaner)

### Inferences
- The idea is validated, but competitors stop at "folder X grew". A differentiator would be growth attributed to a *meaning* ("Docker build cache +12 GB this week; rebuild cost low; one-click `docker builder prune`"), plus forecast-to-full like Disk Forecast.
- Disk Monitor's APFS clone/shared-storage caveat is a correctness issue our scanner must handle: purgeable space, clones and snapshots.

### Gaps
- I didn't check iStat Menus or Stats (exelban) disk alert capabilities in this pass; neither came up in searches as offering folder-level growth.

## Cross-platform analogs with borrowable ideas (supplementary)
- **Czkawka / Krokiet** (Rust, about 35k stars): duplicates (by name, size or hash), empty folders/files, big files, temp files, similar images/videos, same music, broken symlinks and files, bad extensions, and bad names. It caches results so later scans run faster. Krokiet (Slint) replaces the GTK GUI, whose last release was 12.0. Licences: MIT for the core and CLI, GPL-3.0 for Krokiet — [GitHub](https://github.com/qarmin/czkawka)
- **Borrowable**: a scan cache for incremental rescans; a "similar media" class beyond exact duplicates; a "bad extension" detector.
- **Gaps**: I couldn't source 2024–2026 specifics for WizTree (MFT-reading speed), TreeSize (snapshot comparison), ncdu, dust, dua or gdu in this pass; my search returned irrelevant results. These are well-known tools, but any claims about them need separate verification before going into the report.
