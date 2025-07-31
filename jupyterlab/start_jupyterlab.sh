#!/bin/bash
set -euo pipefail

# ------------------------ Conda Activation ------------------------
if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
    source /opt/conda/etc/profile.d/conda.sh
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    echo "[ERROR] Could not find conda.sh to initialize Conda environment." >&2
    exit 1
fi

# Activate the jupyterlab environment
conda activate jupyterlab

# ------------------------ Port Export ------------------------
PORT=8888
CONFIG_DIR="$HOME/.jupyterlab"
PORT_FILE="$CONFIG_DIR/jupyterlab_port.txt"
mkdir -p "$CONFIG_DIR"
echo "PORT=$PORT" > "$PORT_FILE"

# ------------------------ Start JupyterLab ------------------------
exec jupyter lab --config "$CONFIG_DIR/jupyterlab_config.py" --port="$PORT" --no-browser
