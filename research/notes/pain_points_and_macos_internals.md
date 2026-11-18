# Mac Disk Space: User Pain Points and macOS Technical Constraints for a Space-Reclaimer App (as of Nov 2026)

Context on versions: macOS 26 Tahoe shipped Sept 2025 (Eclectic Light tests run on 26.6.2 in Aug 2026). macOS 27 "Golden Gate" was in RC in late Sept 2026 per MacRumors and is now the current release. Most technical findings below were verified on Tahoe 26.x. Many web sources on this topic are cleaner-app vendors (MacPaw/CleanMyMac, BuhoCleaner, iBoysoft, Nektony, Mole, Setapp) and are flagged as such.

## Q1. Top recurring complaints and discovered culprits (2024–2026), with sizes

### Takeaway
The main complaint is a huge, opaque "System Data" figure (100–500+ GB reported) that Storage Settings won't explain or let you delete. When users do find the cause, it is almost always one thing growing without limit: Time Machine/APFS snapshots (especially with VMs), cloud-sync caches (Google Drive), app scratch/cache stores (Photoshop, video editors), runaway logs, developer artifacts (Xcode, simulators, Docker), and since macOS 27, Apple Intelligence models (20–30 GB) that users can no longer opt out of.

### Cited Findings
- Apple Community user with **over 500 GB of System Data** traced it to **Google Drive** — [Apple Community](https://discussions.apple.com/thread/256062620)
- **Photoshop**: System Data grew to about 860 GB while the app was open and fell back to 18 GB when it closed (scratch disk) — [Adobe Community](https://community.adobe.com/t5/photoshop-ecosystem-discussions/scratch-disk-issue-photoshop-is-filling-all-space-in-my-harddrive-via-system-dat-a/m-p/14243966/highlight/true)
- **240 GB of "ChunkStorage"** from a video-editing app cache sat inside System Data; Premiere Pro 2025 threads report similar volume bloat — [Adobe Community](https://community.adobe.com/t5/premiere-pro-discussions/premiere-pro-2025-crashes-and-takes-too-much-volumes/m-p/14936280)
- A **304 GB log file in /opt/homebrew/var/log** was the cause for one user (as summarized from the forum search results) — [Apple Developer Forums, "System uses ~300GB"](https://developer.apple.com/forums/thread/79609?page=8)
- About 200 GB of System Data after installing the Sequoia beta, cause never found — [Apple Developer Forums](https://developer.apple.com/forums/thread/758416)
- Complaints about how much space Apple's own categories take ("Other Users and Shared", macOS, System Data) — [Apple Developer Forums](https://developer.apple.com/forums/thread/766370)
- System storage keeps growing after the Sequoia upgrade across a managed fleet. Spotlight re-indexing shrank it briefly before it grew back, and a 15.4 update stabilized it — [Jamf Community](https://community.jamf.com/general-discussions-2/system-storage-space-increasing-in-the-mac-after-upgrade-to-sequoia-34657)
- A reader of Oakley's blog cut System Data from **163.35 GB to 16.78 GB** by deleting a folder of pasteboard (clipboard) archives on a 2019 MBP. Oakley does not endorse the method — [Eclectic Light, Feb 2025](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/)
- A reader comment reports **276.96 GB System Data**. Oakley notes that 50 GB is already "enough to cause panic" and that Storage sometimes never finishes calculating System Data — [Eclectic Light, Sept 2026](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)
- **VMs in snapshots**: snapshots can't exclude folders, so large VMs get captured. Oakley cites one case over **400 GB** — [Eclectic Light, Oct 2025](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/)
- Founder of a cleaner app (FreeUpMyMac) says his System Data reached **300 GB** and took months to diagnose (anecdotal, and he is selling the app) — [Product Hunt](https://www.producthunt.com/products/freeupmymac)
- **macOS 27 / Apple Intelligence**: MacRumors measured **20.67 GB** on an M4 Pro Mac mini. Ars Technica measured **22.42 GB** on an M3 MacBook Air, and ~14 GB on an M1 Air and the MacBook Neo, above their 8 GB tier. A Reddit RC screenshot showed **30.16 GB**, and another user reported 24.35 GB on an M3 Pro. Apple's support document says "up to 14 GB" (M3+ with 12 GB+ RAM) or "up to 8 GB" (other Macs). **Apple removed the Apple Intelligence disable toggle** in macOS 27, so the models download automatically. The entry appears in Storage under macOS (info button) — [MacRumors, 2026-09-23](https://macrumors.com/2026/09/23/apple-intelligence-30gb-some-macs-macos-27)
- One user reported System Data of ~121.6 GB on a 500 GB Mac mini after macOS 27, and ~125 GB lost free space after upgrading. These are vendor forums, so treat them as anecdotal — [iBoysoft forum](https://iboysoft.com/forums/t/lost-around-125-gb-of-free-space-after-upgrading-my-mac-mini-to-macos-27/913); [Tom's Guide](https://www.tomsguide.com/computing/if-your-mac-is-suddenly-running-out-of-space-after-macos-27-check-this-one-setting)
- Reporting disagrees on whether AI models count under "macOS" or "System Data" — [Gadget Hacks](https://apple.gadgethacks.com/news/macos-27-apple-intelligence-storage-space-up-to-30gb-used/)
- Under Sequoia, Apple Intelligence needed about 7 GB (vendor claim) — [MacPaw](https://macpaw.com/how-to/clear-system-storage-mac)
- **Developer artifacts** (vendor blogs, rough figures): DerivedData typically 20–60 GB, with a sample of 50 developer Macs averaging 23.4 GB and maxing at 83 GB. CoreSimulator devices take 20–150 GB, at 5–8 GB per runtime. Docker Desktop's single `Docker.raw` VM disk takes 10–30 GB and **does not shrink when images are deleted**. A typical developer accumulates 50–150 GB of reclaimable artifacts per year — [dissectmac](https://dissectmac-com.pages.dev/blog/clean-xcode-derived-data); [DEV Community](https://dev.to/pyrx_tech/the-complete-xcode-cleanup-guide-for-iosmacos-developers-reclaim-50-150-gb-2026-2h5j); [ClearDisk blog](https://bysiber.github.io/cleardisk/blog/xcode-simulators-device-support-cleanup-mac.html); [Kodeco](https://www.kodeco.com/19998365-understanding-and-managing-xcode-space)
- **The 256 GB Mac budget**: two hidden containers take ~6 GB, the System volume just over 12 GB, Preboot just under 8 GB, and Recovery/other under 2 GB. That leaves at most **~228 GB** for the Data volume, minus VM swap — [Eclectic Light](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/)
- What counts as "normal" System Data is disputed: guides say 12–25 GB or 5–20 GB, and Apple publishes no range. Commonly cited causes are local snapshots, leftovers from deleted apps, old iPhone backups, and developer files. Restarting can drop it by several GB — [Setapp](https://setapp.com/how-to/macos-system-data-large); [DrBuho](https://www.drbuho.com/how-to/clear-system-storage-mac); [1dot.ai](https://1dot.ai/blog/what-is-system-data-on-mac) (all vendor/SEO)
- The ongoing TidBITS thread on excessive System Data on a MacBook Pro shows that even expert users struggle to diagnose it — [TidBITS Talk](https://talk.tidbits.com/t/excessive-system-data-on-a-macbook-pro-any-ideas/33460)
- Common diagnostic tips from forums: OmniDiskSweeper or another disk-space analyzer, and Activity Monitor → Disk → sort by Bytes Written to find runaway writers — [Apple Community](https://discussions.apple.com/thread/256062620)

### Inferences
- The best product opportunity is attribution: mapping "System Data" GB back to a named owner app or process (Google Drive, Photoshop scratch, Docker.raw, snapshots, AI models). Generic "junk" cleaning is less valuable. Users usually lose to one runaway item, not to a pile of small caches.
- On 256 GB machines, the fixed ~28 GB overhead, 20–30 GB for AI models, and 24h snapshot retention leave very little headroom. A single VM or video project can trigger a crisis.
- The macOS 27 removal of the AI opt-out is a fresh, high-salience pain point (398 comments on MacRumors) that a tool can explain but likely cannot fix. The models live on Apple-managed storage.

### Gaps
- I found no Hacker News threads with useful data on this in my searches. Reddit threads came up only indirectly, through redlib mirrors about fake CleanMyMac installers.
- No quantitative survey of what fills 256/512 GB Macs. All size figures are anecdotes or vendor estimates.
- iOS/iPadOS device backups (`~/Library/Application Support/MobileSync/Backup`) and iOS update files are widely cited as culprits, but I found no 2024–2026 primary source quantifying them.

## Q2. What breaks if you delete caches, and which folders are dangerous

### Takeaway
User caches regenerate, but deleting them costs performance and sometimes logins or offline data. Personal data stores, Containers, Group Containers, Application Support, cloud-sync folders, and system locations are where cleaners cause real damage. macOS already purges opted-in caches itself through `deleted`, so manual cache wiping often gains little.

### Cited Findings
- Caches that macOS manages are usually current and in active use, not stale. Deleting all QuickLook previews makes Finder Gallery view much slower until they rebuild. Tools that clean "old caches" (such as Cocktail) may not touch the caches `deleted` manages — [Eclectic Light, Tahoe caches](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)
- Safari's Empty Caches makes familiar sites load slower, which shows how much caching helps — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)
- Clearing `~/Library/Caches` is generally safe but often gains little: one Apple Community responder would recover only ~2.6 GB. Performance dips until caches rebuild — [Apple Community](https://discussions.apple.com/thread/256036043)
- Deleting system caches in `/Library/Caches` or `/System/Library` can cause startup failures. Safe Mode is the supported way to clear font, kernel and other system caches — [iBoysoft wiki](https://iboysoft.com/wiki/library-caches-mac.html) (vendor)
- In `~/Library/Containers/<bundle-id>/`, only `Data/Library/Caches/` is a safe target, because the rest is the app's full sandboxed home. Group Containers are shared across apps, so deleting one breaks several — [Mole blog](https://mole.fit/blog/what-mac-cleaners-should-never-delete.md); [iBoysoft containers](https://iboysoft.com/wiki/mac-containers-folder.html); [Apple Community, Group Containers](https://discussions.apple.com/thread/251019023)
- Don't remove the containers of cloud-sync apps (OneDrive) you still use — [Apple Community](https://discussions.apple.com/thread/254501473)
- A "never delete" list (vendor Mole), with consequences:
  - Photos, Mail, Messages, Notes and Voice Memos stores: permanent data loss.
  - iCloud Drive / Mobile Documents and `~/Library/CloudStorage/`: deletion propagates to other devices.
  - Keychains, browser login databases and token stores: lost logins.
  - TCC databases, MDM profiles and security-agent state.
  - Staged macOS install payloads: boot or install may fail.
  - Live package-manager stores during builds.
  - Vendor parent folders while another product from the vendor remains.
  - Application Support: app databases, offline packs and license state are lost.
  - Clipboard-history image stores under Caches.
  - Compiled model / Neural Engine stores: recognition breaks until reboot.
  - tmp/Temp: checkpoints, unsaved drafts and installer state are lost.
  - Large .db/.sqlite files.
  - Rebuildable items cost time and bandwidth: `node_modules`, `Pods`, `.venv`, `DerivedData` (need network and lockfiles), package caches, local AI weights, DeviceSupport (license prompts).
  - HTTP and bytecode caches: slower first loads and CPU to rebuild.
  - Core rule: "Caches regenerate. Deleted conversations and libraries do not."
  - [Mole](https://mole.fit/blog/what-mac-cleaners-should-never-delete.md)
- Deleting simulator runtimes means re-downloading them. `xcrun simctl runtime delete --notUsedSinceDays 180` is a targeted alternative. `docker system prune -a --volumes` also deletes unused volumes, which may hold data — [ClearDisk blog](https://bysiber.github.io/cleardisk/blog/free-disk-space-mac-developer); [DEV Community](https://dev.to/pyrx_tech/the-complete-xcode-cleanup-guide-for-iosmacos-developers-reclaim-50-150-gb-2026-2h5j)
- A 1Password "AccountExports" folder of 18 GB is an example of app-specific bloat inside a container — [1Password Community](https://www.1password.community/discussions/1password/accountexports-folder-18gb-of-storage/50695)
- Post-upgrade temporary files are normally removed within 24h. Booting to Safe Mode briefly and restarting speeds this up — [Eclectic Light](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/)

### Inferences
- A safe app should classify paths into tiers: regenerable-cheap, regenerable-costly (network/time/license), user-data, and shared/system. It should default to Trash or a quarantine with undo, and refuse or warn when the owning app is running.
- Running a cache-wipe on files that macOS already treats as purgeable produces "freed" numbers that macOS would have reclaimed anyway, at a performance cost.

### Gaps
- No authoritative Apple list of which `~/Library/Caches` subfolders hold login tokens or offline data. This varies per app.

## Q3. How Apple's Storage Settings categorize space, and where they're wrong

### Takeaway
Storage Settings sorts by data type, not location. "System Data" is a residual: whatever isn't attributed to another category. It absorbs uncategorized user files, snapshots and caches, has no Time Machine category, and omits purgeable space. Oakley's advice is not to trust it, and to use Disk Utility for numbers and a location-based visualizer (DaisyDisk) for hunting.

### Cited Findings
- Apple defines System Data as "the storage space used by all Apple and third-party files that don't belong to any more specific category" — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)
- Oakley calls it "an etcetera, a ragbag", essentially the gap between used space and the other categories. On his Mac, over 100 GB of music counted as under 50 GB in Music, with the rest likely in System Data. TV showed 36 GB even though the libraries are external, and Photos was not listed at all. There is **no Time Machine category**, so snapshot space lands in System Data. Drilled-down Applications bundle sizes don't add up to the category total. Recommendation: "don't trust Storage settings"; use Disk Utility (container free space, with the bracketed purgeable figure per volume) — [Eclectic Light, Feb 2025](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/)
- Useful built-in sub-tools: Applications (sizes, Intel-only, duplicates), Developer (Xcode build files and device support), Documents, Messages attachments, Music Creation, and macOS (shows Apple Intelligence space) — [Eclectic Light](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/)
- Finder and Storage settings omit purgeable space, so their figures are wrong. Finder Get Info never mentions purgeable space. Disk Utility is the most consistent tool but still not always accurate (Tahoe 26.6.2) — [Eclectic Light, Aug 2026](https://eclecticlight.co/2026/08/24/arent-snapshots-purgeable/)
- Finder's free-space figure refreshes only periodically. In 2023 Finder reported 0 bytes purgeable while snapshots held 3.53 GB — [Eclectic Light 2023](https://eclecticlight.co/2023/04/17/the-finder-confuses-with-wildly-inaccu); [search summary of Eclectic Light](https://eclecticlight.co/2023/04/19/ventura-space-management-what-gets-purged-and-how/)
- In Apple Community, a whole disk was incorrectly marked as purgeable — [Apple Community](https://discussions.apple.com/thread/255870214)
- One App Store cleaner claims the "old System Data estimate counted your own large files (build folders, model weights, disk images) as system data and could overstate it by hundreds of GB" (vendor claim) — [Sediment, App Store](https://apps.apple.com/app/id6785442064)
- Storage figures can take hours to update after changes — [iThinkDiff](https://www.ithinkdiff.com/how-to-free-up-storage-on-your-mac-after-updating-to-macos-27-golden-gate/)
- In a Sept 2026 post, Oakley calls the Storage section "becoming increasingly useful" and recommends using it during a crisis, because visualizers like DaisyDisk build their own caches that need free space — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)

### Inferences
- A differentiating feature would be "explain System Data": scan for files Storage can't attribute (user-owned files in odd places, app scratch, VM images, snapshots, MobileSync) and reconcile the numbers against Storage's total.
- The app should work in a near-full disk state, with a low-memory, low-disk scan and no large on-disk index. That is when users need it most.

### Gaps
- Apple does not document category membership rules. I did not find official notes on any Storage Settings changes in macOS 27 beyond the Apple Intelligence entry.

## Q4. How to measure "real" freed space under APFS, and pitfalls in competitors

### Takeaway
Under APFS, deleting a file often frees less than its size, sometimes nothing. Clones share blocks, sparse and compressed files have allocated sizes below their logical sizes, snapshots pin deleted blocks (Time Machine for up to 24h, third-party snapshots indefinitely), and purgeable space is reported inconsistently. The honest metric is container free-space delta measured before and after, plus allocated (not logical) size during scanning, with explicit warnings about snapshots and clones.

### Cited Findings
- APFS special files: clones initially share data and diverge as they change. Sparse files store only non-null data. Compressed files are common on the System volume. Dataless files keep their data in iCloud (Data volume only). APFS counts actual on-disk use. All volumes in a container share free space, and **container free space is generally reliable** (`diskutil apfs list`). Example on 26.6.2: Finder Get Info said 826.67 GB used, Disk Utility said 814.03 GB — [Eclectic Light, Aug 2026](https://eclecticlight.co/2026/08/21/the-arithmetic-of-free-space/)
- Capacity = Available + (Used − Purgeable). Snapshots were later folded into "purgeable". tmutil says local snapshots "may be removed at any time by deleted(8)". In tests on 26.6.2, macOS **failed to purge the snapshot on at least two occasions** when space was needed, and Disk Utility showed purgeable as either 549 KB or 94.8 GB for the same state. Apps with a restricted entitlement can create third-party APFS snapshots, which may not be purgeable — [Eclectic Light](https://eclecticlight.co/2026/08/24/arent-snapshots-purgeable/)
- Snapshots retain deleted data for up to 24h, so "freed" space doesn't appear until the snapshot ages out or is deleted (Disk Utility → View → Show APFS Snapshots) — [Eclectic Light](https://eclecticlight.co/2025/02/11/what-is-system-data-in-storage-settings/); [Eclectic Light](https://eclecticlight.co/2025/10/02/why-did-that-macos-upgrade-take-so-much-space/)
- Purge mechanics: `deleted` (subsystem `com.apple.cache_delete`) polls each caching service registered under `/System/Library/CacheDelete` (on the sealed volume) for freeable bytes, then purges in escalating urgency phases starting at level 3. Third-party apps can opt files in by marking them purgeable, which adds them to `com.apple.fspurgeable_data`. A Tahoe test purge freed ~94.9 GB, mostly TM snapshots, raising free space from 5.2 GB to ~100 GB. Purging is frequent during macOS updates — [Eclectic Light, Tahoe](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)
- Disk Utility Help says purgeable files can't be removed manually. Oakley notes this contradicts the fact that snapshots can be deleted manually — [Eclectic Light](https://eclecticlight.co/2026/08/21/the-arithmetic-of-free-space/)
- Tools like **diskr** report both allocated and apparent size, because clones, sparse files and compression make logical and on-disk sizes diverge. **dumac** deduplicates hard links by inode — [diskr](https://awesome.ecosyste.ms/projects/github.com%2Fmilobeans%2Fdiskr); [dumac](https://awesome.ecosyste.ms/projects/github.com%2Fhealeycodes%2Fdumac)
- MacPaw research distinguishes logical size from physical (allocated) size and uses physical size for usage analysis — [MacPaw Research](https://research.macpaw.com/publications/disco); [MacPaw news](https://macpaw.com/news/calculate-macos-file-hierarchy-size)
- Docker: deleting images does not shrink `Docker.raw`, so a cleaner that deletes images inside it reports savings that never reach the filesystem — [ClearDisk](https://bysiber.github.io/cleardisk/blog/free-disk-space-mac-developer)
- The App Store version of DaisyDisk can't purge system storage files because of the sandbox (reader comment) — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)

### Inferences
- Recommended approach: show allocated size while scanning. Flag files with a shared-clone risk, since there is no cheap public API for whether blocks are exclusively owned (see Gaps). After deleting, report the measured change in container free space, and separately "pending: held by snapshot X". Offer to delete local TM snapshots explicitly (`tmutil deletelocalsnapshots`, which needs no root for TM snapshots in many configurations; verify).
- Competitor pitfall pattern: summing logical sizes, double-counting hard links and clones, counting purgeable caches as "junk freed", and claiming Docker or VM savings that don't shrink the image.

### Gaps
- I did not verify Apple's documentation for `URLResourceKey.totalFileAllocatedSizeKey` / `fileAllocatedSizeKey` in this session. From general knowledge, these give allocated size including metadata but do not account for clone sharing. Confirm before relying on this.
- No public API surfaced for "bytes exclusively owned by this clone" (APFS private-size). Oakley has written separately on clone accounting, but I did not fetch it.

## Q5. Distribution constraints: sandboxed App Store app vs notarized direct download; privileged helpers, scanning APIs, FSEvents

### Takeaway
Mac App Store apps must be sandboxed. There is no Full Disk Access entitlement, and a user granting FDA does not lift sandbox restrictions, so App Store cleaners can only touch user-selected folders (via security-scoped bookmarks) and can't purge system storage. A notarized Developer ID app can ask the user for FDA (TCC) and install a root helper via SMAppService (macOS 13+, which replaced SMJobBless), still subject to the SIP-protected, sealed system volume.

### Cited Findings
- App Store apps must enable App Sandbox. "Full disk access" is not an available entitlement, App Review can't grant it, and only users can. Granting FDA to a sandboxed app does not override sandbox checks. The workaround is user-picked folders plus security-scoped bookmarks — [Apple Developer Forums 807142](https://developer.apple.com/forums/thread/807142); [Apple Developer Forums 124895](https://developer.apple.com/forums/thread/124895)
- Some App Store storage tools (Storage Radar) advertise a "Standard install on the Mac App Store" alongside FDA features. How they reconcile this is unverified, and likely a reduced feature set — [Storage Radar](https://storageradar.chama.pro/); [Storage Radar blog on blocked paths](https://storageradar.chama.pro/blog/how-to-fix-blocked-paths-and-permissions-in-macos-cleanup-tools)
- CleanMyMac ships an App Store edition alongside its direct version — [App Store listing](https://apps.apple.com/us/app/cleanmymac/id1339170533)
- `/System/Library/CacheDelete` and the system volume are sealed and can't be modified — [Eclectic Light](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)
- Oakley criticizes a third-party cleaner for running privileged operations through a scripted workaround, calling it "dangerous and amateur". He advises checking how cleaners obtain privileges — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)
- SMAppService (ServiceManagement, macOS 13+) registers daemons, agents and login items. Services can sit in `.requiresApproval` until the user enables them in System Settings → General → Login Items & Extensions. SMJobBless was deprecated in macOS 13. (The Apple doc page failed to render, so this summary comes from the fetch tool's general knowledge; verify.) — [Apple SMAppService docs](https://developer.apple.com/documentation/servicemanagement/smappservice)
- `getattrlistbulk(2)` returns attributes for many directory entries per kernel call and is used by fast scanners (diskr, dumac — "much faster than the next leading disk usage program"). Caveats: an ERANGE bug when a 16K buffer is exactly filled on APFS, and a 2019 filesystem-dev thread where readdir was ~2x faster than alternatives on APFS in one test — [diskr](https://awesome.ecosyste.ms/projects/github.com%2Fmilobeans%2Fdiskr); [dumac/healeycodes](https://healeycodes.com/optimizing-my-disk-usage-program); [Apple Forums 98262](https://developer.apple.com/forums/thread/98262); [filesystem-dev list](https://lists.apple.com/archives/filesystem-dev/2019/Apr/msg00010.html); [Thomas Tempel blog](https://blog.tempel.org/2019/04/)
- APFS directory statistics (fast directory sizing) were announced but remain only partially implemented and rarely used — [CachyOS forum](https://discuss.cachyos.org/t/fast-directory-size-calculation-on-linux-apfs-equivalent-will-we-see-native-fast-metadata-tracking/36489)
- Third-party apps can opt their caches into OS purging through the purgeable flag — [Eclectic Light](https://eclecticlight.co/2026/09/02/caches-and-purging-in-macos-tahoe/)

### Inferences
- A product strategy that fits the constraints: a direct-download notarized app as the full product (FDA for scanning `~/Library`, Mail, Messages and so on; an optional SMAppService daemon only for root-owned targets like `/Library/Caches`, `/private/var/folders` of other users, and snapshot deletion), plus an optional App Store "lite" analyzer limited to user-granted folders.
- Under TCC, even a non-sandboxed app without FDA gets prompts or silent denials for protected locations (Mail, Messages, Safari, Desktop/Documents/Downloads, removable volumes). A scanner must handle EPERM gracefully and report "N GB not visible: grant FDA".
- For incremental monitoring, FSEvents (with the persistent event ID / sinceWhen) lets an app rescan only changed directories, avoiding full scans. Not verified in this session; see Gaps.

### Gaps
- I did not fetch Apple's FSEvents, TCC, or App Sandbox entitlement docs in this session. The FSEvents behavior (directory-level granularity, event-ID replay, the `kFSEventStreamCreateFlagFileEvents` option) comes from general knowledge.
- No sources fetched for swap/sleepimage (`/private/var/vm`), `/private/var/folders`, or Spotlight index sizes on Tahoe/27.
- I found no info on macOS 27-specific changes to the sandbox, TCC, or SMAppService.

## Q6. Trust signals users want from cleaner apps

### Takeaway
Distrust of cleaners is widespread, driven by MacKeeper-era scareware, fake CleanMyMac installers that spread malware, subscriptions, and vague "junk" claims. Users and experts favor open source (Pearcleaner, Mole, OnyX as a free tool), path-level previews, move-to-Trash and undo, clear explanation of what each item is and what breaks, and transparent privileged-helper design.

### Cited Findings
- June 2024: fake CleanMyMac installers distributing malware (r/mac, r/apple, Moonlock) — [r/apple mirror](https://redlib.belloworld.it/r/apple/comments/1df8gai/beware_of_fake_cleanmymac_installers_that_will); [r/mac mirror](https://lr.eu.psf.lt/r/mac/comments/1df85en/beware_of_fake_cleanmymac_installers_that_will/lhejqui/?context=3)
- Open-source alternatives commonly recommended: Pearcleaner (described as "best open-source alternative to CleanMyMac"), BleachBit, Mole (a CLI, source on GitHub), PureMac, and OnyX (free) — [OpenAlternative](https://openalternative.co/alternatives/cleanmymac); [Nektony review of Mole](https://nektony.com/reviews/is-mole-mac-cleaner-safe); [PureMac](https://pyshine.com/PureMac-Open-Source-macOS-Cleaner/); [Microsoft Tech Community](https://techcommunity.microsoft.com/discussions/windows11/is-cleanmymac-a-safe-program-as-a-mac-cleaner/4512304)
- Forum argument: open source lets anyone inspect what gets deleted, and aggressive cleanup can remove useful cache data — [Microsoft Tech Community](https://techcommunity.microsoft.com/discussions/windows11/is-cleanmymac-a-safe-program-as-a-mac-cleaner/4512304)
- Vendors themselves compete on "safety" messaging (Cindori, "are mac cleaner apps safe"), and MacPaw argues against free cleaners. This shows safety is the battleground — [Cindori](https://cindori.com/reviews/are-mac-cleaner-apps-safe); [MacPaw](https://macpaw.com/how-to/why-free-mac-cleaners-not-a-good-idea)
- Oakley's expert view: be cautious with cleaners, check how they do privileged operations, and prefer Storage or DaisyDisk for finding large files — [Eclectic Light](https://eclecticlight.co/2026/09/06/last-week-on-my-mac-storage-crisis-management/)
- Concern about a 2026 wave of "vibe-coded" Mac utilities and what gets lost in quality — [boorghani RSS repost](https://rss.boorghani.com/vibe-coded-mac-apps-are-arriving-fast-here-is-what-gets-lost-in-the-process)
- The pricing model is a trust factor: Mole positions itself as a one-time purchase vs CleanMyMac's subscription (vendor comparison) — [mole.fit](https://mole.fit/blog/cleanmymac-alternative)
- Recommended practice: delete only identifiable cache subfolders and move to Trash rather than deleting permanently — [Apple Community](https://discussions.apple.com/thread/256036043); [Cindori how-to](https://cindori.com/how-to/how-to-clear-cache-on-mac-safely)

### Inferences
- Trust feature checklist for the product:
  - Open source or auditable rules.
  - A per-item preview showing path, owner app, last access, and "what happens if deleted".
  - Default to Trash or quarantine with one-click undo.
  - No inflated "junk found" numbers: report allocated bytes and the measured free-space change.
  - No scareware alerts, menu-bar nagging, or bundled "optimizers".
  - Signed, notarized, and documented SMAppService helper with minimal scope.
  - Works offline with no telemetry.
  - Explains Apple-managed items (snapshots, AI models, purgeable) rather than pretending to "clean" them.

### Gaps
- No Hacker News primary threads were retrieved. No quantitative user survey on trust preferences was found.
