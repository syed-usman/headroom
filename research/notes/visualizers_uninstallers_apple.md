# macOS Disk Visualizers, Uninstallers, Maintenance Utilities and Apple Storage Settings (as of Nov 2026)

Research date: 2026-11-08. About 18 tool calls, so coverage is uneven. Vendor-affiliated comparison blogs (CleanMyMac/MacPaw, Nektony, Mole, Cindori, Softorino, iBoysoft) are marked as such. Items I couldn't verify in this session are under Gaps, not presented as fact.

## 1. Does each tool explain WHAT a folder is / whether it's safe to delete, or just show sizes?

### Takeaway
Almost none of these tools explain meaning. Visualizers (DaisyDisk, GrandPerspective, OmniDiskSweeper, Disk Inventory X, WhatSize, DiskSavvy) show sizes and treemaps or lists. Uninstallers tie files to one app bundle. Apple's Storage settings is the only tool that gives meaning by category, and only for Apple-owned categories (Developer/Xcode, TV, Messages and so on). Its biggest bucket, System Data, comes with no breakdown and no button. No tool found has a "what is this folder / is it rebuildable" knowledge base or an LLM explainer.

### Cited Findings
- Apple Storage settings (Tahoe 26.2) has three sections: the Storage Bar, Recommendations, and per-category lists. The Developer category "cleans up potentially redundant Xcode build and device support files". The Documents view (large files, old downloads, column browser) is called inferior to DaisyDisk and GrandPerspective. The Mail and Podcasts categories "add nothing". — [Eclectic Light, Explainer: Storage settings, Dec 2025](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- System Data "desperately needs further information, but doesn't have a button". Identifying what's in it may come down to "a process of elimination". — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- Apple's recommendations are generic: Store in iCloud (Desktop/Documents plus iCloud Photos), Optimize Storage (removes watched Apple TV content, which is not the same as iCloud Drive's "Optimize Mac Storage"), and Empty Trash Automatically (after 30 days). — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- Apple's own advice lists manual actions: delete re-downloadable media, clear Downloads, delete old iOS backups, remove unused users, compress files. Booting in safe mode clears "certain system caches, which are automatically created again as needed". — [Apple Support 102624](https://support.apple.com/en-us/102624)
- DaisyDisk explains only its synthetic "hidden space" item, breaking it into purgeable space, other volumes and "still hidden". It doesn't explain ordinary folders. — [DaisyDisk guide: hidden space](https://daisydiskapp.com/guide/hidden-space)
- Reviewers describe OmniDiskSweeper as fast, free and list-based with no visuals, GrandPerspective as a free, open-source treemap, and Disk Inventory X as open source, rarely updated and clunky on Apple Silicon. — [dissectmac (blog)](https://dissectmac-com.pages.dev/blog/daisydisk-alternatives); [CleanMyMac blog (vendor)](https://cleanmymac.com/blog/daisydisk-alternative); [mole.fit (vendor)](https://mole.fit/blog/daisydisk-alternative)
- WhatSize costs about US$12.99 with a trial. A 2026 comparison praises its CSV export, duplicate cleanup and granular filters but notes the trial limits key actions. — [machow2](https://machow2.com/disk-space-analyzer-mac/); [Nektony roundup Apr 2026 (vendor)](https://nektony.com/reviews/best-disk-space-analyzer-for-mac); [App Store listing](https://apps.apple.com/us/app/whatsize/id413702125?mt=12)
- DiskSavvy is listed as a free, fast analyzer that can also scan network shares and NAS. SquirrelDisk is listed as paid and proprietary. Disk Diag appears in a 2026 Nektony roundup among analyzers that also clean junk, with no details found. — [AlternativeTo](https://alternativeto.net/software/squirreldisk/?p=2); [Nektony roundup (vendor)](https://nektony.com/reviews/best-disk-space-analyzer-for-mac)
- Pearcleaner has a "Development Environment Manager", a Homebrew manager, file search, orphaned file search, adjustable search sensitivity and a CLI. This is the closest thing to stale-dev-artifact cleanup among the uninstallers. — [Pearcleaner GitHub](https://github.com/alienator88/Pearcleaner)
- OnyX (Titanium Software) is the main free maintenance utility. Titanium's page listed OnyX 4.9.8 for Tahoe 26 (Mar 27, 2026), and a later review cites OnyX 5.0.3 (Aug 31, 2026). OnyX 5 for Tahoe was reported in June 2026, and ifun.de mentions new OnyX/Deeper versions for the next macOS ("Golden Gate 27"). — [Titanium Software](https://titanium-software.fr/en/onyx); [iphonesoft.fr Jun 2026](https://iphonesoft.fr/2026/06/05/onyx-5-menage-macos-26-tahoe); [ifun.de](https://www.ifun.de/onyx-und-deeper-neue-versionen-fuer-macos-golden-gate-27-289374/). The version sources conflict.

### Inferences
- The "explain by meaning" layer (rebuildable cache, re-downloadable asset, stale dev artifact, orphan, personal data) is missing from every tool here. Apple covers a narrow version of it for its own content only (Xcode, TV, Music, Messages).
- An "explain System Data" feature directly answers the weakness Eclectic Light names: no button and no breakdown.
- OnyX-style tools run maintenance scripts and cache purges without per-item rebuild-cost reasoning. Rebuild-cost estimates would be new.

### Gaps
- I didn't verify the current feature sets of Disk Diag, DiskSavvy for Mac, SquirrelDisk or the Squirrel treemap tools. Their vendor pages weren't fetched.
- I didn't verify whether "Maintenance" (Titanium Software's simpler sibling of OnyX) is still updated for Tahoe. My search returned nothing on it.
- From training (unverified): DaisyDisk sells for about $9.99 direct or on the Mac App Store, and GrandPerspective is open source on SourceForge with a paid App Store build. Both need checking against current vendor pages.

## 2. How do tools handle System Data, hidden space, purgeable space, APFS snapshots, clones and sparse files (size accuracy)?

### Takeaway
DaisyDisk is the most explicit. It reports a "hidden space" remainder split into purgeable, other volumes and still hidden, counts a hard link or clone once (including partial clones), and can force-purge purgeable space. That purge isn't available in the Mac App Store edition. Apple's Storage settings now reports allocated rather than nominal size (sparse files are counted correctly). Its System Data is simply the remainder. I found no evidence that GrandPerspective, OmniDiskSweeper or Disk Inventory X deduplicate clones or hard links.

### Cited Findings
- DaisyDisk computes hidden space as used space minus what it could scan. Its contents are purgeable space (mostly Time Machine local snapshots, plus swap, sleep image and temporary system files), other APFS volumes sharing the container, and "still hidden": other users' homes, the Spotlight index, document versions, 2-3 GB of file system overhead, and space lost to file system errors. — [DaisyDisk guide](https://daisydiskapp.com/guide/hidden-space)
- In DaisyDisk, Time Machine snapshots count toward purgeable space. Third-party snapshots (such as Carbon Copy Cloner) count toward still hidden space and can't be purged by DaisyDisk. The guide points users to `tmutil listlocalsnapshots /`. Snapshot sizes are shown for reference and aren't added again. — [DaisyDisk guide](https://daisydiskapp.com/guide/hidden-space); [DaisyDisk snapshots guide](https://daisydiskapp.com/guide/snapshots)
- Users can force a purge by dragging the purgeable item to DaisyDisk's Collector. This "is not available in the Mac App Store edition", and the purge can take 2-10 minutes. — [DaisyDisk purgeable guide](https://daisydiskapp.com/guide/purgeable-space)
- DaisyDisk counts the first hard link or clone and gives the rest zero size, and it detects partial clones. — [DaisyDisk HardLinks guide](https://daisydiskapp.com/guide/4/en/HardLinks)
- Users report DaisyDisk purges that do little. One MacRumors user saw 188.1 GB of "snapshots" that wouldn't go away. One Apple Community user deleted 142 GB of purgeable space and got back about 5 GB. — [MacRumors thread](https://forums.macrumors.com/threads/storage-capacity-keeps-shrinking-on-my-m2-mini-even-after-deleting-at-least-100-gigabytes-off-my-drive-ideas.2481527/); [Apple Community 250490791](https://discussions.apple.com/thread/250490791)
- Apple Storage settings reports space actually used, not nominal size. A 100 GB sparse VM showed as about 62 GB. Apps in the Signed System Volume are left out, and System Data excludes the System volume and its snapshot. — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- Apple's System Data is the remainder after the other categories are totalled. It "can include temporary files like caches, snapshots, and anything else it can't account for elsewhere". Recovering that space means going to Disk Utility, which lists snapshots and purgeable space. — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- Analyzers that add up logical file sizes count both copies of an APFS clone in full and can report more than the volume holds. Clones, hard links, sparse files and snapshots each skew totals in a predictable direction. — [Mole blog (vendor)](https://mole.fit/blog/daisydisk-alternative)

### Inferences
- APFS-accurate sizing is a solved problem in DaisyDisk only, and it's a differentiator against free tools. A new tool needs clone and hard-link deduplication, allocated-size reporting, and separate purgeable and snapshot accounting. It also needs to identify which app owns third-party snapshots.
- Sandboxing limits are real. The App Store edition of DaisyDisk can't purge. A tool that wants native cleanup commands (tmutil, purge) will likely need direct distribution plus Full Disk Access or a privileged helper, as Pearcleaner does.

### Gaps
- I couldn't confirm how GrandPerspective, OmniDiskSweeper, Disk Inventory X or WhatSize treat clones, hard links or sparse files. No source states it, so direct testing is needed.
- I found no scan-speed benchmarks.

## 3. How do uninstallers detect orphaned leftovers of already-deleted apps? Accuracy and false positives?

### Takeaway
FreeMacSoft AppCleaner works only on an app you drag in, with no scan for already-deleted apps. Nektony App Cleaner & Uninstaller has "Remaining Files" for apps that are already gone. Pearcleaner has an orphaned file search with adjustable sensitivity, an exclusion list and a condition builder, which exist mostly because of false positives. Pearcleaner development has been on hold since late 2025. No vendor documents its matching method beyond name and bundle-ID heuristics, and I found no published accuracy figures.

### Cited Findings
- AppCleaner (FreeMacSoft) is a drag-and-drop tool with SmartDelete and no scan for remaining files. — [CleanMyMac blog (vendor)](https://cleanmymac.com/blog/pearcleaner-vs-appcleaner); [Cindori (vendor)](https://api.cindori.com/reviews/what-is-appcleaner-and-is-it-safe)
- Nektony's Remaining Files can scan for leftovers from apps that were already deleted. In one comparison it found 10 leftover files for Chrome against 5 for AppCleaner. — [CleanMyMac review of Nektony (competitor)](https://cleanmymac.com/blog/nektony-app-cleaner-review); [Nektony (vendor)](https://nektony.com/how-to/appcleaner-vs-app-cleaner-pro)
- Nektony pricing: $14.95/year or $34.95 one-time, with a short full-featured trial (sources say 2 or 3 days). After the trial, a free version with limited features remains. Third-party listings disagree ($19.90, $7.95/month). — [Nektony AppCleaner alternatives Oct 2026](https://nektony.com/appcleaner-alternatives); [Nektony buy page](https://nektony.com/mac-app-cleaner/buy2d); [Trend Micro roundup](https://cleanerone.trendmicro.com/blog/best-mac-app-cleaner-uninstaller/)
- Pearcleaner features: Orphaned File Search, an exclude list for orphan search, adjustable search sensitivity, CLI, deep links, a Homebrew manager and a dev-environment manager. It needs Full Disk Access and a Privileged Helper for system folders. — [Pearcleaner GitHub](https://github.com/alienator88/Pearcleaner)
- License is Apache 2.0 with Commons Clause (no monetization). Version 5.4.3, about 15.1k stars. Distributed through GitHub Releases and a Homebrew cask (`brew install --cask pearcleaner`). — [Pearcleaner GitHub](https://github.com/alienator88/Pearcleaner)
- Pearcleaner is "On Hold". The author says development "has basically stopped since end of 2025" because they have no personal Mac after a job change. Issues, PRs and releases are on hold indefinitely, but the project is "not abandoned". Issue tracker reports describe a malicious site impersonating the project and malware download links. — [Pearcleaner README via jsDelivr](https://cdn.jsdelivr.net/gh/alienator88/Pearcleaner@main/README.md); [Pearcleaner issues](https://github.com/alienator88/Pearcleaner/issues)
- Pearcleaner's own fixes point to false positives and scope problems. Release 3.8.1 made "sure file searches don't hit home folder, only home/apps folder", and 4.4.0 added orphaned file association for the current session. A fork's README tells users who see unrelated files to try the Condition Builder before filing a bug. — [newreleases 3.8.1](https://newreleases.io/project/github/alienator88/Pearcleaner/release/3.8.1); [newreleases 4.4.0](https://newreleases.io/project/github/alienator88/Pearcleaner/release/4.4.0); [fork README](https://github.imc.re/forksss/Pearcleaner)
- AppZapper is back as "AppZapper 3000" (Sept 2026). It costs $18 with 3 free zaps, adds a playful "blaster" UI and replaces the long-dormant legacy version. The article doesn't describe how it detects leftovers or whether it handles orphans. — [9to5Mac, Sept 15 2026](https://9to5mac.com/2026/09/15/appzapper-3000-the-uninstaller-apple-forgot-returns-for-the-modern-mac-era/)
- TrashMe 3: Softpedia lists v3.8 (Oct 2026, macOS 11+). Price is $17.99 one-time with a 15-day trial. — [Nektony uninstaller roundup (vendor)](https://nektony.com/reviews/best-uninstaller-for-mac); [RoaringApps](https://roaringapps.com/app/trashme-3)
- Uninstally, another open-source Mac app, is reported to scan leftovers of already-removed apps. — [Digital Trends](https://digitaltrends.com/computing/this-open-source-mac-app-finds-the-leftovers-your-deleted-apps-leave-behind)

### Inferences
- The best-known free, open-source orphan finder (Pearcleaner) is unmaintained heading into macOS 27. That leaves an opening for a maintained tool with clear provenance.
- Orphan detection everywhere is a string match on name or bundle ID, which makes false positives (shared vendor prefixes, generic names) the main pain point. A rules knowledge base plus the reason a file was matched, an evidence score and an undo log would answer the controls Pearcleaner had to add after the fact (sensitivity, exclusions, condition builder).

### Gaps
- I found no technical documentation of how Nektony or TrashMe match orphans (for example, LaunchServices history, receipts in /var/db/receipts, or bundle-ID prefix matching).
- I didn't review specific Pearcleaner GitHub issues about false positives, since the search didn't surface them. Searching the tracker directly for "orphan" would be the next step.
- AppZapper 3000's macOS requirement and distribution channel are unconfirmed.

## 4. What does Apple's built-in Storage Management do well and poorly in macOS 15/26? What is System Data made of?

### Takeaway
By Tahoe 26.2, Storage settings is more accurate (allocated sizes that match Disk Utility) and handles Apple content well. It's weak on System Data, which is an unexplained remainder that can be half the disk, and on other volumes. Its recommendations are mostly iCloud upsells or basic housekeeping. Many Tahoe 26.x users report System Data of 360 GB to 1.75 TB, with suspected causes (Spotlight index, snapshots) unconfirmed by Apple.

### Cited Findings
- Storage settings has become "more reliable and useful" since moving to System Settings > General > Storage and matches Disk Utility better. "All Volumes" gives no detail. Photos reports only the System Photo Library. The macOS category now shows space used by AI components. — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- In Eclectic Light's example, System Data was the largest category at about half the SSD. The author calls it "the greatest weakness". — [Eclectic Light](https://eclecticlight.co/2025/12/20/explainer-storage-settings/)
- Apple's definition: System Data is "a general category for space used by Apple and third-party files that don't belong to a more specific category". — [Apple Support 102624](https://support.apple.com/en-us/102624)
- Apple Community reports of huge System Data on Tahoe: 360 GB on an M3 Max, 700 GB after the 26.2 upgrade, 1.75 TB on a Mac Studio, and figures that swing up and down on Tahoe. — [thread 256174371](https://origin-discussions2-us-dr-prz.apple.com/thread/256174371); [thread 256239409](https://discussions.apple.com/thread/256239409); [thread 256228420](https://discussions.apple.com/thread/256228420); [thread 256147856](https://discussions.apple.com/thread/256147856); [thread 256240535](https://discussions.apple.com/thread/256240535)
- Community suspicion falls on a Tahoe Spotlight bug creating large amounts of data. One third-party guide suggests deleting ~/Library/Metadata/CoreSpotlight, which is risky and unverified. Apple has not acknowledged a bug. — [iBoysoft (vendor)](https://iboysoft.com/howto/macos-system-data-huge.html)
- Commonly cited parts of System Data: local Time Machine snapshots, logs, caches, leftovers from incomplete app removal, and VM or swap files. Macworld says it can exceed 100 GB. — [Macworld](https://www.macworld.com/article/676493/how-to-delete-system-data-mac.html); [CleanMyMac blog (vendor)](https://cleanmymac.com/blog/why-system-storage-takes-so-much-space)
- Other community threads on excessive System Data: TidBITS Talk and MPU forum. — [TidBITS Talk](https://talk.tidbits.com/t/excessive-system-data-on-a-macbook-pro-any-ideas/33460); [MPU Talk](https://talk.macpowerusers.com/t/system-data-takes-up-a-third-of-my-local-storage/43291)
- Six Colors (May 2026) covers keeping Mac storage from filling up, including APFS snapshots in general terms. — [Six Colors](https://sixcolors.com/post/2026/05/dont-let-your-macs-storage-fill-up/)

### Inferences
- Combining the Apple, Eclectic Light and DaisyDisk sources, System Data likely includes: local snapshots (Time Machine and third-party), the Spotlight/CoreSpotlight index, document versions (/.DocumentRevisions-V100), swap and sleep image, caches and logs, other users' homes when the scan isn't run as admin, unaccounted ~/Library contents (app containers, iOS backups if not categorized, simulator runtimes, VM disks), and file system overhead. A tool that fills each of these buckets with measured sizes would be the first full "System Data explainer".
- Regressions after an upgrade (26.2) make a growth watcher that compares before and after OS updates valuable.

### Gaps
- Apple publishes no itemized breakdown of System Data. Any component list is community-derived.
- I didn't find a specific Hacker News thread on System Data in this session.
- I didn't verify whether macOS 15 Sequoia differs materially from 26 in Storage settings. The Eclectic Light piece covers Tahoe only.

## 5. Pricing, open source status, sandbox / App Store limits, scan speed. Duplicate finders and automation.

### Takeaway
Free and open-source options are GrandPerspective, Disk Inventory X, Pearcleaner (on hold) and dupeGuru. AppCleaner and OnyX are free but closed. Paid options: Nektony ($14.95/yr or $34.95), AppZapper 3000 ($18), TrashMe ($17.99), WhatSize (~$12.99) and Gemini 2 (from $19.95/yr, also in Setapp). Sandboxed App Store editions lose privileged actions (DaisyDisk can't purge purgeable space).

### Cited Findings
- dupeGuru: free and open source. Latest release seen is 4.3.1. Repository commits ran into January 2026, and a Fedora packaging request was filed in July 2026. — [Launchpad mirror](https://code.launchpad.net/~dupeguru/dupeguru/+git/master/+index); [Debian tracker](https://tracker.debian.org/dupeguru); [Fedora review](https://bugzilla.redhat.com/show_bug.cgi?id=2497737)
- Gemini 2 (MacPaw): a yearly plan from $19.95 on the US store, version 2.10.0 (Mar 2026) or 2.10.1 (Jun 2026) depending on the page, also in Setapp. It finds exact and similar duplicates and sends deletions to the Trash by default. Older sources cite $44.95 one-time. — [MacPaw store](https://macpaw.com/store/gemini); [Macworld review](https://www.macworld.com/article/228073/gemini-2-review-first-line-of-defense-against-duplicate-files-on-your-mac.html); [softwarehow](https://softwarehow.com/?p=1276)
- DaisyDisk: purge of purgeable space is unavailable in the App Store edition. — [DaisyDisk guide](https://daisydiskapp.com/guide/purgeable-space)
- Pearcleaner needs Full Disk Access plus a Privileged Helper and isn't on the App Store. — [GitHub](https://github.com/alienator88/Pearcleaner)

### Inferences
- The duplicate finders (Gemini, dupeGuru, PhotoSweeper) dedupe by content. None is APFS-clone aware in any documented way. A space reclaimer could suggest replacing a duplicate with a clone (zero-cost dedupe) rather than deleting it. That's a gap, but unverified as absent.
- Hazel shows that rule-based automation (age or size rules on folders, trash cleanup on app deletion) is accepted by power users. A "growth watcher + rules" product overlaps with it.

### Gaps
- Hazel's current version and price are unverified. From training, Hazel 6 is about $42 with app-sweep uninstall-on-trash, but I couldn't confirm it in this session.
- PhotoSweeper's price and status are unverified.
- I found no scan-speed benchmarks for any tool.
- I didn't gather Reddit r/mac or r/MacOS complaints and feature requests directly. The only community evidence here comes from Apple Community, MacRumors and TidBITS, so a dedicated Reddit pass is recommended.
