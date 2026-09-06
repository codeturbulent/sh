#!/bin/bash
# ==============================================================================
#  ULTIMATE FLUTTER & ANDROID SETUP SCRIPT (ARCH LINUX)
#  - Installs OpenJDK 17, Flutter Stable, Android SDK (cmdline-tools)
#  - Configures paths & environment variables
#  - Applies Gradle memory fixes for low-RAM environments
#  - Handles network retries and idempotency
# ==============================================================================
set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success(){ echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_internet() {
  log_info "Checking internet connectivity..."
  if ping -q -c 1 -W 1 archlinux.org >/dev/null 2>&1 || ping -q -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
    log_success "Internet available."
  else
    log_error "No internet connection detected."
  fi
}

ensure_dir() {
  [ -d "$1" ] || { mkdir -p "$1"; log_info "Created: $1"; }
}

download_file() {
  local url=$1 dest=$2 retries=${3:-3} count=0
  while [ $count -lt $retries ]; do
    curl -fsSL "$url" -o "$dest" && return 0
    count=$((count+1))
    log_warn "Download failed. Retry $count/$retries..."
    sleep 2
  done
  log_error "Failed to download $url after $retries attempts."
}

# Defaults / paths
HOME_DIR="$HOME"
ANDROID_ROOT="$HOME_DIR/Android/Sdk"
FLUTTER_ROOT="$HOME_DIR/flutter"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
AUR_HELPER="yay"

log_info "Starting Flutter & Android setup for Arch Linux..."

check_internet

# 1) SYSTEM PACKAGES (pacman)
log_info "Updating system and installing dependencies via pacman..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git curl unzip xz zip mesa glu mesa-opencl-icd jdk17-openjdk ninja android-sdk-platform-tools

# Verify Java 17
JAVA_PATH="/usr/lib/jvm/java-17-openjdk"
if [ ! -d "$JAVA_PATH" ]; then
  log_warn "Java 17 path not found at $JAVA_PATH. Checking alternatives..."
  JAVA_PATH="$(readlink -f /usr/lib/jvm/default-java || true)"
  [ -d "$JAVA_PATH" ] || log_error "Java 17 not found. Install jdk17-openjdk and re-run."
fi
log_success "Java 17 available at $JAVA_PATH"

# 2) OPTIONAL: Install AUR helper (yay) if not present
if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
  log_info "Installing AUR helper: $AUR_HELPER"
  ensure_dir "/tmp/$AUR_HELPER-build"
  pushd "/tmp/$AUR_HELPER-build" >/dev/null
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "/tmp/$AUR_HELPER-build"
  log_success "$AUR_HELPER installed."
else
  log_info "AUR helper ($AUR_HELPER) already installed."
fi

# 3) SETUP FLUTTER SDK
if [ -d "$FLUTTER_ROOT" ]; then
  log_info "Flutter directory exists — pulling latest stable..."
  git -C "$FLUTTER_ROOT" pull || log_warn "Failed to update Flutter, continuing with existing copy."
else
  log_info "Cloning Flutter (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_ROOT" || log_error "Failed to clone Flutter."
fi
log_success "Flutter setup present at $FLUTTER_ROOT"

# 4) ANDROID CMDLINE TOOLS
ensure_dir "$ANDROID_ROOT/cmdline-tools"
if [ -d "$ANDROID_ROOT/cmdline-tools/latest" ]; then
  log_info "Android commandline tools already installed."
else
  log_info "Downloading Android commandline tools..."
  ensure_dir "$ANDROID_ROOT/cmdline-tools"
  tmp_zip="$(mktemp --suffix=.zip)"
  download_file "$CMDLINE_TOOLS_URL" "$tmp_zip"
  pushd "$ANDROID_ROOT/cmdline-tools" >/dev/null
  unzip -q "$tmp_zip"
  # Normalize structure: move 'cmdline-tools' or 'tools' into 'latest'
  if [ -d "cmdline-tools" ]; then
    mv cmdline-tools latest || true
  elif [ -d "tools" ]; then
    mv tools latest || true
  fi
  rm -f "$tmp_zip"
  popd >/dev/null
  log_success "Android commandline tools installed."
fi

# 5) ENVIRONMENT (session + persistence)
log_info "Configuring environment variables..."
export JAVA_HOME="$JAVA_PATH"
export ANDROID_HOME="$ANDROID_ROOT"
export PATH="$FLUTTER_ROOT/bin:$PATH:$ANDROID_ROOT/cmdline-tools/latest/bin:$ANDROID_ROOT/platform-tools"

# Idempotent .bashrc/.zshrc update
PROFILE_FILE="$HOME_DIR/.bashrc"
[ -n "${ZSH_VERSION-}" ] && PROFILE_FILE="$HOME_DIR/.zshrc"
sed -i '/# -- FLUTTER SETUP START --/,/# -- FLUTTER SETUP END --/d' "$PROFILE_FILE" || true
cat >> "$PROFILE_FILE" <<EOT
# -- FLUTTER SETUP START --
export JAVA_HOME="$JAVA_PATH"
export ANDROID_HOME="$ANDROID_ROOT"
export PATH="\$PATH:$FLUTTER_ROOT/bin:$ANDROID_ROOT/cmdline-tools/latest/bin:$ANDROID_ROOT/platform-tools"
# -- FLUTTER SETUP END --
EOT
log_success "Environment variables appended to $PROFILE_FILE"

# 6) Ensure sdkmanager is available (from cmdline-tools)
if ! command -v sdkmanager >/dev/null 2>&1; then
  # sdkmanager may be under cmdline-tools/latest/bin
  if [ -x "$ANDROID_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
    export PATH="$ANDROID_ROOT/cmdline-tools/latest/bin:$PATH"
  else
    log_error "sdkmanager not found. Ensure cmdline-tools installed correctly."
  fi
fi

# 7) Install Android SDK components (accept licenses)
log_info "Installing Android SDK components..."
yes | sdkmanager --sdk_root="$ANDROID_ROOT" "platform-tools" \
  "platforms;android-34" "platforms;android-36" \
  "build-tools;34.0.0" "build-tools;28.0.3" || log_error "Failed to install SDK components."
log_success "Android SDK components installed."

# 8) FLUTTER CONFIG
log_info "Configuring Flutter..."
"$FLUTTER_ROOT/bin/flutter" config --no-analytics || log_warn "flutter config failed."
"$FLUTTER_ROOT/bin/flutter" config --android-sdk "$ANDROID_ROOT" || log_warn "flutter config android-sdk failed."
"$FLUTTER_ROOT/bin/flutter" config --jdk-dir "$JAVA_PATH" || log_warn "flutter config jdk-dir failed."

log_info "Accepting Android licenses..."
yes | "$FLUTTER_ROOT/bin/flutter" doctor --android-licenses || log_warn "Android license acceptance may require manual input."

# 9) GRADLE MEMORY FIXS
log_info "Applying Gradle memory limits..."
ensure_dir "$HOME_DIR/.gradle"
cat > "$HOME_DIR/.gradle/gradle.properties" <<EOT
org.gradle.jvmargs=-Xmx1536M -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.daemon=false
org.gradle.parallel=false
EOT
log_success "Gradle properties written."

# 10) FINAL CHECK
echo "=================================================="
log_info "Running flutter doctor..."
"$FLUTTER_ROOT/bin/flutter" doctor -v || log_warn "flutter doctor reported issues."
echo "=================================================="
log_success "SETUP COMPLETE. Run 'source $PROFILE_FILE' or restart your shell to apply environment changes."
echo "=================================================="

exit 0