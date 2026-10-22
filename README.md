# Cleany 🧹✨

> **The 100% Local, Privacy-by-Design, Free & Open-Source macOS Cleaner.**  
> Zero Telemetry • Zero Daemons • Zero Subscriptions • Built in Swift 6 & SwiftUI.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)](https://swift.org)
[![Privacy](https://img.shields.io/badge/Telemetry-0%25%20(Local%20Only)-success)](#privacy--security-by-design)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Why Cleany?

Commercial Mac cleaners (such as CleanMyMac) are proprietary, charge costly annual subscriptions (\$39.95+/yr), install persistent background root helpers and daemons (`com.macpaw.CleanMyMac5.Agent`), and transmit analytics across third-party trackers.

**Cleany is the open-source answer:**
- 🛡️ **100% Local & Privacy-First:** Outgoing and incoming network access is cryptographically disabled in `Cleany.entitlements`. No analytics, no pings, no servers.
- ⚡ **Zero Background Daemons:** Cleany only runs when you ask it to. No persistent launch agents, no memory hogs in your menu bar.
- 🗑️ **Safe by Default:** Items are moved to the native macOS Trash (`FileManager.trashItem`) so accidental deletions can always be undone with `⌘Z`. Critical system paths are strictly guarded.
- 🤖 **Next-Gen AI Clutter Detection:** Inspired by reverse-engineering CleanMyMac 5's newest scanning frameworks (`AIToolScanning`, `LocalModelScanning`), Cleany automatically cleans gigabytes of orphaned artifacts from **Claude Code**, **Cursor Agent**, **OpenCode**, **Ollama**, **LM Studio**, and **HuggingFace**.
- 🛠️ **Developer Friendly:** Cleans DerivedData, SPM caches, npm/pnpm/yarn, Cargo targets, and Gradle build trees in seconds. Includes a standalone CLI tool (`cleany`) for terminal power users and automation scripts.

---

## Comparison: Cleany vs. CleanMyMac 5

| Feature | Cleany (Open Source) | CleanMyMac 5 (Proprietary) |
| :--- | :---: | :---: |
| **License** | **Free & Open Source (MIT)** | \$39.95 / year subscription |
| **Telemetry & Analytics** | **0 bytes (Disabled via Entitlements)** | Mixpanel, Amplitude, GTM Proxy |
| **Background Daemons** | **None (Zero overhead when closed)** | Root helper daemon + LaunchAgents |
| **AI Tool Clutter** *(Claude, Cursor, OpenCode)* | ✅ Yes | ✅ Yes |
| **Local LLM Models** *(Ollama, LM Studio, HuggingFace)*| ✅ Yes | ✅ Yes |
| **Developer Artifacts** *(DerivedData, npm, Cargo)* | ✅ Yes | Limited |
| **System Caches & Diagnostic Logs** | ✅ Yes | ✅ Yes |
| **App Leftovers & Orphaned Containers** | ✅ Yes | ✅ Yes |
| **System Maintenance Tasks** *(DNS, RAM, APFS, Mail)* | ✅ Yes | ✅ Yes |
| **Visual Disk Lens ("SpaceLens")** | ✅ Yes | ✅ Yes |
| **Command Line Interface (CLI)** | ✅ Full-featured CLI (`cleany`) | ❌ None |
| **Deletion Safety** | **macOS Trash (`⌘Z` Undoable)** | Permanent Deletion / Custom Helper |

---

## Modules & Capabilities

### 1. Smart Care & Scanners
- **AI Clutter (`AIScanner`):** Scans for cached prompt logs, agent intermediate outputs, and gigabytes of orphaned GGUF / model checkpoints (`~/.claude/projects`, `~/.cursor`, `~/.cache/opencode`, `~/.ollama/models`, `~/.cache/lm-studio`, `~/.cache/huggingface`).
- **Developer Artifacts (`DeveloperScanner`):** Deep cleans Xcode DerivedData, Archives, SPM caches, CocoaPods, npm, pnpm, Cargo build target folders, and Gradle caches.
- **System Junk (`SystemJunkScanner`):** Removes stale user cache files (`~/Library/Caches`), user logs (`~/Library/Logs`), and Apple crash diagnostics.
- **App Leftovers (`AppLeftoversScanner`):** Identifies orphaned remnants left behind in `~/Library/Application Support` and `~/Library/Containers` after applications have been uninstalled.
- **Trash Bins (`TrashBinsScanner`):** Safely computes and purges user trash across volumes.

### 2. System Maintenance (`MaintenanceRunner`)
- **Flush DNS Cache:** Reloads `mDNSResponder` and purges directory service caches.
- **Purge Inactive RAM:** Reclaims memory cached by inactive processes.
- **Thin Time Machine Snapshots:** Uses APFS snapshot pruning (`tmutil thinlocalsnapshots`) to recover gigabytes of purged disk space without losing backups.
- **Reindex Spotlight:** Triggers `mdimport -r` to fix broken Spotlight search indexing.
- **Speed Up Apple Mail:** Runs SQLite `VACUUM` on Apple Mail `Envelope Index` databases to eliminate mailbox bloat.

### 3. SpaceLens Disk Visualizer
- Recursive, high-performance disk analyzer that visualizes disk usage across subdirectories, sorted by size with human-readable formatting and direct Finder integration.

---

## Installation & Usage

### Option A: Native macOS App (`Cleany.app`)

1. Build and bundle the app:
   ```bash
   ./scripts/bundle_app.sh
   ```
2. Launch directly:
   ```bash
   open dist/Cleany.app
   ```
3. Or install to your `/Applications` directory:
   ```bash
   cp -R dist/Cleany.app /Applications/
   ```

### Option B: Terminal CLI (`cleany`)

Build the CLI binary:
```bash
swift build -c release
sudo cp .build/release/cleany /usr/local/bin/cleany
```

#### Run a system scan:
```bash
cleany scan
```
*Output preview:*
```
🔍 Starting Cleany system scan...
  [AI Tools & Models] Found 4 items (3.20 GB)
  [Developer Artifacts] Found 12 items (5.40 GB)
  [System Junk] Found 38 items (820.5 MB)
  [App Leftovers] Found 14 items (148.0 MB)
  [Trash Bins] Found 3 items (5.2 MB)

==================================================
Total Reclaimable Space: 9.57 GB (71 items)
==================================================
```

#### Clean with Safe Trash Default:
```bash
# Dry run first
cleany clean --dry-run

# Clean AI clutter only
cleany clean --category ai

# Clean all categories (moves to macOS Trash for safety)
cleany clean

# Permanent deletion (bypasses Trash)
cleany clean --permanent
```

#### Run Maintenance Tasks:
```bash
# List available maintenance tasks
cleany maintenance list

# Run specific tasks
cleany maintenance run flush-dns
cleany maintenance run purge-ram
cleany maintenance run thin-time-machine
```

---

## Privacy & Security by Design

Cleany enforces privacy at both the compile-time and code-signing layers:

1. **Explicit Zero-Network Entitlements:**
   ```xml
   <key>com.apple.security.network.client</key>
   <false/>
   <key>com.apple.security.network.server</key>
   <false/>
   ```
   macOS kernel-level enforcement guarantees that the application cannot initiate or accept any network sockets.

2. **Guarded Path Invariants:**
   `FileUtilities.isSafeToDelete(path:)` prevents deletion of:
   - Root filesystem (`/`, `/System`, `/usr`, `/bin`, `/sbin`, `/Applications`)
   - User home directory root (`~`)
   - Personal user documents (`~/Desktop`, `~/Documents`, `~/Downloads`, `~/Pictures`, `~/Music`)

3. **Reversible Trash Defaults:**
   Deletions invoke `FileManager.default.trashItem(at:resultingItemURL:)` rather than `removeItem(at:)`. You can restore any cleaned file at any time from the native macOS Trash.

---

## Building & Developing

### Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15+ or macOS Command Line Tools with Swift 6.0

### Run Tests
```bash
swift test
```

### Build Everything
```bash
swift build
```

---

## Architecture

```
cleany/
├── Sources/
│   ├── CleanyCore/              # Reusable engine & domain framework
│   │   ├── Models/              # JunkCategory, JunkItem, ScanProgress, CleanResult
│   │   ├── Scanners/            # AIScanner, DeveloperScanner, SystemJunkScanner, etc.
│   │   ├── Maintenance/         # MaintenanceRunner (DNS, RAM, APFS, Mail)
│   │   └── Engine/              # SafeDeletionManager, FileUtilities, SpaceLensScanner
│   ├── CleanyCLI/               # Command-line interface executable (cleany)
│   └── CleanyApp/               # SwiftUI macOS Application
│       ├── Components/          # ScanningGaugeView, MetricCardView, JunkRowView
│       ├── Views/               # DashboardView, CategoryDetailView, SpaceLensView, etc.
│       └── State/               # AppState (ObservableObject)
├── Tests/
│   └── CleanyCoreTests/         # Swift Testing suite
├── scripts/
│   ├── bundle_app.sh            # Packages, signs & verifies Cleany.app
│   └── generate_icon.py         # Generates multi-res Apple AppIcon.icns
├── Cleany.entitlements          # Zero-telemetry security profile
└── Package.swift                # Swift Package Manager definition
```

---

## Contributing

Contributions, bug reports, and pull requests are welcome! If you want to add support for a new AI framework, developer cache, or maintenance task:
1. Fork the repo and create a feature branch.
2. Implement your scanner under `Sources/CleanyCore/Scanners/` conforming to `JunkScanner`.
3. Add unit tests under `Tests/CleanyCoreTests/`.
4. Submit a Pull Request.

---

## License

Cleany is distributed under the [MIT License](LICENSE).  
Copyright © 2026 Woadlab & Cleany Contributors.
