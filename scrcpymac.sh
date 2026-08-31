#!/bin/bash

echo "Starting Scrcpy setup for non-admin macOS user..."

# Define local Homebrew path inside your user folder
BREW_DIR="$HOME/homebrew"

# 1. Install Homebrew locally if it doesn't exist
if [ ! -d "$BREW_DIR" ]; then
    echo "Installing Homebrew locally in $BREW_DIR without sudo..."
    mkdir -p "$BREW_DIR"
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_DIR"
else
    echo "Local Homebrew already found in $BREW_DIR."
fi

# 2. Add local Homebrew to PATH for the current session
eval "$($BREW_DIR/bin/brew shellenv)"

# Add it to your .zshrc so it works in future terminal windows
if ! grep -q "$BREW_DIR/bin/brew shellenv" ~/.zshrc; then
    echo 'eval "$('"$BREW_DIR"'/bin/brew shellenv)"' >> ~/.zshrc
fi

echo "Updating local Homebrew..."
brew update

# 3. Install scrcpy and android-platform-tools
echo "Installing scrcpy and ADB (This might take a while if it needs to compile dependencies)..."
brew install scrcpy android-platform-tools

echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo "Next steps:"
echo "1. Enable 'USB Debugging' in your Android phone's Developer Options."
echo "2. Plug the phone into your Mac."
echo "3. Type 'scrcpy' in your terminal and press Return."
