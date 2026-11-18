# Developer-focused disk cleanup tools for macOS (as of Nov 2026)

Method note: GitHub star, license, and activity numbers come from the GitHub REST API (`api.github.com/repos/...`), queried on 2026-11-08. Mole's rule counts come from reading its source on `main` (`lib/clean/dev.sh`, `lib/clean/purge_shared.sh`, `lib/clean/project.sh`) on the same date. For the ecosystem-native commands (uv, pnpm, brew, docker prune, conda, ollama, gradle, cargo-cache) the citation is the official docs URL. Only the Hugging Face page was fetched in this session; the other native-command citations come from prior knowledge and are flagged in Gaps.

## Q1. Which ecosystems does each tool cover, and how many rules or targets?

### Takeaway
Mole (tw93/Mole) is by far the broadest and most popular. It has roughly 57 `clean_*` functions in its dev module, 207 `safe_clean` call sites, and 34 project-artifact directory names. Project-artifact cleaners divide in two. kondo (23 project types) and clean-dev-dirs (16 languages) detect a project from its marker file. npkill is directory-name based and node-first, with "profiles". Xcode-only tools such as DevCleaner cover about 6 categories. None of the general tools covers ML model stores (Hugging Face, Ollama) well. Mole's dev module has no Ollama or HF rules.

### Cited Findings

**Mole (tw93/Mole)**
- 74,274 stars, GPL-3.0, pushed 2026-11-08. Latest release V1.70.0, published 2026-11-08 — [GitHub API](https://api.github.com/repos/tw93/Mole), [releases](https://github.com/tw93/mole/releases)
- Bash CLI (`mo`) with subcommands clean, uninstall, optimize, analyze, status, purge, installer, and slim. It cleans user and app caches, logs, browser caches, dev caches (npm, pnpm, etc.), project build artifacts, installers (DMG/PKG/ISO/XIP/ZIP), and Homebrew caches — [README](https://github.com/tw93/Mole)
- `lib/clean/dev.sh` is 6,328 lines with about 57 `clean_*` functions. They cover AI agents (Codex, Claude Desktop bundled versions, cursor-agent, Antigravity), API tools, automation browsers (Playwright/Puppeteer-style), CI/CD, cloud, databases, Docker, Elixir, frontend, Go, JetBrains logs and Toolbox, JVM, mise, mobile, network, Nix, npm, OCaml, Perl, Python, Ruby, Rust, shell, bun, corepack, pnpm stores, uv, conda metadata, pyinstaller, clang module cache, GitHub CLI cache, and Xcode (DeviceSupport, documentation cache, system CoreSimulator caches, XCTest devices). The file contains 207 `safe_clean` invocations — [dev.sh source](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh)
- Purge targets: 34 hard-coded directory names in `MOLE_PURGE_TARGETS`. They are node_modules, target, build, dist, venv, .venv, .pytest_cache, .mypy_cache, .tox, .nox, .ruff_cache, .gradle, .terragrunt-cache, `__pycache__`, .next, .nuxt, .output, vendor, bin (guarded), obj, .turbo, .parcel-cache, .dart_tool, .zig-cache, zig-out, .angular, .svelte-kit, .astro, coverage, DerivedData, Pods, .cxx, .expo, and .build. Default search roots include ~/www, ~/dev, ~/Projects, and ~/GitHub — [purge_shared.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/purge_shared.sh)
- A July 2026 PR added discovery of orphaned Xcode DerivedData from deleted workspaces — [PR #1302](https://github.com/tw93/Mole/pull/1302)
- A grep of dev.sh for "ollama" and "huggingface" found no matches, so no ML-model rules were seen — [dev.sh source](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh)

**kondo (tbillington/kondo)**
- 2,584 stars, MIT, last push 2026-04-24, 50 open issues — [GitHub API](https://api.github.com/repos/tbillington/kondo)
- It covers 23 project types: Cargo, CMake, Composer, Elixir, Godot 4.x, Gradle, Jupyter, Pixi, Maven, Node, Pub (Dart), Python, SBT, Stack, Cabal, Swift, Unity, Unreal Engine, Zig, .NET, Turborepo, Terraform, and React Native. `--older 3M` filters by age — [README](https://github.com/tbillington/kondo)

**npkill (voidcosmos/npkill)**
- 9,501 stars, MIT, pushed 2026-11-08 — [GitHub API](https://api.github.com/repos/voidcosmos/npkill)
- The default target is node_modules. `-p` profiles (default "node") select target sets, and `-t` takes arbitrary comma-separated dir names. It has `--older-than N` days, a `last_mod` column, `--dry-run`, `--json`/`--json-stream`, and a Node API — [README](https://github.com/voidcosmos/npkill)
- A 2025 HN post was titled "npkill goes beyond node_modules", marking the shift to multi-ecosystem profiles — [HN 44722252](https://news.ycombinator.com/item?id=44722252)

**clean-dev-dirs (clean-dev-dirs/clean-dev-dirs, formerly TomPlanche)**
- 21 stars, Apache-2.0 (crate is "Apache-2.0 OR MIT"), last push 2026-06-15, crate version 2.8.2 — [GitHub API](https://api.github.com/repos/TomPlanche/clean-dev-dirs), [docs.rs README](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md)
- It covers 16 languages, each detected by a marker file and mapped to a target dir. Examples: Cargo.toml→target, package.json→node_modules, pyproject/setup.py/requirements→`__pycache__`/.venv/build/dist, go.mod→vendor, pom.xml→target, build.gradle→build, CMakeLists/Makefile→build, Package.swift→.build, .csproj→bin/obj, Gemfile→.bundle or vendor/bundle, mix.exs→_build, deno.json→vendor, composer.json→vendor, stack.yaml→.stack-work, cabal→dist-newstyle, pubspec.yaml→.dart_tool/build, build.zig→zig-cache/zig-out, build.sbt→target — [docs.rs README](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md)

**DevCleaner for Xcode (vashpan/xcode-dev-cleaner)**
- 1,620 stars, GPL-3.0, last push 2026-05-18. It is a GUI app on the Mac App Store (tip-supported) — [GitHub API](https://api.github.com/repos/vashpan/xcode-dev-cleaner), [README](https://github.com/vashpan/xcode-dev-cleaner)
- It cleans 6 categories: Device Support, Archives, Derived Data, Documentation Cache, Old Simulator & Device Logs, and Old Documentation Downloads. There is no CLI mentioned — [README](https://github.com/vashpan/xcode-dev-cleaner)
- Missing ecosystems and requests: simulator removal is open since 2021 ([#21](https://github.com/vashpan/xcode-dev-cleaner/issues/21)), and the CoreSimulator dyld cache is open since 2024 ([#48](https://github.com/vashpan/xcode-dev-cleaner/issues/48))

**dev-cleaner (jemishavasoya/dev-cleaner)**
- 359 stars, pushed 2026-09-07. Bash script plus a Homebrew tap. It covers Xcode, Flutter (including FVM), Visual Studio, Gradle, npm, NuGet, IDE, browser caches, and old Claude Code binaries in `~/.local/share/claude/versions` (~190 MB per release) — [GitHub search API](https://api.github.com/search/repositories?q=dev-cleaner+in:name), [README](https://raw.githubusercontent.com/jemishavasoya/dev-cleaner/main/README.md)

**Other tools**
- **cargo-sweep (holmgr/cargo-sweep):** 1,004 stars, MIT, pushed 2026-05-26. A cargo subcommand for "cleaning up unused build files generated by Cargo" — [GitHub search API](https://api.github.com/search/repositories?q=cargo-sweep+in:name)
- **cargo-cache (matthiaskrgr/cargo-cache):** 996 stars, last push 2023-06-04, so effectively dormant — [GitHub API](https://api.github.com/repos/matthiaskrgr/cargo-cache)
- **mac-cleanup-py (mac-cleanup/mac-cleanup-py):** 2,375 stars, Apache-2.0, pushed 2026-10-30. The older **mac-cleanup-sh** has 2,812 stars, MIT, and is marked DEPRECATED (last push 2023-05-21) — [GitHub API py](https://api.github.com/repos/mac-cleanup/mac-cleanup-py), [GitHub API sh](https://api.github.com/repos/mac-cleanup/mac-cleanup-sh)
- **trash-cli (andreafrancia/trash-cli):** 4,622 stars, GPL-2.0, active. It implements the FreeDesktop trash spec, which is Linux-centric — [GitHub API](https://api.github.com/repos/andreafrancia/trash-cli)
- **ClearDisk (bysiber/cleardisk):** 754 stars, MIT, pushed 2026-09-10. A menu-bar app covering Xcode, node_modules, CocoaPods, SPM, Docker, pip, and Cargo — [GitHub API](https://api.github.com/repos/bysiber/cleardisk)
- **MegaCleaner:** free, closed source. Its site claims 39 developer scanners and 148 sub-features across languages, dev tools (Xcode, Docker, Git, Homebrew, Kubernetes), IDEs (VS Code, JetBrains), and system areas — [megacleaner.app](https://megacleaner.app/)
- **Small newer entrants:** mac-dev-cleaner-cli (11 stars, TUI and GUI) — [repo](https://github.com/thanhdevapp/mac-dev-cleaner-cli); clean-my-mac (2 stars, "staged cleanup for devs & AI agents", dry-run first) — [repo](https://github.com/shihabshahrier/clean-my-mac); macOS-dev-cache-cleaner (49 stars, menu bar) — [GitHub search API](https://api.github.com/search/repositories?q=dev-cleaner+in:name); DevClean ("skips anything it cannot prove is junk") — [HN 49541885](https://news.ycombinator.com/item?id=49541885); and commercial CodeCleaner, DevClean.app, and DreamDisk — [code-cleaner.com](https://code-cleaner.com/), [devclean.app](https://devclean.app/)
- **Colima (abiosoft/colima):** 31,569 stars, MIT, pushed 2026-10-13. Listed as relevant context for the container-runtime disk question — [GitHub API](https://api.github.com/repos/abiosoft/colima)

**Native and first-party cleanup commands**
- **Xcode / simctl:**
  - `xcrun simctl delete unavailable` removes simulators whose runtimes are missing
  - `xcrun simctl list runtimes` lists runtimes
  - Runtimes can be removed in System Settings > General > Storage > Developer, or in Xcode Settings > Platforms ("Other Installed Platforms") — [Apple Developer Forums thread 773153](https://developer.apple.com/forums/thread/773153) (community posts, not Apple staff)
  - Each runtime is a large .dmg under /Library/Developer/CoreSimulator/Volumes — [Apple forum 812992](https://developer.apple.com/forums/thread/812992)
  - Orphaned runtimes can remain under SIP-protected /System/Library/AssetsV2, where Xcode and simctl cannot cleanly remove them (about 9 GB in that report). `xcrun simctl runtime scan-and-mount` was suggested — [Apple forum 812992](https://developer.apple.com/forums/thread/812992)
- **Hugging Face:** The current CLI is `hf cache ls` (with filters such as `size>1GB` and `accessed>30d`, and `--format json`), `hf cache rm` (repo, revision, or a single `hf://` file), `hf cache prune` (detached revisions, `.incomplete` files, unreferenced shared Xet blobs), and `hf cache verify`, all with `--dry-run`. The cache lives at `~/.cache/huggingface/hub`, and the Xet shard cache at `~/.cache/huggingface/xet` has a 16 GB soft limit. HF writes a `CACHEDIR.TAG` file. The older `huggingface-cli delete-cache` name has been superseded by the `hf` CLI — [HF manage-cache docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)
- **Other ecosystem commands** (docs not fetched this session):
  - Docker: `docker system prune [-a] [--volumes]` and `docker builder prune` — [Docker docs: pruning](https://docs.docker.com/engine/manage-resources/pruning/)
  - pnpm: `pnpm store prune` — [pnpm docs](https://pnpm.io/cli/store)
  - uv: `uv cache prune` / `uv cache clean` — [uv cache docs](https://docs.astral.sh/uv/concepts/cache/)
  - Homebrew: `brew cleanup [--prune=N]` — [brew manpage](https://docs.brew.sh/Manpage)
  - conda: `conda clean --all` — [conda docs](https://docs.conda.io/projects/conda/en/latest/commands/clean.html)
  - Ollama: `ollama list` / `ollama rm` — [Ollama CLI docs](https://github.com/ollama/ollama/blob/main/docs/cli.md)

### Inferences
- Mole is the de facto reference rule set for the macOS developer-cache domain. Its function-per-ecosystem layout is a ready-made taxonomy for a rules knowledge base, but it is GPL-3.0, so copying its rules into a differently-licensed project needs care.
- The ML-model category (HF hub, Ollama `~/.ollama/models`, LM Studio, pip and torch caches) is a clear coverage gap among the general cleaners. These are also often the largest single items.
- The project-artifact cleaners point to two detection strategies. A rules KB should support both "dir name" rules (npkill, Mole) and "marker file + dir" rules (kondo, clean-dev-dirs). Marker-file rules are safer, for example avoiding deletion of a `bin/` or `vendor/` that is not a build artifact.

### Gaps
- An exact Mole "rule count" isn't defined anywhere. The ~57 functions, 207 call sites, and 34 purge targets above are my counts from source.
- I did not fetch kondo's per-type artifact directory lists (they are in `kondo-lib/src/lib.rs`).
- I did not fetch Docker, pnpm, uv, brew, conda, Ollama, or Gradle docs this session. The citations above are canonical doc URLs from prior knowledge.
- I found no dedicated, maintained tools for JetBrains caches or VS Code/Cursor extension caches beyond Mole's JetBrains logs/Toolbox functions and MegaCleaner's IDE scanners.
- I found no dedicated Gradle/Maven cache cleaner of note. Mole has Gradle daemon/build-cache logic and, since v1.27, a Maven local repo rule ([tw93 on X](https://x.com/HiTw93/status/2025424790467871149)).

## Q2. Do any tools estimate rebuild cost, check running processes, or use native cleanup commands instead of rm -rf?

### Takeaway
No tool found estimates rebuild cost, whether as time, bandwidth, or a "cost" tier. MegaCleaner shows regeneration commands, which comes closest. Mole is the strongest on process-awareness and native commands. Most project-artifact cleaners are effectively `rm -rf` with a prompt; clean-dev-dirs and MegaCleaner default to Trash instead.

### Cited Findings
- **Mole process checks (pgrep):**
  - It skips pnpm when pnpm is busy, and checks uv/uvx, bun/bunx, and gh
  - It checks whether Xcode, Simulator, xcodebuild, xctest, XCTRunner, or simctl is running, and whether any simulator is booted (`simctl list devices booted -j`), before touching CoreSimulator
  - It checks Gradle daemon state, and skips Gradle targets when "process state unknown"
  - It protects node_modules with open files (for example a dev server whose cwd is inside it)
  - [dev.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh), [project.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/project.sh)
- **Mole native commands:**
  - `npm cache clean --force`, `bun pm cache rm`, `go clean -cache` / `-modcache`, and `conda clean --yes --index-cache --tarballs --logfiles`
  - `docker builder prune -f --filter until=168h` and `docker image prune -f`
  - `brew cleanup`
  - It resolves configured cache paths (`npm config get cache`, CARGO_HOME, RUSTUP_HOME)
  - For orphaned simulator runtimes it only suggests `xcrun simctl runtime delete <id>` and does not run it
  - [dev.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/dev.sh)
- **Mole deletion and safety:**
  - `clean`, `purge`, and `installer` delete permanently, while `uninstall`, `analyze`, and `slim` move to Trash
  - It offers `--dry-run`, a plain-text whitelist at `~/.config/mole/whitelist`, and an operations log at `~/Library/Logs/mole/operations.log` (`mo history`)
  - Purge leaves artifacts with activity in the last 7 days unselected by default, and protects nested git repos and git-tracked files
  - [README](https://github.com/tw93/Mole)
- **kondo:** the README calls itself "essentially `rm -rf` with a prompt" and advises "Always have a backup" — [README](https://github.com/tbillington/kondo)
- **npkill:** flags dirs that installed apps may need with ⚠️, and `-x` excludes sensitive dirs. The README does not say whether deletion is permanent — [README](https://github.com/voidcosmos/npkill)
- **clean-dev-dirs:** moves to Trash by default, with `--permanent` to delete outright. Also offers `--keep-days`, `--keep-size`, `--dry-run`, `--interactive`, and `--keep-executables` (copies Rust and Python binaries out before cleaning) — [README](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md)
- **MegaCleaner:** "Safe move-to-Trash cleaning". It shows regeneration commands but does not estimate rebuild cost — [megacleaner.app](https://megacleaner.app/)
- **HF `hf cache rm`/`prune`:** computes the expected freed size before execution via `DeleteCacheStrategy`, and handles shared blobs safely, keeping a blob still referenced elsewhere — [HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)
- **DevCleaner:** warns that it relies on undocumented Xcode folder structures that may break with new Xcode versions — [README](https://github.com/vashpan/xcode-dev-cleaner)

### Inferences
- A rebuild-cost field, such as "re-download GBs", "recompile minutes", or "needs network/credentials", would be a genuine differentiator, since nobody does it.
- Mole's process-guard list (Xcode, Simulator, xcodebuild, Gradle daemon, pnpm, uv, bun, open-file checks) is a good seed for a per-rule `blocked_by_processes` field.
- Native commands matter for correctness, not just style: pnpm's content-addressable store, HF's shared blobs, and Docker's VM disk cannot be cleaned safely with rm -rf.

### Gaps
- I did not verify whether npkill deletes to Trash or permanently.
- I did not inspect whether mac-cleanup-py uses native commands. Its README was not fetched.

## Q3. Does any tool use a declarative, community-maintained rules format (YAML/JSON)?

### Takeaway
No tool found uses a community-maintained declarative rules database for developer junk. Rules are hard-coded in Bash (Mole, dev-cleaner) or Rust (kondo, clean-dev-dirs). User config is limited to whitelists, scan roots, and filters, in plain text or TOML. Machine-readable output exists in npkill, clean-dev-dirs, and `hf cache ls`, but there is no rules input format.

### Cited Findings
- **Mole:** rules are Bash functions in `lib/clean/*.sh`, and purge targets are a Bash array. User-facing config is plain-text files (`~/.config/mole/whitelist`, `~/.config/mole/purge_paths`) plus `MOLE_TIMEOUT_*` env vars — [README](https://github.com/tw93/Mole), [purge_shared.sh](https://raw.githubusercontent.com/tw93/Mole/main/lib/clean/purge_shared.sh)
- **clean-dev-dirs:** TOML config at `~/.config/clean-dev-dirs/config.toml` with `[filtering]`, `[scanning]`, and `[execution]` sections. It only configures filters; project types are built in. `--json` output includes per-type summaries — [README](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md)
- **npkill:** profiles are defined in the codebase and documented in a separate profiles doc. `--json` and `--json-stream` give output — [README](https://github.com/voidcosmos/npkill)
- **kondo:** project types are defined in Rust in `kondo-lib/src/lib.rs` — [README](https://github.com/tbillington/kondo)
- **Hugging Face:** writes `CACHEDIR.TAG` per the Cache Directory Tagging Standard ([bford.info/cachedir](https://bford.info/cachedir/)) so backup tools can skip it. This is a cross-tool "this is a cache" signal a scanner could honor — [HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)

### Inferences
- A YAML/JSON community rules KB would be novel in this space. The closest prior art to borrow structure from:
  - clean-dev-dirs' marker→target mapping
  - Mole's per-ecosystem functions, process guards, and native commands
  - npkill's profiles
  - The CACHEDIR.TAG standard, for automatic detection
- The many confirmed Mole data-loss bugs (Q5) argue that each rule should carry explicit, reviewable fields: owner, path glob, native command, process guard, safety tier, and rebuild cost. Logic buried in a 6,000-line shell script is hard for the community to audit.

### Gaps
- I did not survey non-dev cleaners such as BleachBit's CleanerML (XML) as format prior art. It is out of scope but likely relevant.

## Q4. What sizes do users report reclaiming, by category?

### Takeaway
Quantitative anecdotes cluster at 50–150 GB total on developer Macs. Xcode (runtimes plus DeviceSupport plus DerivedData) and Docker's VM disk are the biggest categories. Most figures come from vendor blogs, not independent measurement, so treat them as marketing-grade.

### Cited Findings
- **Xcode DeviceSupport:** about 2–5 GB per iOS version, and Xcode caches can total tens of GB — [DevCleaner README](https://github.com/vashpan/xcode-dev-cleaner)
- **Simulator runtimes:** 5–8 GB each (third-party blog) — [search summary of ClearDisk blog](https://bysiber.github.io/cleardisk/blog/xcode-simulators-device-support-cleanup-mac.html). One orphaned runtime of about 9 GB stuck in /System/Library/AssetsV2 — [Apple forum 812992](https://developer.apple.com/forums/thread/812992)
- **Xcode wipe-and-reinstall:** a community post reports freeing "about 80%" of disk (anecdotal, drastic) — [Apple forum 773153](https://developer.apple.com/forums/thread/773153)
- **Docker VM disk:** can grow past 100 GB — [cleanwithcrumb 2026 roundup](https://cleanwithcrumb.com/blog/best-mac-cleaner-for-developers-2026/). One user saw a 60 GB apparent vs 31 GB actual Docker.raw (ls vs du) — [Docker forums](https://forums.docker.com/t/trouble-downsizing-docker-raw-using-docker-desktop/138443). "Reclaiming 20–50GB" from Docker is claimed in a DEV post title — [dev.to](https://dev.to/nixeton/docker-ate-your-disk-reclaiming-20-50gb-on-macos-4k86)
- **Docker.raw caveat:** prune frees space inside the VM, not on the host. Shrinking requires lowering the disk-size slider or a reclaim step, and users report the size limit being ignored and a 34 GB file reappearing — [Docker forums 147964](https://forums.docker.com/t/docker-desktop-mac-ignoring-the-disk-usage-limit-i-specified-in-settings-resources/147964), [Docker forums 138443](https://forums.docker.com/t/trouble-downsizing-docker-raw-using-docker-desktop/138443)
- **OrbStack:** `data.img` is an 8 TB sparse file that "automatically shrinks when you delete data", so no manual compaction is needed — [OrbStack FAQ](https://docs.orbstack.dev/faq)
- **Totals across categories:**
  - "Reclaim 50–100GB" — [dev.to/nixeton](https://dev.to/nixeton/your-dev-tools-are-why-your-mac-is-full-heres-how-to-reclaim-50-100gb-3n8b)
  - "Free 50–150GB" from Xcode and Docker — [deepcleanmac](https://deepcleanmac.com/blog/clean-xcode-docker-dev-cache-mac)
  - "Reclaim 50–150 GB" Xcode guide — [dev.to/pyrx_tech](https://dev.to/pyrx_tech/the-complete-xcode-cleanup-guide-for-iosmacos-developers-reclaim-50-150-gb-2026-2h5j)
  - "Free 50GB+" — [ClearDisk blog](https://bysiber.github.io/cleardisk/blog/free-disk-space-mac-developer). All of these are vendor or self-promotional.
- **ML models:** a single GGUF quantization can be 16.5 GB, and a two-repo bulk delete freed 5.31 GB (documentation examples) — [HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)
- **Mole's illustrative outputs:** clean 4.5 GB, purge about 6 GB, installers 3.83 GB (README samples, not benchmarks) — [README](https://github.com/tw93/Mole). The maintainer markets "free up tens of GBs in one go" — [tw93 on X](https://x.com/HiTw93/status/2025424790467871149)
- **Misreported sizes:** Mole reported 2.98 GB freed while free space rose from 69 GB to 88 GB, and differed from System Settings by about 7 GB — [Mole #1023](https://github.com/tw93/Mole/issues/1023). npkill's README admits size calculations can be too high — [README](https://github.com/voidcosmos/npkill)

### Inferences
- Estimates should be measured as allocated size (du), not apparent size, and should account for APFS clones, purgeable space, and snapshots. Otherwise "freed" numbers will disagree with Finder or System Settings, which is a recurring complaint.
- The rough order of magnitude for tiering defaults is: Docker VM 20–100+ GB, Xcode runtimes and DeviceSupport 10–50+ GB, ML models multiple GB each, and node_modules from hundreds of MB to tens of GB in aggregate.

### Gaps
- I found no independent, survey-style data, and no strong Reddit or HN threads with many user-reported numbers. HN posts for npkill, kondo, Mole, and DevCleaner all had under 5 points ([HN Algolia results](https://hn.algolia.com/api/v1/search?query=npkill&tags=story)).
- I did not retrieve a sourced per-user aggregate for node_modules or for Ollama.

## Q5. What are the GitHub stars, activity, licenses, and complaints?

### Takeaway
Mole dominates attention (74k stars, releasing daily) but has a documented history of deleting user data that was not junk: Claude Code memory, LaunchAgents, and printers. Its issues were fixed reactively. kondo is slower-moving, with detection bugs. DevCleaner lags Xcode changes. A safety-first, rules-reviewed design addresses the main complaint category.

### Cited Findings

| Tool | Stars | License | Last push | Notes |
|---|---|---|---|---|
| Mole | 74,274 | GPL-3.0 | 2026-11-08 (V1.70.0) | — |
| npkill | 9,501 | MIT | 2026-11-08 | — |
| trash-cli | 4,622 | GPL-2.0 | 2026-11 | — |
| mac-cleanup-sh | 2,812 | MIT | 2023 | deprecated |
| kondo | 2,584 | MIT | 2026-04 | — |
| mac-cleanup-py | 2,375 | Apache-2.0 | 2026-10 | — |
| DevCleaner | 1,620 | GPL-3.0 | 2026-05 | — |
| cargo-sweep | 1,004 | MIT | 2026-05 | — |
| cargo-cache | 996 | — | 2023 | — |
| ClearDisk | 754 | MIT | 2026-09 | — |
| dev-cleaner | 359 | — | 2026-09 | — |
| clean-dev-dirs | 21 | Apache/MIT | 2026-06 | — |

Sources: [GitHub API](https://api.github.com/repos/tw93/Mole) (queried per repo)

- **Mole star-count skepticism:** one AlternativeTo commenter questioned "23k stars without suspicious activity" (single unverified opinion) — [AlternativeTo](https://alternativeto.net/software/mole/about)
- **Mole data-loss and over-deletion bugs (all now closed):**
  - `mo clean` permanently unlinked `~/.claude/projects/*/memory/` (Claude Code persistent memory) across 8 projects, with no Trash and no recovery — [#823](https://github.com/tw93/Mole/issues/823)
  - It deleted a user-created `~/Library/LaunchAgents/environment.plist` — [#582](https://github.com/tw93/Mole/issues/582)
  - It deleted saved printers (v1.34.0, macOS 26.4.1) — [#731](https://github.com/tw93/Mole/issues/731)
  - `mo uninstall` destroyed same-named CLI data via an XDG dotdir heuristic (Claude Code, opencode) — [#993](https://github.com/tw93/Mole/issues/993)
  - Potential removal of Codex project conversation history — [#913](https://github.com/tw93/Mole/issues/913)
  - Uninstall targeted a Sparkle file belonging to another app — [#1133](https://github.com/tw93/Mole/issues/1133)
- **kondo issues:**
  - "Kondo no longer detecting projects" (2025, open) — [#175](https://github.com/tbillington/kondo/issues/175)
  - Unity misidentification — [#149](https://github.com/tbillington/kondo/issues/149)
  - "Directory not empty" deletion errors — [#97](https://github.com/tbillington/kondo/issues/97)
  - `kondo .` fails inside $HOME — [#55](https://github.com/tbillington/kondo/issues/55)
- **npkill:** a request to handle pnpm's `node_modules/.ignored` separately — [#220](https://github.com/voidcosmos/npkill/issues/220). The UI can block while deleting — [README](https://github.com/voidcosmos/npkill)
- **DevCleaner:** "DevCleaner says I have Zero KB of device support" (Nov 2025, open, likely a path change in newer Xcode) — [#59](https://github.com/vashpan/xcode-dev-cleaner/issues/59). Simulator removal is still not supported — [#21](https://github.com/vashpan/xcode-dev-cleaner/issues/21)
- **dev-cleaner:** its Flutter cleanup removes `pubspec.lock` and `ios/Podfile.lock`. These are lockfiles, often committed, not build artifacts — [README](https://raw.githubusercontent.com/jemishavasoya/dev-cleaner/main/README.md)
- **HF cache tooling:** older third-party cache-deletion tools "may delete a shared file still used by other repos" under the new Xet shared-blob layout — [HF docs](https://huggingface.co/docs/huggingface_hub/guides/manage-cache)

### Inferences
- The dominant failure mode is heuristic matching on directories that look like cache or app data but hold user state. Examples are `~/.claude/projects/*/memory`, LaunchAgents, printers, and lockfiles. AI-agent dotdirs (`~/.claude`, `~/.codex`, `~/.cursor`) are a new high-risk zone that mixes caches with irreplaceable state. A rules KB should allowlist specific subpaths rather than whole dotdirs.
- Permanent deletion by default (Mole `clean`, kondo) plus overnight unattended runs turned bugs into unrecoverable loss. Trash-by-default (clean-dev-dirs, MegaCleaner) or a quarantine step should be the norm.

### Gaps
- I found no complaints data for mac-cleanup-py, cargo-sweep, or ClearDisk; their issues were not reviewed.
- **Project-aware stale detection:**
  - Mole uses file-activity age (7 days, with labels such as "28d" and "2mo") — [README](https://github.com/tw93/Mole)
  - kondo, npkill, and clean-dev-dirs use modification time (`--older`, `--older-than`, `--keep-days`) — [kondo](https://github.com/tbillington/kondo), [npkill](https://github.com/voidcosmos/npkill), [clean-dev-dirs](https://docs.rs/crate/clean-dev-dirs/latest/source/README.md)
  - MegaCleaner flags projects "untouched for 30+ days" without saying how it measures this — [megacleaner.app](https://megacleaner.app/)
  - I found no tool that explicitly uses the last git commit date for staleness. Mole only uses git to protect tracked files and nested repos.
  - "Projectlens" (HN, 2026-06) mentions npkill support but was not investigated — [HN 48668309](https://news.ycombinator.com/item?id=48668309)
