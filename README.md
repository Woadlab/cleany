# Cleany

> **The 100% Local, Privacy-by-Design macOS Cleaner & Menu Bar Companion.**  
> Zero telemetry &bull; Zero background daemons &bull; Zero subscriptions &bull; 100% Open Source.

[![macOS 14.0+](https://img.shields.io/badge/macOS-14.0%2B%20Sonoma%20%2F%20Sequoia-black?style=flat-square&logo=apple)](https://github.com/Woadlab/cleany)
[![Swift 6](https://img.shields.io/badge/Swift-6.0%2B-F05138?style=flat-square&logo=swift&logoColor=white)](https://github.com/Woadlab/cleany)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%2F%20Intel-blue?style=flat-square)](https://github.com/Woadlab/cleany)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline-707BF5?style=flat-square)](https://github.com/Woadlab/cleany)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

Commercial Mac cleaners (such as CleanMyMac) are closed-source, charge aggressive annual subscriptions ($39.95+/year), install persistent background root helpers and launch daemons (`com.macpaw.CleanMyMac5.Agent`), and transmit analytics across third-party trackers.

**Cleany** is the modern, open-source alternative built natively in **Swift 6** and **SwiftUI** with Apple Human Interface Guidelines and Liquid Glass aesthetics. It runs 100% on-device, disables network access at the entitlement level, and never installs background services.

---

## Installation

### Method 1: One-Line Installer (cURL)

Install Cleany directly to `/Applications` with a single terminal command:

```bash
curl -fsSL https://raw.githubusercontent.com/Woadlab/cleany/main/install.sh | bash
```

### Method 2: Direct Download (DMG) — Recommended

Download the pre-compiled disk image from GitHub Releases:

👉 **[Download Latest Cleany (DMG)](https://github.com/Woadlab/cleany/releases/latest)** *(or [Cleany.zip](https://github.com/Woadlab/cleany/releases/latest))*

1. Open `Cleany.dmg` and drag `Cleany` to your `/Applications` shortcut.
2. Launch `Cleany` from Spotlight or Launchpad.

> *First launch note: If macOS Gatekeeper displays an unverified developer prompt, right-click (Control-click) `Cleany.app` &rarr; **Open**, or click **Open Anyway** under System Settings &rarr; Privacy & Security.*

### Method 3: Homebrew Cask

```bash
brew tap woadlab/tap
brew install --cask cleany
```

### Method 4: Build from Source

```bash
git clone https://github.com/Woadlab/cleany.git
cd cleany
./build.sh
```

The compiled application and disk image will be generated at `dist/Cleany.app` and `dist/Cleany.dmg`.

---

## Comparison: Cleany vs. CleanMyMac

| Feature | Cleany (Open Source) | CleanMyMac (Proprietary) |
| :--- | :---: | :---: |
| **Pricing** | **Free & Open Source (MIT)** | $39.95 / year subscription |
| **Telemetry & Trackers** | **0 bytes (Disabled via Entitlements)** | Mixpanel, Amplitude, GTM Proxy |
| **Background Daemons** | **Zero (No LaunchAgents, zero memory overhead)** | Root helper daemon + LaunchAgents |
| **AI Tool Clutter** *(Claude, Cursor, OpenCode)* | ✅ Yes | ✅ Yes |
| **Local LLM Checkpoints** *(Ollama, LM Studio, HF)* | ✅ Yes | ✅ Yes |
| **Developer Artifacts** *(DerivedData, SPM, npm, Cargo)* | ✅ Yes | Limited |
| **System Caches & Diagnostic Logs** | ✅ Yes | ✅ Yes |
| **App Leftovers & Orphaned Containers** | ✅ Yes | ✅ Yes |
| **Safe Deletion** | **Native macOS Trash (`⌘Z` Undoable)** | Permanent Deletion / Custom Helper |
| **Space Lens Visualizer** | ✅ Yes (Apple System Settings style) | ✅ Yes |
| **System Maintenance Tasks** *(DNS, RAM, APFS, Mail)* | ✅ Yes | ✅ Yes |
| **Menu Bar Extra Companion** | ✅ Yes (Native SwiftUI popover) | ✅ Yes |
| **Command Line Interface (CLI)** | ✅ Full-featured CLI (`cleany`) | ❌ None |

---

## Features

### 1. Smart Care
One-click scan and cleanup across all five categories of redundant disk files:
- **Cache & Modelli AI (`AIScanner`)**: Reclaims gigabytes from cached prompt traces, agent session logs, and local model checkpoints (`~/.claude/projects`, `~/.cursor`, `~/.cache/opencode`, `~/.ollama/models`, `~/.cache/lm-studio`, `~/.cache/huggingface`).
- **Residui Sviluppo (`DeveloperScanner`)**: Deep cleans Xcode DerivedData, Archives, Swift Package Manager caches, CocoaPods, npm/pnpm caches, Cargo build target folders, and Gradle build trees.
- **File di Sistema (`SystemJunkScanner`)**: Safely removes obsolete user cache files (`~/Library/Caches`), user logs (`~/Library/Logs`), and Apple crash diagnostics.
- **Residui Applicazioni (`AppLeftoversScanner`)**: Identifies orphaned folders in `~/Library/Application Support` and `~/Library/Containers` left behind by uninstalled software.
- **Cestino (`TrashBinsScanner`)**: Accurately computes cumulative trash size and item count via Finder scripting, respecting macOS TCC boundaries.

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
- **0 Telemetry / Analytics**: No crash reporters, no tracking IDs, no remote pings.
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
