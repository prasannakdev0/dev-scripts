#!/bin/bash

set -euo pipefail

CONDA_DIRPATH="$HOME/miniconda3"
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_URL="https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER"
INSTALLER_PATH="$CONDA_DIRPATH/miniconda.sh"
CONDARC_PATH="$HOME/.condarc"

# Function: Log with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Check OS and architecture
OS_TYPE="$(uname -s)"
ARCH_TYPE="$(uname -m)"

# ----------------------------------------------------------------
if [[ "$OS_TYPE" != "Linux" ]]; then
    log "❌ This script supports only Linux. Detected OS: $OS_TYPE"
    exit 1
fi

if [[ "$ARCH_TYPE" != "x86_64" ]]; then
    log "❌ This script supports only x86_64 architecture. Detected: $ARCH_TYPE"
    exit 1
fi

# Check if conda is already installed
if command -v conda >/dev/null 2>&1; then
    log "✅ Conda is already installed at: $(which conda)"
    log "ℹ️ Skipping installation and configuration."
    exit 0
fi

# Check if the target directory already exists
if [[ -d "$CONDA_DIRPATH" ]]; then
    log "⚠️ Directory $CONDA_DIRPATH already exists. Aborting to avoid overwriting."
    exit 1
fi
# ----------------------------------------------------------------
# Create the install directory
mkdir -p "$CONDA_DIRPATH"

# Download Miniconda installer
log "📥 Downloading Miniconda installer..."
wget -q "$MINICONDA_URL" -O "$INSTALLER_PATH"

# Install Miniconda
log "📦 Installing Miniconda to $CONDA_DIRPATH..."
bash "$INSTALLER_PATH" -b -u -p "$CONDA_DIRPATH"

# Remove the installer
rm -f "$INSTALLER_PATH"
log "🧹 Installer removed."

# Initialize conda for bash
"$CONDA_DIRPATH/bin/conda" init bash
log "🔧 Conda initialized for bash."
# ----------------------------------------------------------------
# Write custom .condarc
log "📝 Writing custom .condarc to $CONDARC_PATH..."
cat > "$CONDARC_PATH" <<EOF
envs_dirs:
  - $CONDA_DIRPATH/envs
pkgs_dirs:
  - $CONDA_DIRPATH/pkgs
EOF
log "✅ .condarc created with custom envs_dirs and pkgs_dirs."

log "🎉 Conda installation complete. Restart your shell or run: source ~/.bashrc"
