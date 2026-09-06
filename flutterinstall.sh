#!/bin/bash

# ==============================================================================
#  ULTIMATE FLUTTER & ANDROID SETUP SCRIPT (LINUX/CODESPACES)
#  - Installs Java 17, Flutter Stable, Android SDK (cmdline-tools)
#  - Configures Paths & Environment Variables
#  - Fixes Gradle Memory Issues for Low-RAM Environments
#  - Handles Network Retries and Idempotency
# ==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_internet() {
    log_info "Checking internet connectivity..."
    if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
        log_success "Internet is available."
    else
        log_warn "Google unreachable. Trying Cloudflare (1.1.1.1)..."
        if ping -q -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
            log_success "Internet is available."
        else
            log_error "No internet connection detected. Aborting."
        fi
    fi
}

ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

download_file() {
    local url=$1
    local dest=$2
    local retries=3
    local count=0

    while [ $count -lt $retries ]; do
        wget -q --show-progress "$url" -O "$dest"
        if [ $? -eq 0 ]; then
            return 0
        fi
        count=$((count + 1))
        log_warn "Download failed. Retrying ($count/$retries)..."
        sleep 2
    done
    log_error "Failed to download $url after $retries attempts."
}

# ------------------------------------------------------------------------------
# MAIN EXECUTION
# ------------------------------------------------------------------------------

log_info "Starting Ultimate Flutter Setup..."

# 1. CHECK INTERNET
check_internet

# 2. INSTALL SYSTEM DEPENDENCIES
log_info "Updating system and installing dependencies..."
# apt-get install might fail if locks are held, usually good to wait or retry,
# but for simplicity we assume sudo access works.
sudo pacman -Sy --noconfirm --needed curl git unzip xz zip glu jdk17-openjdk ninja || log_error "Failed to install system dependencies."

# Verify Java 17 Installation (Arch installs under /usr/lib/jvm/java-17-openjdk, no arch suffix)
JAVA_PATH=$(find /usr/lib/jvm -maxdepth 1 -iname 'java-17-openjdk*' -print -quit)
if [ -z "$JAVA_PATH" ] || [ ! -d "$JAVA_PATH" ]; then
    log_error "Java 17 directory not found under /usr/lib/jvm. Installation might have failed."
fi
log_success "Java 17 installed at $JAVA_PATH."

# 3. SETUP DIRECTORY VARIABLES
HOME_DIR="$HOME"
ANDROID_ROOT="$HOME_DIR/Android/Sdk"
FLUTTER_ROOT="$HOME_DIR/flutter"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# 4. INSTALL FLUTTER SDK
if [ -d "$FLUTTER_ROOT" ]; then
    log_info "Flutter directory exists. Pulling latest changes..."
    cd "$FLUTTER_ROOT" && git pull || log_warn "Failed to update Flutter. Continuing with existing version."
else
    log_info "Cloning Flutter stable branch..."
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_ROOT" || log_error "Failed to clone Flutter."
fi

# 5. INSTALL ANDROID COMMAND LINE TOOLS
ensure_dir "$ANDROID_ROOT/cmdline-tools"

if [ -d "$ANDROID_ROOT/cmdline-tools/latest" ]; then
    log_info "Android Command Line Tools already installed."
else
    log_info "Downloading Android Command Line Tools..."
    cd "$ANDROID_ROOT/cmdline-tools"
    download_file "$CMDLINE_TOOLS_URL" "tools.zip"
    
    log_info "Extracting tools..."
    unzip -q tools.zip
    # Fix directory structure requirement (cmdline-tools/latest/bin)
    if [ -d "cmdline-tools" ]; then
        mv cmdline-tools latest
    elif [ -d "tools" ]; then
        mv tools latest
    fi
    rm tools.zip
    log_success "Android Tools installed."
fi

# 6. CONFIGURE ENVIRONMENT VARIABLES (Session & Persistence)
log_info "Configuring environment variables..."

# Set vars for the rest of THIS script to use
export JAVA_HOME="$JAVA_PATH"
export ANDROID_HOME="$ANDROID_ROOT"
export PATH="$FLUTTER_ROOT/bin:$PATH:$ANDROID_ROOT/cmdline-tools/latest/bin:$ANDROID_ROOT/platform-tools"

# Update shell rc files idempotently (removes old lines, adds new ones)
for RC_FILE in "$HOME_DIR/.bashrc" "$HOME_DIR/.zshrc"; do
    [ -f "$RC_FILE" ] || continue
    sed -i '/# -- FLUTTER SETUP START --/,/# -- FLUTTER SETUP END --/d' "$RC_FILE"

    cat <<EOT >> "$RC_FILE"
# -- FLUTTER SETUP START --
export JAVA_HOME="$JAVA_PATH"
export ANDROID_HOME="$ANDROID_ROOT"
export PATH="\$PATH:$FLUTTER_ROOT/bin:$ANDROID_ROOT/cmdline-tools/latest/bin:$ANDROID_ROOT/platform-tools"
# -- FLUTTER SETUP END --
EOT
    log_success "Environment variables updated in $RC_FILE"
done

# 7. INSTALL ANDROID SDK PLATFORMS & TOOLS
log_info "Installing Android SDK components (Licenses will be accepted automatically)..."

# Check if sdkmanager is runnable
if ! command -v sdkmanager &> /dev/null; then
    log_error "sdkmanager not found in PATH. Setup failed."
fi

# Install specific versions needed for Flutter 3.38+
yes | sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "platforms;android-36" \
    "build-tools;34.0.0" \
    "build-tools;28.0.3" || log_error "Failed to install Android SDK components."

log_success "Android SDK components installed."

# 8. CONFIGURE FLUTTER
log_info "Configuring Flutter settings..."
flutter config --no-analytics
flutter config --android-sdk "$ANDROID_ROOT"
flutter config --jdk-dir "$JAVA_PATH"

log_info "Accepting Android Licenses..."
yes | flutter doctor --android-licenses || log_warn "License acceptance might have had issues, check doctor output."

# 9. APPLY GRADLE MEMORY FIX (CRITICAL FOR LOW RAM/CODESPACES)
log_info "Applying Global Gradle Memory Fixes..."
ensure_dir "$HOME_DIR/.gradle"

# Overwrite gradle.properties with optimized settings
cat <<EOT > "$HOME_DIR/.gradle/gradle.properties"
org.gradle.jvmargs=-Xmx1536M -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.daemon=false
org.gradle.parallel=false
EOT
log_success "Gradle memory limits applied (Max 1.5GB)."

# 10. FINAL VERIFICATION
echo "=================================================="
log_info "Running Flutter Doctor..."
flutter doctor -v

echo "=================================================="
log_success "SETUP COMPLETE!"
echo -e "${YELLOW}IMPORTANT:${NC} Run this command to refresh your current terminal:"
echo -e "    ${GREEN}source ~/.zshrc${NC}  (or ~/.bashrc if using bash)"
echo "=================================================="
