#!/bin/bash

set -euo pipefail

# ------------------------ Configuration ------------------------
CONDA_ENV_NAME="jupyterlab"
PYTHON_VERSION="3.12"
CONFIG_DIR="$HOME/.jupyterlab"
SYSTEMD_SERVICE_FILE="$HOME/.config/systemd/user/jupyterlab.service"
BASE_URL="https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main"
PORT_FILE="$CONFIG_DIR/jupyterlab_port.txt"
# ---------------------------------------------------------------

log() {
    echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
    echo "[ERROR] [$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
    exit 1
}

# ---------------------- Conda Activation -----------------------
activate_conda() {
    if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
        source /opt/conda/etc/profile.d/conda.sh
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        error_exit "Conda not found. Please install Anaconda or Miniconda."
    fi
}
activate_conda
# ---------------------------------------------------------------

log "Starting JupyterLab installation and user-level systemd setup..."

# ---------------------- Conda Environment ----------------------
if conda env list | grep -q "$CONDA_ENV_NAME"; then
    log "Conda environment '$CONDA_ENV_NAME' already exists."
else
    log "Creating conda environment '$CONDA_ENV_NAME' with Python $PYTHON_VERSION..."
    conda create -n "$CONDA_ENV_NAME" python="$PYTHON_VERSION" -y -q || error_exit "Environment creation failed."
    log "Environment created successfully."
fi

log "Activating conda environment '$CONDA_ENV_NAME'..."
conda activate "$CONDA_ENV_NAME"

log "Installing JupyterLab..."
python -m pip install --quiet jupyterlab || error_exit "Failed to install JupyterLab."
log "JupyterLab installed successfully."
# ---------------------------------------------------------------

# ------------------ Configuration Setup ------------------------
log "Creating configuration directory at '$CONFIG_DIR'..."
mkdir -p "$CONFIG_DIR"
rm -rf "$CONFIG_DIR"/*

log "Downloading JupyterLab configuration files..."
wget -q "$BASE_URL/jupyterlab/jupyterlab_config.py" -O "$CONFIG_DIR/jupyterlab_config.py"
wget -q "$BASE_URL/jupyterlab/start_jupyterlab.sh" -O "$CONFIG_DIR/start_jupyterlab.sh"

chmod +x "$CONFIG_DIR/start_jupyterlab.sh"

log "Configuration files downloaded and set up."
# ---------------------------------------------------------------

# ------------------ Systemd Service Setup ----------------------
log "Setting up systemd user service..."
mkdir -p "$(dirname "$SYSTEMD_SERVICE_FILE")"
wget -q "$BASE_URL/jupyterlab/jupyterlab.service" -O "$SYSTEMD_SERVICE_FILE"

systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable jupyterlab.service || error_exit "Failed to enable systemd service."
systemctl --user start jupyterlab.service || error_exit "Failed to start systemd service."
log "Systemd service started and enabled."
# ---------------------------------------------------------------

# ---------------------- Port Discovery -------------------------
log "Waiting for port file..."
while [ ! -f "$PORT_FILE" ]; do
    sleep 1
done

PORT=$(grep "PORT=" "$PORT_FILE" | cut -d'=' -f2)
log "JupyterLab is running at: port:$PORT"
# ---------------------------------------------------------------

# ----------------------- Final Info ----------------------------
cat <<EOF

JupyterLab is now installed and running as a user-level systemd service.

Useful commands:
  - Check status:     systemctl --user status jupyterlab.service
  - Restart service:  systemctl --user restart jupyterlab.service
  - Stop service:     systemctl --user stop jupyterlab.service
  - View logs:        journalctl --user -u jupyterlab -f | less

EOF
# ---------------------------------------------------------------
