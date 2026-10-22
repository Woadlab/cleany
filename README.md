# Cleany

> **The 100% Local, Privacy-by-Design macOS Cleaner & Menu Bar Companion.**  
> Zero telemetry &bull; Zero background daemons &bull; Zero subscriptions &bull; 100% Open Source.

[![macOS 15.0+](https://img.shields.io/badge/macOS-15.0%2B%20Sequoia-black?style=flat-square&logo=apple)](https://github.com/Woadlab/cleany)
[![Swift 6](https://img.shields.io/badge/Swift-6.0%2B-F05138?style=flat-square&logo=swift&logoColor=white)](https://github.com/Woadlab/cleany)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%2F%20Intel-blue?style=flat-square)](https://github.com/Woadlab/cleany)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline-707BF5?style=flat-square)](https://github.com/Woadlab/cleany)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

Keeping your Mac fast, clean, and responsive shouldn't require recurring subscription fees, running invasive background helper agents, or transmitting system telemetry to remote servers.

**Cleany** is a native, modern macOS optimizer and disk visualizer built from the ground up in **Swift 6** and **SwiftUI** with Apple Human Interface Guidelines and Liquid Glass aesthetics. It runs 100% on-device, cryptographically disables network access at the entitlement level, and never installs background services.

---

## Installation

### Method 1: One-Line Installer (Terminal cURL)

Install or update Cleany directly to `/Applications` with a single terminal command:

```bash
curl -fsSL https://raw.githubusercontent.com/Woadlab/cleany/main/install.sh | bash
```

This automated script:
1. Verifies your macOS version and architecture (Apple Silicon / Intel).
2. Downloads the latest verified release archive from GitHub.
3. Installs `Cleany.app` directly into `/Applications`.
4. Removes Gatekeeper quarantine attributes.
5. Launches the application.

---

### Method 2: Disk Image (DMG) — Recommended

Download the pre-compiled disk image from GitHub Releases:

👉 **[Download Latest Cleany (DMG)](https://github.com/Woadlab/cleany/releases/latest)** *(or [Cleany.zip](https://github.com/Woadlab/cleany/releases/latest))*

1. Open `Cleany.dmg`.
2. Drag `Cleany` into your **Applications** folder shortcut.
3. Launch `Cleany` from Spotlight or Launchpad.

> **First launch note**: If macOS Gatekeeper displays an unverified developer prompt, right-click (or Control-click) `Cleany.app` &rarr; click **Open**, or allow it under **System Settings &rarr; Privacy & Security &rarr; Open Anyway**.

---

### Method 3: Homebrew Cask

```bash
brew tap woadlab/tap
brew install --cask cleany
```

---

### Method 4: Build from Source

```bash
git clone https://github.com/Woadlab/cleany.git
cd cleany
./build.sh
```

The script compiles the project in Release mode, signs the application bundle with entitlements, and packages `dist/Cleany.app`, `dist/Cleany.dmg`, and `dist/Cleany.zip`.

---

## Architectural Principles & Guarantees

| Capability | Cleany Implementation | Guarantee |
| :--- | :--- | :--- |
| **Privacy & Telemetry** | Network disabled in entitlements (`com.apple.security.network.client = false`) | **0 bytes sent** &bull; 100% Offline |
| **System Overhead** | Zero background daemons, zero launch agents | **0% CPU / 0 MB RAM** when closed |
| **Deletion Safety** | Native macOS Trash via `FileManager.default.trashItem()` | **`⌘Z` Undoable** in Finder at any time |
| **AI Clutter Cleaning** | Deep scans prompt caches and models (Claude, Cursor, OpenCode, Ollama, LM Studio, HF) | Reclaims 10s of GBs of AI context artifacts |
| **Developer Artifacts** | Cleans DerivedData, SPM, CocoaPods, npm/pnpm, Cargo, Gradle | Fast, safe developer cache reclamation |
| **Disk Visualizer** | Space Lens recursive directory analyzer with responsive flow legend | 100% mathematically coherent breakdown |
| **Menu Bar Extra** | Compact, fluid Liquid Glass popover with live telemetry | Quick one-click cleanup from menu bar |
| **Command Line Interface** | Standalone Swift executable (`cleany`) | Terminal power users & CI automation |

---

## Features

### 1. Smart Care
One-click scan and cleanup across five categories of redundant files:
- **Cache & Modelli AI (`AIScanner`)**: Reclaims disk space from cached prompt traces, agent session logs, and local model checkpoints (`~/.claude/projects`, `~/.cursor`, `~/.cache/opencode`, `~/.ollama/models`, `~/.cache/lm-studio`, `~/.cache/huggingface`).
- **Residui Sviluppo (`DeveloperScanner`)**: Deep cleans Xcode DerivedData, Archives, Swift Package Manager caches, CocoaPods, npm/pnpm caches, Cargo build target folders, and Gradle build trees.
- **File di Sistema (`SystemJunkScanner`)**: Safely removes obsolete user cache files (`~/Library/Caches`), user logs (`~/Library/Logs`), and Apple crash diagnostics.
- **Residui Applicazioni (`AppLeftoversScanner`)**: Identifies orphaned folders in `~/Library/Application Support` and `~/Library/Containers` left behind by uninstalled software.
- **Cestino (`TrashBinsScanner`)**: Accurately computes cumulative trash size and item count via Finder scripting, respecting macOS TCC security boundaries.

### 2. Menu Bar Extra Companion
A native, lightweight status bar companion in the macOS menu bar:
- At-a-glance health indicator (Protected / Attention).
- One-click Smart Care cleanup directly from the menu bar.
- Live Cestino weight with immediate "Svuota" action.
- Physical storage gauge for Macintosh HD.
- Quick deep-links to Space Lens, Maintenance, or the main application window.

### 3. Lente Spazio (Space Lens)
A high-performance recursive directory visualizer:
- **Analyzed Directory Bar**: 100% coherent representation of the analyzed folder with zero math discrepancies.
- **Responsive Legend Grid**: Clean multi-column layout without word-wrapping or syllable hyphenation (`LazyVGrid`).
- **Physical SSD Overview**: Separate, dedicated System Settings-style storage platter showing free vs. used capacity on Macintosh HD.
- Direct Finder integration (`Reveal in Finder`) for any discovered folder.

### 4. Manutenzione di Sistema (Maintenance)
Native, zero-daemon system maintenance routines executed locally with standard user privileges:
- **Svuota Cache DNS**: Flushes `mDNSResponder` and local directory service caches.
- **Libera RAM Inattiva**: Reclaims memory cached by inactive processes via native `purge`.
- **Ottimizza Istantanee Time Machine**: Safely thins local APFS snapshots (`tmutil thinlocalsnapshots`).
- **Ricostruisci Indice Spotlight**: Reindexes search metadata (`mdimport -r`).
- **Velocizza Apple Mail**: Performs SQLite `VACUUM` on `Envelope Index` databases to eliminate mailbox lag.

---

## Privacy & Security by Design

Cleany enforces strict security guarantees through its sandbox configuration:

```xml
<!-- Cleany.entitlements -->
<key>com.apple.security.network.client</key>
<false/>
<key>com.apple.security.network.server</key>
<false/>
```

- **0 Network Requests**: Outgoing network traffic is blocked at the OS kernel level.
- **0 Telemetry / Analytics**: No crash reporters, no tracking IDs, no remote analytics.
- **Undoable Deletions**: Files are moved to `~/.Trash` via `FileManager.default.trashItem()`. You can restore any deleted item at any time using `⌘Z` in Finder.

---

## Command Line Interface (CLI)

Cleany includes a standalone command-line tool for terminal workflows:

```bash
# Build the CLI tool
swift build -c release --product cleany

# Run a complete scan
.build/release/cleany scan

# Clean all detected items
.build/release/cleany clean

# Clean a specific category
.build/release/cleany clean --category aiClutter
```

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an Issue.

```bash
git clone https://github.com/Woadlab/cleany.git
cd cleany
swift test
```

---

## License

Cleany is distributed under the **MIT License**. See [LICENSE](LICENSE) for details.  
Copyright &copy; 2026 Woadlab &amp; Cleany Contributors.
