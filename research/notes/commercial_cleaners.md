# Commercial all-in-one macOS cleaner apps (state as of November 2026)

Method note: about 20 searches and fetches, run 2026-11-08. Many "reviews" in this space come from competing vendors: Nektony (MacCleaner Pro), MacPaw (CleanMyMac), Dr.Buho (BuhoCleaner), Cindori (Sensei), MacKeeper, 1dot.ai (Files Magic AI) and Crumb. Each such source is flagged below. Reddit threads and Trustpilot pages did not show up in search results, so the user-complaint evidence here is thinner than I wanted (see Gaps).

## Q1: Per-app profiles: junk categories, pricing, distribution, version

### Takeaway
CleanMyMac 5.7.x (MacPaw) is still the reference product. It has a subscription-first price and has added features outward: cloud, Gmail, a Chrome extension and an Apple-Intelligence "Smart Insights" feature. It has not gone deeper into storage semantics. Its rivals (MacCleaner Pro, BuhoCleaner, Sensei, CCleaner, MacKeeper, Intego, Parallels Toolbox) cover the same generic categories: caches, logs, language files, mail attachments, large/old files, duplicates and app leftovers. No vendor page I fetched lists Docker, node_modules, Time Machine local snapshots or iOS backups as named categories.

### Cited Findings

**CleanMyMac (MacPaw)**
- Latest version is 5.7.4, dated 06 Nov 2026. It requires macOS 11+ and 320 MB of space. The 7-day free trial is "starting at $3.33/month", with a 30-day money-back guarantee — [cleanmymac.com](https://cleanmymac.com/)
- The homepage pitches junk cleanup as "unneeded system files, hidden clutter, broken downloads and 20 more types of junk". It does not itemize Xcode, dev junk or mail attachments. Other features: duplicates and similar images, the Space Lens drive map, a 5-action Smart Care scan, an uninstaller with leftovers and updates, startup/background app control, malware scanning (Quick/Normal/Deep), and Cloud Cleanup. It claims it deletes only files "100% safe for removal" — [cleanmymac.com](https://cleanmymac.com/)
- 5.x release history from MacPaw's release notes:
  - 5.0.0: 16 Oct 2024.
  - 5.0.5 (Feb 2025): added "Free Up Purgeable Space", described as dealing with "data that is safe to remove when more storage is needed".
  - 5.1.0 (Jun 2025): reworked Space Lens as bubbles.
  - 5.2.1 (Jul 2025): Cloud Cleanup for iCloud Drive, Google Drive and OneDrive. 5.3.0 (Dec 2025) added Dropbox.
  - 5.2.6 (20 Oct 2025): "Smart Insights", "Powered by Apple Intelligence, Smart Insights give you helpful info about system files". This is the only AI feature in the history.
  - 5.4.0 (Feb 2026): My Activity dashboard.
  - 5.5.0 (Apr 2026): My Tools.
  - 5.6.0 (Aug 2026): in-app Notification Center for "product news, offers, and other useful messages".
  - 5.7.0 (25 Sep 2026): Gmail Email Cleanup.
  - 5.7.1: Screen Cleaning Mode.
  - 5.7.2: Browser Care Chrome extension.
  - The notes never mention Xcode/developer cleanup or Time Machine snapshots. The "In Progress" section lists "smarter cleanup for AI agents", a "CleanMyMac CLI for Terminal" and Safari/Chrome extensions, marked "may be subject to change".
  - Source: [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- Mac App Store version: 5.7.3 (Oct 31). In-app purchases are $9.99/mo, $39.99/yr (Basic), $65.99/yr (Plus) and a $89.99 one-time purchase. There is a 7-day trial. The listing mentions "Cache, log, and attachment cleanup", Moonlock-powered malware scanning, cloud cleanup, duplicates/similar images, a large/unused file finder and Smart Insights. The US store shows no rating overview ("hasn't received enough ratings") — [App Store listing](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12)
- Macworld (updated 20 Jul 2026) lists $39.99 with one-time or yearly options. It says the App Store version "lacks some features because of Apple restrictions" and the trial caps cleaning at 500 MB. Cons: "Expensive; overlaps with built-in macOS tools; occasionally flags files users need" — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- The web subscription is $39.95/yr for 1 Mac, $63.95/yr for 2 and $127.95/yr for 5. Sources disagree on the one-time price: Cybernews says $119.95, the Mac App Store says $89.99, and 1dot.ai says MacPaw no longer publishes one — [Cybernews](https://cybernews.com/resources/macpaw-cleanmymac-review/); [1dot.ai (competitor)](https://1dot.ai/blog/filesmagicai-vs-cleanmymac-comparison)
- Nektony (a competitor) says the one-time license covers only one major version, and the free version only scans; removal needs a license — [Nektony review](https://nektony.com/reviews/cleanmymac-review)
- Crumb (a competitor) says CleanMyMac covers Xcode DerivedData and simulator runtimes but "misses some language-specific caches, such as Cargo and pip virtual environments" — [cleanwithcrumb.com](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/)

**MacCleaner Pro (Nektony)**
- Version 4.0.5, updated 28 Oct 2026, supports macOS 11 through 27. Nektony calls it "a bundle of six professional tools": App Cleaner & Uninstaller, Duplicate File Finder and Disk Space Analyzer are named, and the product menu also shows Memory Cleaner, Funter, VSD Viewer and FireWally. Price starts at $14.95/mo, with subscription or one-time options and a 2-day trial. It is distributed as a direct .dmg.
- Categories: mail attachments, screenshots, unused localizations, zip files, duplicates, caches/logs, Mail and Spotlight reindex, RAM, startup items, browser extensions, large files, and "system data". Xcode, simulators, Docker, node_modules, iOS backups, TM snapshots and purgeable space are not mentioned.
- The page says it "always displays a confirmation window before cleaning up any files".
- Source: [nektony.com/mac-cleaner](https://nektony.com/mac-cleaner)
- Macworld's test: Fast Cleanup freed 11.4 GB and Deep Cleanup reclaimed 65.4 GB. Cons: "Split across multiple apps; clunky interface". Macworld cites €13.85/mo. In the same article, Nektony's App Cleaner & Uninstaller "Remaining Files can remove critical elements such as the App Store", and Adobe apps had to be reinstalled after testing — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- Cindori lists $39.95/yr for a 1-Mac bundle plan. Its criticism is that it is "a bundle of separate utilities rather than one integrated dashboard" — [Cindori (Sensei vendor)](https://cindori.com/reviews/best-mac-cleaner-apps-2026)

**BuhoCleaner (Dr.Buho)**
- Features: Flash Clean, Disk Space Analyzer, App Uninstall with leftovers, RAM freeing, login items/startup management, and a menu bar monitor (RAM, disk, CPU load/temp, fan, network, one-click RAM free). Quick actions: **Xcode Cache Cleaner**, Secure File Shredder, Spotlight reindex, Flush DNS. Runs on M1–M5 and Intel. The product page lists no prices — [drbuho.com/buhocleaner](https://www.drbuho.com/buhocleaner)
- Toolradar: $39.99/yr or $67.99 lifetime for 1 Mac, with a free tier limited to cleaning 3 GB. It calls BuhoCleaner the "closest thing here to a one-click cleaner with a usable free tier" — [Toolradar](https://toolradar.com/blog/best-free-mac-cleaners)

**Sensei (Cindori)**
- $29/yr or $59 lifetime for up to 3 Macs, with a 7-day trial. Features: cache/log cleanup, uninstaller with leftovers, duplicates, large files, S.M.A.R.T. health, disk benchmark, TRIM, and real-time CPU/GPU/memory/disk/network/battery/sensor monitoring. It can "monitor CPU or memory from the menu bar". Requires macOS 12+, with a legacy 1.5.10 build for 10.15–11. The source is Sensei's own vendor — [Cindori](https://cindori.com/reviews/best-mac-cleaner-apps-2026)
- One third-party ranking scored Sensei 6.5/10, the lowest on its list. Nektony frames it as monitoring/hardware-focused with a 14-day trial, which conflicts with Cindori's 7 days — [Nektony roundup](https://nektony.com/reviews/best-mac-cleaning-software); [Worldmetrics](https://worldmetrics.org/best/mac-cleanup-software/)

**CCleaner for Mac (Gen Digital / Piriform)**
- Macworld (Mar 2025, older): free tier, Pro $39.95/yr. Nektony says plans start at $29.95/yr — [Dr.Buho review](https://www.drbuho.com/review/ccleaner-for-mac-review); [Nektony comparison](https://nektony.com/reviews/ccleaner-vs-maccleaner-pro)
- Macworld 2026 pros: "Strong customization; effective at clearing clutter". Cons: "Dated interface; less polished; not beginner-friendly". It "shows a clear analysis before deletion" — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- MacPaw (a competitor) says it "does feel like a Windows tool that was adapted". 1dot.ai notes past privacy/trust concerns. Dr.Buho says the 2026 Mac build is notarized and that the 2017 incident was Windows-only — [CleanMyMac blog](https://cleanmymac.com/blog/ccleaner-for-mac-review); [1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026); [Dr.Buho](https://www.drbuho.com/review/ccleaner-for-mac-review)

**Intego Washing Machine (X9)**
- Macworld 2026: €19.99/yr, also bundled in Intego's suite. It reclaimed about 24 GB on an M2 MacBook Pro on the first run. Initial duplicate indexing of a 1 TB SSD took about 5 hours. Full Disk Access had to be added manually. Cons: "Annoying pop-ups; difficult installation". Requires macOS 13+ — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- A German report says Washing Machine has been absorbed into Intego One and that Intego One lacks Smart Clean features such as duplicate search. I found no official Intego confirmation — [channelpartner.de](https://www.channelpartner.de/article/4201622/aufraum-tools-fur-mac-rechner-im-uberblick.html)

**MacKeeper (Clario/Kromtech lineage)**
- The current product is a suite covering security, privacy, cleaning and performance: Safe Cleanup (caches, logs, trash), Duplicates Finder, Smart Uninstaller, plus a VPN and breach monitoring. It is Apple-notarized. Nektony (a competitor) quotes $10.95/mo or $71.40 for the first year and puts 2026 one-star reviews at 8%. Their themes: auto-renewal charges, upsells in cancellation chats, and pressure to buy paid tech support. AV-Comparatives last marked it not approved in 2021 — [Nektony MacKeeper review](https://nektony.com/reviews/mackeeper)
- A Korean Dr.Buho review (competitor) found Safe Cleanup items mostly preselected "with little per-item explanation" — [Dr.Buho KO](https://www.drbuho.com/ko/review/mackeeper-review)
- Capterra lists a starting price of US$14.95 — [Capterra](https://www.capterra.com/p/210976/MacKeeper/)

**Parallels Toolbox**
- Macworld 2026: $24.99/yr for 1 Mac, 7-day trial. "Best all-in-one toolkit" with "solid basic cleaning but no deep optimization". It focuses on obvious junk and avoids risky deletions. Cons: subscription, and "many tools are unnecessary" — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)

**Pretty Clean**
- A free, under-5 MB, notarized disk cleaner aimed at developers: build output and compilation caches, with a user-specified source directory. It has no uninstaller. The last version I found is 0.1.18 (14 Mar 2022), launched on Product Hunt in March 2022, so it may be dormant (old info) — [MajorGeeks](https://www.majorgeeks.com/files/details/pretty_clean.html); [Product Hunt](https://www.producthunt.com/products/pretty-clean); [kocpc](https://en.kocpc.com.tw/?p=9319)

**Others in Macworld's 2026 roundup:**
- Cleaner One Pro (Trend Micro): App Store version, duplicate and Dropbox cleanup.
- Avast Cleanup Premium: "can be overly aggressive; promotional opt-ins enabled".
- AVG TuneUp: whitelists. Its uninstaller needed multiple authentications.
- diCleaner: free, "feels like an unfinished beta".
- DaisyDisk: $9.99, deletions are user-driven with a countdown.
- Klarity Disk: $6.99.
- Gemini 2 (MacPaw duplicates).
- Macworld does not recommend MacBooster.
- Source: [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)

**Newer entrants, 2025–2026, mostly developer- and AI-flavoured:**
- **Mole (tw93)**: open-source GPL-3.0 CLI `mo` with 74.3k GitHub stars. Commands: clean, uninstall, optimize, analyze, status, purge.
  - `mo purge` removes `node_modules`, `target`, `.build`, `build` and `dist`. It skips projects active in the last 7 days and protects Git-tracked files.
  - `mo clean` covers "known-safe caches, logs, temporary files, developer artifacts, and leftovers from apps that are no longer installed".
  - Safety: `--dry-run` everywhere, whitelists, and an operations log (`~/Library/Logs/mole/operations.log`, viewable with `mo history`). No undo. clean/purge delete permanently, while uninstall/analyze move items to Trash.
  - Source: [GitHub tw93/Mole](https://github.com/tw93/Mole)
  - A paid native "Mole for Mac" app costs $19 one-time and needs macOS 14+ — [tw93.fun](https://tw93.fun/projects/mole.md); [mole.fit](https://mole.fit/llms.txt)
- **Crumb**: covers DerivedData, Xcode device support, npm/pip caches, Cargo registries and Gradle/Maven. Each category shows "a size estimate and a description of what rebuilds it". Source is the vendor — [cleanwithcrumb.com](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/)
- **CleanMyDev**: targets developer caches "hidden in System Data": Xcode, Cursor, Ollama, Claude Code, npm. It moves items to Trash by default — [cleanmydev.com](https://cleanmydev.com/)
- **DevClean**: node_modules, DerivedData and Pods, with reviewable results — [devclean.app](https://devclean.app/)
- **Files Magic AI (1dot.ai)**: $6.99/mo, $34.99/yr or $49.99 lifetime. Covers node_modules, Xcode, Gradle and Flutter builds. Review-first with undo, plus Apple Intelligence renaming. It does not clear deep system caches — [1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026)
- Mac App Store dev micro-cleaners: Eraser (menu bar Xcode cleaner with scheduling), DevPowerCleanup (one-time Pro) and Cleano (subscription except DerivedData). Also seen: "CleanMyJunk – AI Disk Cleaner" and OptiClear — [Eraser](https://apps.apple.com/us/app/eraser-cleaner-for-xcode/id6758531046); [DevPowerCleanup](https://apps.apple.com/us/app/devpowercleanup/id6758896751); [Cleano](https://apps.apple.com/ua/app/cleano/id6469460523); [CleanMyJunk AI](https://apps.apple.com/us/app/cleanmyjunk-ai-disk-cleaner/id6738380105); [OptiClear](https://apps.apple.com/app/opticlear/id6761193078)

### Inferences
- The market splits in two. One side is broad consumer suites (CleanMyMac, MacKeeper, Intego, Parallels Toolbox, CCleaner) that bundle security, VPN, cloud and email. The other is a fast-growing long tail of narrow developer cleaners (Mole, Crumb, CleanMyDev, DevClean, Eraser) that came up in 2025–26. No product combines both with a meaning-based classification across all of disk.
- CleanMyMac's 2025–26 roadmap went toward breadth (cloud, Gmail, Chrome, screen cleaning, notification/offers center), not storage depth. Its roadmap entries for "AI agents" cleanup and a CLI suggest MacPaw sees the developer and AI-tooling segment coming. It could compete with the proposed product within about a year.
- Prices cluster at $25–$40/yr for a single Mac. One-time licenses exist at roughly $59–$120, and the developer-tool newcomers sit at $19–$50 one-time.

### Gaps
- **Clean Me / Mac Optimizer and iBoostUp:** no current (2025–26) information found. iBoostUp may be discontinued or obscure.
- **Parallels Toolbox:** exact cleaner categories not documented in what I fetched.
- **BuhoCleaner:** official price and full category list (iOS backups, simulators, etc.) not confirmed from the vendor page.
- **CleanMyMac:** a Basic vs Plus feature diff is not documented on the App Store page. The "Plus" tier probably includes Moonlock/protection, but that is unverified.

## Q2: How deep is developer junk coverage?

### Takeaway
Among the big commercial suites, developer coverage is shallow. It means Xcode caches/DerivedData and maybe simulators, delivered as a "quick action" (BuhoCleaner) or a single module (CleanMyMac). None I checked lists Docker, node_modules, Cargo, pip/venvs, Gradle or Homebrew as categories. That gap is why a 2025–26 wave of developer-specific tools exists.

### Cited Findings
- CleanMyMac: DerivedData and simulator runtimes, "misses ... Cargo and pip virtual environments" (competitor source). MacPaw's 5.x release notes never mention developer cleanup — [Crumb](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/); [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- BuhoCleaner: only an "Xcode Cache Cleaner" quick action is named — [drbuho.com](https://www.drbuho.com/buhocleaner)
- MacCleaner Pro: no developer categories on the product page — [nektony.com](https://nektony.com/mac-cleaner)
- Docker and node_modules are handled by CLI commands (`docker system prune`, `npkill`, `brew cleanup`) rather than by GUI cleaners. npkill "often surfaces 20–60 GB" — [Crumb](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/)
- One guide estimates 30–100 GB of developer junk on active developer Macs, mostly shown under System Data. A vendor source says node_modules plus DerivedData alone reach 30–60 GB — [1dot.ai](https://1dot.ai/blog/what-is-system-data-on-mac); [1dot.ai Xcode guide](https://1dot.ai/blog/clean-xcode-cache-mac)
- Mole `purge` is the most capable free option for project artifacts: it uses recency (7 days) and Git-tracked safeguards. Its named cache coverage, though, is npm/pnpm/Homebrew. The README does not mention Xcode, Docker, pip, Gradle or Cargo — [GitHub Mole](https://github.com/tw93/Mole)
- Crumb is the only tool found that shows "what rebuilds it" per category, which is close to the proposed "rebuild-cost" idea. It does this only for developer caches — [Crumb](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/)

### Inferences
- No surveyed product has a cross-ecosystem developer knowledge base (Xcode + Docker VM disk + JS/Rust/Python/JVM + Homebrew + ML model caches like Ollama/HF) with staleness detection per project. A community rules knowledge base would be a real differentiator.
- AI-tooling caches (Ollama models, Cursor, Claude Code) are a new junk class. Only CleanMyDev targets them so far, and CleanMyMac has them on its roadmap.

### Gaps
- Hands-on verification of whether CleanMyMac's or BuhoCleaner's "Xcode" handling includes simulator runtimes, device support and archives was not possible.

## Q3: Safety model: preview, safe lists, undo, explanations

### Takeaway
Every app has a preview/confirm step, and some have ignore lists. Real undo or quarantine is rare: DaisyDisk has a countdown, Gemini 2 and Files Magic AI have undo, Mole keeps a log only. Per-item explanations are weak across the board, and CleanMyMac's Apple-Intelligence "Smart Insights" (Oct 2025) is the only attempt at explaining system files by AI. Complaints focus on preselected items and unexplained jargon.

### Cited Findings
- CleanMyMac claims it removes only "100% safe" files. Macworld says it "occasionally flags files users need" and advises manual checking — [cleanmymac.com](https://cleanmymac.com/); [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- CleanMyMac Smart Insights: "Powered by Apple Intelligence, Smart Insights give you helpful info about system files" — [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- An App Store reviewer wanted "clearer explanations of technical terms" and hesitated to delete unexplained items — [App Store](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12)
- MacKeeper Safe Cleanup preselects items "with little per-item explanation" (competitor source) — [Dr.Buho KO](https://www.drbuho.com/ko/review/mackeeper-review)
- The Nektony uninstaller's Remaining Files feature removed critical items such as the App Store in Macworld's test — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- Avast Cleanup "can be overly aggressive". AVG TuneUp offers whitelists. DaisyDisk uses a countdown window — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- Mole: dry-run, whitelists, operations log. clean/purge delete permanently with no undo — [GitHub Mole](https://github.com/tw93/Mole)
- Files Magic AI: review-first with undo. Gemini 2 has undo history. OmniDiskSweeper deletes immediately — [1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026)
- CleanMyDev moves items to Trash by default — [cleanmydev.com](https://cleanmydev.com/)

### Inferences
- An undo log with a time-limited quarantine, plus explanations of what each item is and what it costs to rebuild, would directly address the most common user hesitation. Few competitors have either part, and none has both.

### Gaps
- Whether CleanMyMac's "Safety Database" or ignore list still exists in 5.x isn't stated on current pages.

## Q4: Do they explain "System Data" / report accurate APFS and purgeable sizes?

### Takeaway
No major cleaner explains System Data fully. CleanMyMac added a "Free Up Purgeable Space" task (Feb 2025) and AI "Smart Insights" about system files. MacCleaner Pro lists "system data" as a category without detail. None documents APFS clone/snapshot-aware sizing, and Time Machine local snapshots appear on no vendor page fetched.

### Cited Findings
- CleanMyMac 5.0.5 added "Free Up Purgeable Space", described as "data that is safe to remove when more storage is needed" — [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- MacCleaner Pro lists "system data" among its targets with no explanation — [nektony.com](https://nektony.com/mac-cleaner)
- 1dot.ai says the macOS Storage panel shows a vague "System Data" category "often with no way to clear it" and ignores developer caches. OnyX "reaches space the Storage panel hides" — [1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026)
- A general guide says System Data shrinks considerably after a reboot. This is consistent with snapshots, swap and caches being transient — [DEV Community](https://dev.to/seodigitexx/9-straightforward-steps-to-clean-up-system-data-on-your-mac-309i)
- Macworld's 2026 roundup does not address System Data for any of 14 apps — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- Developer-focused newcomers (CleanMyDev, 1dot.ai) pitch themselves as revealing what's "hidden in System Data" — [cleanmydev.com](https://cleanmydev.com/); [1dot.ai](https://1dot.ai/blog/what-is-system-data-on-mac)

### Inferences
- "Full System Data breakdown + APFS-accurate sizing (clones, sparse files, snapshots, purgeable)" looks like open ground. No incumbent markets it. Size reports in treemaps (Space Lens, DaisyDisk) probably use logical or allocated sizes without clone de-duplication, but this is unverified.

### Gaps
- No source tested the size accuracy of any cleaner against APFS ground truth.
- Whether any app lists or deletes TM local snapshots (`tmutil`) isn't confirmed.

## Q5: Pricing, distribution, Full Disk Access

### Takeaway
Subscriptions dominate (about $25–$70/yr), and one-time options are being pushed down or hidden. Direct, non-sandboxed distribution is the norm because full functionality needs Full Disk Access. CleanMyMac's App Store build is feature-limited.

### Cited Findings
| App | Price (2026) | Distribution | Source |
|---|---|---|---|
| CleanMyMac | $39.95/yr (1 Mac), $63.95 (2), $127.95 (5). MAS: $9.99/mo, $39.99/yr Basic, $65.99/yr Plus, $89.99 one-time | Direct + MAS (MAS "lacks some features") | [Cybernews](https://cybernews.com/resources/macpaw-cleanmymac-review/), [App Store](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12), [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html) |
| MacCleaner Pro | from $14.95/mo; ~$39.95/yr; one-time available | Direct .dmg | [Nektony](https://nektony.com/mac-cleaner), [Cindori](https://cindori.com/reviews/best-mac-cleaner-apps-2026) |
| BuhoCleaner | $39.99/yr or $67.99 lifetime; free tier 3 GB | Direct | [Toolradar](https://toolradar.com/blog/best-free-mac-cleaners) |
| Sensei | $29/yr or $59 lifetime (3 Macs) | Direct | [Cindori](https://cindori.com/reviews/best-mac-cleaner-apps-2026) |
| CCleaner Mac | Free; Pro $29.95–$39.95/yr | Direct | [Nektony](https://nektony.com/reviews/ccleaner-vs-maccleaner-pro), [Dr.Buho](https://www.drbuho.com/review/ccleaner-for-mac-review) |
| Intego Washing Machine | ~€/$19.99/yr promo; bundled in suite | Direct; manual FDA | [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html) |
| MacKeeper | ~$10.95/mo; $71.40 first year | Direct | [Nektony](https://nektony.com/reviews/mackeeper) |
| Parallels Toolbox | $24.99/yr | Direct | [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html) |
| Mole | CLI free (GPL-3.0); Mac app $19 one-time | Homebrew / direct | [tw93.fun](https://tw93.fun/projects/mole.md) |
| Files Magic AI | $34.99/yr or $49.99 lifetime | MAS/direct (unclear) | [1dot.ai](https://1dot.ai/blog/best-mac-disk-cleaner-apps-2026) |
| DaisyDisk | $9.99 one-time | Direct + MAS | [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html) |

- A CleanMyMac App Store user on macOS 15 reported that "Grant Access" did nothing and the app kept asking for folder access, and granting Full Disk Access didn't fix it — [App Store](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12)
- Intego requires Full Disk Access, which the reviewer had to add manually — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)

### Inferences
- A one-time or developer-friendly price ($20–$50) is well established by Mole, Sensei lifetime and DaisyDisk. Subscription fatigue is a known pain (MacKeeper billing complaints).
- A product that needs deep visibility into System Data will need direct distribution plus Full Disk Access. Onboarding friction around FDA is a known failure mode, as the CleanMyMac and Intego reports show.

### Gaps
- FDA requirements for each app aren't documented on the vendor pages fetched.

## Q6: Scheduling, background monitoring, menu bar

### Takeaway
Menu bar features at incumbents are system monitors (CPU, RAM, temperature, network), not storage-growth watchers. BuhoCleaner and Sensei have monitor menus, and CleanMyMac has a "CleanMyMac Menu". No product found offers a "which folder grew today and why" watcher.

### Cited Findings
- The BuhoCleaner menu bar shows RAM, disk usage, CPU load/temp, fan and network, with one-click RAM free — [drbuho.com](https://www.drbuho.com/buhocleaner)
- The Sensei menu bar monitors CPU and memory — [Cindori](https://cindori.com/reviews/best-mac-cleaner-apps-2026)
- CleanMyMac has a "CleanMyMac Menu" (referenced in 5.7.1). The My Activity dashboard (5.4.0) tracks cleanup progress and time saved, and Applications now scans in the background (5.5.5) — [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- Eraser: a menu bar Xcode cleaner with scheduled clean-up — [App Store](https://apps.apple.com/us/app/eraser-cleaner-for-xcode/id6758531046)
- OnyX: "Scheduling needs refinement" — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- Mole `mo status` is a terminal dashboard with a health score and JSON output, but no menu bar — [GitHub Mole](https://github.com/tw93/Mole)

### Inferences
- A storage growth watcher (per-folder deltas, attribution to an app or process, alerts) is apparently unoccupied.
- Offload to an external drive also appears in no incumbent's feature list. CleanMyMac's cloud cleanup is the closest analogue.

### Gaps
- Whether CleanMyMac's menu shows storage-growth alerts was not verified.

## Q7: Notable user complaints

### Takeaway
The recurring complaint themes:
- subscription and billing aggression (MacKeeper most of all)
- upsell and "offers" surfaces (CleanMyMac added a notification center for offers in 2026)
- preselected deletions with little explanation
- permission/FDA bugs
- incomplete uninstalls
- "overlaps with built-in macOS tools"
- historical trust issues (MacKeeper, CCleaner)

Direct Reddit and Trustpilot evidence was not retrievable in this session.

### Cited Findings
- MacKeeper 2026 one-star themes: auto-renewal charges, upsells during cancellation, and pushes for paid tech support (competitor source) — [Nektony](https://nektony.com/reviews/mackeeper)
- CleanMyMac App Store complaints:
  - uninstalls reported as complete while the apps remained (2024)
  - support demanding card or bank details for App Store purchases
  - FDA grant loop on macOS 15
  - unclear technical terms
  - Source: [App Store](https://apps.apple.com/us/app/cleanmymac/id1339170533?mt=12)
- CleanMyMac 5.6.0 added a Notification Center for "product news, offers, and other useful messages" — [MacPaw What's New](https://macpaw.com/cleanmymac/whats-new)
- Macworld on CleanMyMac: "Expensive; overlaps with built-in macOS tools; occasionally flags files users need". On Avast: "promotional opt-ins enabled". On Intego: "Annoying pop-ups" — [Macworld](https://www.macworld.com/article/673271/best-mac-cleaner-tested-compared.html)
- CCleaner: lingering trust concerns from the 2017 (Windows) incident — [Dr.Buho](https://www.drbuho.com/review/ccleaner-for-mac-review)
- MacKeeper was marked not approved by AV-Comparatives in 2021 — [Nektony](https://nektony.com/reviews/mackeeper)
- Mole's popularity (74k stars) and one-off claims such as "Clear 95GB of macOS Junk with One Command" suggest developers prefer transparent, scriptable, open tools to opaque suites — [GitHub](https://github.com/tw93/Mole); [recca0120 blog](https://recca0120.github.io/en/2026/03/09/mole-macos-cleaner/)

### Inferences
- Trust is the main currency. Transparency (open rules, explanations, undo, no upsell surfaces) is a positioning wedge against CleanMyMac and MacKeeper.
- Background, unverified this session: MacKeeper has a long history of aggressive advertising and a US class-action settlement (around 2015). Older CleanMyMac versions were criticised for overstating "junk" totals. The report writer should verify these before using them.

### Gaps
- Reddit (r/mac, r/MacOS) threads and Trustpilot scores could not be retrieved, because search returned no Reddit results. Quantitative "space actually freed" complaints are not sourced here beyond Macworld's test figures: MacCleaner Pro 11.4 GB / 65.4 GB, Intego about 24 GB.
- No 2025–26 coverage was found from 9to5Mac, The Verge or Ars Technica on Mac cleaners.
