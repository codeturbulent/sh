# ⚡ codeturbulent / sh

A curated collection of shell scripts, environment setups, and developer automation utilities hosted at **[github.com/codeturbulent/sh](https://github.com/codeturbulent/sh)**.

All scripts in this repository are served directly via GitHub Pages at:
```text
https://codeturbulent.github.io/sh/<script-name>.sh
```

---

## 🚀 Quick Execution Guide

You can run or download any script directly from the web without cloning the repository.

### Option 1: Direct Execution via `curl`

Run directly in your terminal:

```bash
# Run with bash process substitution
bash <(curl -fsSL https://codeturbulent.github.io/sh/pushextension.sh) <appname> "<commit_message>" <version>

# Or pipe into bash with arguments
curl -fsSL https://codeturbulent.github.io/sh/pushextension.sh | bash -s -- <appname> "<commit_message>" <version>
```

### Option 2: Download and Make Executable

Download to your local machine or add to your `$PATH`:

```bash
# Download
curl -fsSL https://codeturbulent.github.io/sh/pushextension.sh -o pushextension.sh

# Make executable
chmod +x pushextension.sh

# Run
./pushextension.sh <appname> "<commit_message>" <version>
```

---

## 📦 Scripts Catalog

| Script | Platform / Target | Description | Direct Access URL |
| :--- | :--- | :--- | :--- |
| [`pushextension.sh`](#pushextensionsh) | Cross-platform | Automated Git commit, zip packaging, and push workflow | `https://codeturbulent.github.io/sh/pushextension.sh` |
| [`flutterinstall.sh`](#flutterinstallsh) | Linux / Codespaces / Ubuntu | Complete Flutter & Android SDK automated installer | `https://codeturbulent.github.io/sh/flutterinstall.sh` |
| [`flutterinstallarch.sh`](#flutterinstallarchsh) | Arch Linux | Flutter & Android SDK installer using `pacman` & `yay` | `https://codeturbulent.github.io/sh/flutterinstallarch.sh` |
| [`fluttermac.sh`](#fluttermacsh) | macOS | Automated Flutter (iOS & Android) setup via Homebrew & Xcode tools | `https://codeturbulent.github.io/sh/fluttermac.sh` |
| [`scrcpymac.sh`](#scrcpymacsh) | macOS (Non-Admin) | Local Scrcpy & ADB setup without requiring `sudo` | `https://codeturbulent.github.io/sh/scrcpymac.sh` |
| [`assignsubs.sh`](#assignsubssh) | Cross-platform | API utility for user subscription plan assignment | `https://codeturbulent.github.io/sh/assignsubs.sh` |
| [`syncwebsite.sh`](#syncwebsitesh) | Cross-platform | Parameter loop and sync utility | `https://codeturbulent.github.io/sh/syncwebsite.sh` |

---

### 1. `pushextension.sh`
Automates staging, creating a formatted git commit, packaging a release `.zip` archive (excluding `.git` and previous releases), and pushing upstream.

```bash
# Quick run:
bash <(curl -fsSL https://codeturbulent.github.io/sh/pushextension.sh) <appname> "<commit_message>" <version>

# Example:
bash <(curl -fsSL https://codeturbulent.github.io/sh/pushextension.sh) myextension "feat: add dark mode" 1.0.4
```

**Parameters:**
- `$1` - Application / extension name (e.g. `myextension`)
- `$2` - Commit message (e.g. `feat: add dark mode`)
- `$3` - Version tag (e.g. `1.0.4`)

Outputs the packaged archive to `release/<appname>_<version>.zip`.

---

### 2. `flutterinstall.sh`
One-click setup for Flutter and Android SDK on Linux systems (Ubuntu, Debian, GitHub Codespaces, Cloud VMs).

**Features:**
- Installs OpenJDK 17 and essential build tools
- Clones and configures Flutter stable branch
- Downloads Android Commandline Tools & Platform Tools
- Automatically accepts Android SDK licenses
- Applies low-RAM Gradle memory optimizations (`gradle.properties`)
- Configures persistent environment variables in `~/.bashrc` and `~/.zshrc`

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/flutterinstall.sh)
```

---

### 3. `flutterinstallarch.sh`
Automated Flutter and Android SDK installation tailor-made for Arch Linux.

**Features:**
- Installs packages via `pacman` and optionally bootstraps `yay`
- Configures OpenJDK 17 (`jdk17-openjdk`), Android SDK 34 & 36
- Installs platform tools and commandline tools
- Sets up environment variables and Gradle memory limits

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/flutterinstallarch.sh)
```

---

### 4. `fluttermac.sh`
Complete setup script for macOS configuring both iOS and Android Flutter environments.

**Features:**
- Installs Homebrew if missing
- Installs Flutter cask and Android Studio
- Configures Android SDK path and platform-tools
- Installs Xcode Command Line Tools and CocoaPods
- Accepts Android and Xcode licenses

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/fluttermac.sh)
```

---

### 5. `scrcpymac.sh`
Local Scrcpy and Android Platform Tools (ADB) installer for non-admin macOS users.

**Features:**
- Installs Homebrew locally in `$HOME/homebrew` without requiring `sudo` privileges
- Configures PATH in `~/.zshrc`
- Installs `scrcpy` and `android-platform-tools` for Android screen mirroring & debugging

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/scrcpymac.sh)
```

---

### 6. `assignsubs.sh`
Helper script sending an authenticated Cloud Function request to assign user subscription plans.

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/assignsubs.sh)
```

---

### 7. `syncwebsite.sh`
Utility loop script for iterating through command line arguments.

```bash
bash <(curl -fsSL https://codeturbulent.github.io/sh/syncwebsite.sh) arg1 arg2
```

---

## 🔒 Security Best Practice

When executing remote scripts via `curl | bash`, it is always recommended practice to review script contents first:

```bash
curl -fsSL https://codeturbulent.github.io/sh/<script-name>.sh | less
```

---

## 📄 License

MIT License. Feel free to use, modify, and distribute.
