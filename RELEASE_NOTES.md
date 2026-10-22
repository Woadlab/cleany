### Cleany 1.0.0 — 100% Local, Privacy-by-Design macOS Cleaner & Menu Bar Companion

Cleany is the free, open-source alternative to commercial Mac cleaners. Built natively in Swift 6 and SwiftUI with Apple Human Interface Guidelines and Liquid Glass aesthetics, Cleany operates 100% locally with zero telemetry, zero analytics, and zero background daemons.

---

### ✨ Key Features

- **Smart Care**: One-click local analysis and cleanup of safe-to-delete system caches, developer artifacts, application leftovers, and AI agent clutter.
- **AI Tool Clutter & Local Models**: Deep scans and removes gigabytes of orphaned prompt logs, intermediate agent contexts, and local checkpoints from **Claude Code**, **Cursor**, **OpenCode**, **Ollama**, **LM Studio**, and **HuggingFace**.
- **Developer Junk Scanner**: Reclaims tens of gigabytes from Xcode DerivedData, Archives, SPM caches, CocoaPods, npm/pnpm caches, Cargo target directories, and Gradle build trees.
- **System Junk & App Residues**: Identifies stale caches in `~/Library/Caches`, crash diagnostics, and leftover container directories from uninstalled applications.
- **Trash Bins Management**: Computes cumulative trash size across mounted volumes and provides instant, safe emptying with AppleScript and Finder integration.
- **Lente Spazio (Space Lens)**: High-performance recursive directory visualizer with an Apple System Settings-style storage bar, non-hyphenating interactive legend grid, and dedicated physical SSD capacity overview.
- **System Maintenance Tasks**:
  - Flush DNS Cache (`mDNSResponder`)
  - Purge Inactive RAM (`purge`)
  - Thin APFS Time Machine Snapshots (`tmutil thinlocalsnapshots`)
  - Reindex Spotlight (`mdimport -r`)
  - Vacuum Apple Mail Envelope Index databases
- **Menu Bar Extra Companion**: Lightweight menu bar popover for instant health monitoring, at-a-glance trash and disk telemetry, one-click cleanup, and deep links.
- **Full Safety & Privacy**:
  - Deleted files are moved to the native macOS Trash (`FileManager.trashItem`) so actions can always be undone (`⌘Z`).
  - Outgoing network connectivity is cryptographically disabled via entitlements. 0 bytes transmitted.
  - Zero background helper daemons: runs only when you open it.

---

### 📦 Installation

#### Option 1: Quick Install (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/Woadlab/cleany/main/install.sh | bash
```

#### Option 2: Disk Image (DMG) — Recommended
Download **`Cleany.dmg`** from Assets below, open it, and drag `Cleany` to `/Applications`.

#### Option 3: Standalone Archive (ZIP)
Download **`Cleany.zip`** from Assets below, extract it, and move `Cleany.app` to `/Applications`.

#### Option 4: Build from Source
```bash
git clone https://github.com/Woadlab/cleany.git
cd cleany
./build.sh
```

---

### 🛡️ Privacy & Security
- **Entitlements**: `com.apple.security.network.client = false`
- **Telemetry**: 0% (No third-party trackers, no Mixpanel, no Amplitude, no Google Analytics).
- **License**: MIT License (Open Source).
