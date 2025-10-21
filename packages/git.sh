#!/usr/bin/env bash
set -euo pipefail

# Install Git
paru -S git --needed --noconfirm

echo ""
echo "================================"
echo "=        Git Setup Script       ="
echo "================================"
echo ""

# --- Configure basic git settings ---
echo "→ Setting up global git configuration..."

# Default branch name
git config --global init.defaultBranch main

# Ask for username and email if not already set
if ! git config --global user.name >/dev/null; then
    read -rp "Enter your Git username: " GIT_NAME
    git config --global user.name "$GIT_NAME"
else
    echo "✓ Git username already set to: $(git config --global user.name)"
fi

if ! git config --global user.email >/dev/null; then
    read -rp "Enter your Git email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
else
    echo "✓ Git email already set to: $(git config --global user.email)"
fi

# Other useful defaults
git config --global core.editor "nano"
git config --global pull.rebase false
git config --global color.ui auto

echo ""
echo "✓ Basic Git configuration complete."

# --- Optional SSH key setup ---
echo ""
read -rp "Would you like to generate an SSH key for GitHub authentication? (y/N): " GEN_KEY

if [[ "$GEN_KEY" =~ ^[Yy]$ ]]; then
    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    DEFAULT_KEY="$SSH_DIR/id_ed25519"

    if [[ -f "$DEFAULT_KEY" ]]; then
        echo "⚠️  SSH key already exists at: $DEFAULT_KEY"
    else
        echo ""
        read -rp "Enter your GitHub email (for SSH key comment): " SSH_EMAIL
        ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$DEFAULT_KEY" -N ""
        echo ""
        echo "✅ SSH key generated successfully."
    fi

    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$DEFAULT_KEY"

    echo ""
    echo "→ Your SSH public key (add this to GitHub):"
    echo "------------------------------------------"
    cat "${DEFAULT_KEY}.pub"
    echo "------------------------------------------"
    echo "Path to your SSH private key: $DEFAULT_KEY"
    echo ""
    echo "You can view it anytime using:"
    echo "  cat ~/.ssh/id_ed25519.pub"
else
    echo "Skipping SSH key generation."
fi

echo ""
echo "✅ Git setup complete!"
