#!/bin/bash --login

# Define variables
CONDA_ENV_NAME="jupyterlab"            # Name of the conda environment
PYTHON_VERSION="3.12"                  # Python version for the conda environment
CONFIG_DIR="$HOME/.jupyterlab"            # Directory for Jupyter configuration files
SYSTEMD_SERVICE_FILE="$HOME/.config/systemd/user/jupyterlab.service" # Systemd service file
# Temporarily set the CONDA_ENVS_PATH for this script only so condarc is ignored
CONDA_ENVS_PATH=/opt/conda/envs
BASE_URL="https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main"
# ------------------------------------------------------------------------------------------
# Set a password for JupyterLab
echo "Do you want to set a password for JupyterLab? (y/n)"
read SET_PASSWORD

source /opt/conda/etc/profile.d/conda.sh

# Log message
echo "Starting JupyterLab installation and user-level systemd setup..."

# Check if conda is installed
if ! command -v conda &>/dev/null; then
    echo "Conda is not installed. Please install Anaconda or Miniconda first."
    exit 1
else
    echo "Conda is already installed."
fi

# Check if the conda environment already exists
echo "Checking if conda environment '$CONDA_ENV_NAME' exists..."

if conda env list | grep "$CONDA_ENV_NAME"; then
    echo "Conda environment '$CONDA_ENV_NAME' already exists."
else
    echo "Creating conda environment '$CONDA_ENV_NAME' with Python $PYTHON_VERSION..."
    conda create -n $CONDA_ENV_NAME python=$PYTHON_VERSION -y --quiet
    if [ $? -eq 0 ]; then
        echo "Conda environment '$CONDA_ENV_NAME' created successfully."
    else
        echo "Failed to create conda environment '$CONDA_ENV_NAME'. Exiting..."
        exit 1
    fi
fi

# Activate the environment
echo "Activating the conda environment '$CONDA_ENV_NAME'..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $CONDA_ENV_NAME

# Use pip from the active conda environment to install JupyterLab
echo "Installing JupyterLab using pip from the conda environment..."
$CONDA_PREFIX/bin/pip install jupyterlab
if [ $? -eq 0 ]; then
    echo "JupyterLab installed successfully."
else
    echo "Failed to install JupyterLab. Exiting..."
    exit 1
fi

# ------------------------------------------------------------------------------------------
if [ "$SET_PASSWORD" == "y" ]; then
    echo "Setting a password for JupyterLab..."
    jupyter server password
    if [ $? -eq 0 ]; then
        echo "Password set successfully."
    else
        echo "Failed to set password. Exiting..."
        exit 1
    fi
else
    echo "Skipping password setup."
fi
# ------------------------------------------------------------------------------------------
# Create the necessary directory for Jupyter configuration
echo "Creating configuration directory at $CONFIG_DIR..."
mkdir -p $CONFIG_DIR

# Download configuration files
echo "Downloading JupyterHub configuration files..."
wget -q $BASE_URL/jupyterlab/jupyterlab_config.py -P $CONFIG_DIR
wget -q $BASE_URL/jupyterlab/start_jupyterlab.sh -P $CONFIG_DIR
chmod +x $CONFIG_DIR/start_jupyterlab.sh

if [ $? -eq 0 ]; then
    echo "Configuration files downloaded successfully."
else
    echo "Failed to download configuration files. Exiting..."
    exit 1
fi
# ------------------------------------------------------------------------------------------
# Create a systemd service for JupyterLab
echo "Setting up user-level systemd service for JupyterLab..."

# Ensure the user-level systemd directory exists
mkdir -p $(dirname "$SYSTEMD_SERVICE_FILE")
wget -q $BASE_URL/jupyterlab/jupyterlab.service -O $SYSTEMD_SERVICE_FILE

# Reload systemd and enable the service
echo "Reloading systemd and enabling the JupyterLab service..."
systemctl --user daemon-reload
systemctl --user enable jupyterlab.service
if [ $? -eq 0 ]; then
    echo "JupyterLab service enabled successfully."
else
    echo "Failed to enable JupyterLab service. Exiting..."
    exit 1
fi

# Start the service
echo "Starting JupyterLab systemd service..."
systemctl --user start jupyterlab.service
if [ $? -eq 0 ]; then
    echo "JupyterLab service started successfully."
else
    echo "Failed to start JupyterLab service. Exiting..."
    exit 1
fi

# ------------------------------------------------------------------------------------------
# Print helpful information
echo "JupyterLab is now installed and running as a user-level systemd service."
echo "To check the status of the service, use:"
echo "    systemctl --user status jupyterlab.service"
echo "To restart the service, use:"
echo "    systemctl --user restart jupyterlab.service"
echo "To view logs, use:"
echo "    journalctl --user -u jupyterlab -f"
# ------------------------------------------------------------------------------------------
