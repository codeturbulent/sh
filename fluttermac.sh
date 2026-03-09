#!/bin/bash

set -e

echo "🚀 Flutter iOS + Android Stable Setup for macOS"

# -----------------------------
# Homebrew
# -----------------------------
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed"
fi

brew update

# -----------------------------
# Flutter
# -----------------------------
if ! command -v flutter &> /dev/null; then
  echo "💙 Installing Flutter..."
  brew install --cask flutter
else
  echo "✅ Flutter already installed"
fi

FLUTTER_PATH="/opt/homebrew/Caskroom/flutter/latest/flutter/bin"
if ! grep -q "$FLUTTER_PATH" ~/.zshrc; then
  echo "export PATH=\"\$PATH:$FLUTTER_PATH\"" >> ~/.zshrc
fi

source ~/.zshrc

# -----------------------------
# Android Setup
# -----------------------------
echo "🤖 Installing Android Studio + platform tools..."
brew install --cask android-studio
brew install android-platform-tools

ANDROID_SDK="$HOME/Library/Android/sdk"

if ! grep -q "ANDROID_HOME" ~/.zshrc; then
  echo "export ANDROID_HOME=$ANDROID_SDK" >> ~/.zshrc
  echo 'export PATH="$PATH:$ANDROID_HOME/emulator"' >> ~/.zshrc
  echo 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' >> ~/.zshrc
fi

source ~/.zshrc

# Accept Android licenses
yes | flutter doctor --android-licenses || true

# -----------------------------
# Xcode Command Line Tools
# -----------------------------
echo "🍎 Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
  xcode-select --install || true
fi

# -----------------------------
# CocoaPods (stable way, no sudo gem mess)
# -----------------------------
echo "📦 Installing CocoaPods using Homebrew..."
brew install cocoapods || brew upgrade cocoapods

pod setup

# -----------------------------
# iOS Permissions
# -----------------------------
echo "🔐 Accepting Xcode license..."
sudo xcodebuild -license accept || true

sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer || true

# -----------------------------
# Final Doctor Check
# -----------------------------
echo "🧪 Running flutter doctor..."
flutter doctor

echo ""
echo "✅ Script finished."
echo "⚠️ IMPORTANT MANUAL STEP:"
echo "1. Open App Store"
echo "2. Install Xcode (if not installed)"
echo "3. Open Xcode once and let it finish setup"
echo "4. Run: flutter doctor"
echo ""
echo "After that, iOS will work cleanly."

