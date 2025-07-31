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
# ------------------------ Start JupyterLab ------------------------
CONFIG_DIR="$HOME/.jupyterlab"
exec jupyter lab --config "$CONFIG_DIR/jupyterlab_config.py"
