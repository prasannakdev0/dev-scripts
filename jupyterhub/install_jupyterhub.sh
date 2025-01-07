#!/bin/bash

# Define variables
CONDA_ENV_NAME="jupyterhub"            # Name of the conda environment
PYTHON_VERSION="3.12"                  # Python version for the conda environment
CONFIG_DIR="$HOME/.jupyterhub"         # Directory for JupyterHub configuration files
# ------------------------------------------------------------------------------------------
# Log message
echo "Starting JupyterHub installation process..."

# Check if conda is installed
if ! command -v conda &>/dev/null; then
    echo "Conda is not installed. Please install Anaconda or Miniconda first."
    exit 1
else
    echo "Conda is already installed."
fi

# Create the conda environment if it doesn't exist
echo "Creating conda environment '$CONDA_ENV_NAME' with Python $PYTHON_VERSION..."
conda create -n $CONDA_ENV_NAME python=$PYTHON_VERSION -y
if [ $? -eq 0 ]; then
    echo "Conda environment '$CONDA_ENV_NAME' created successfully."
else
    echo "Failed to create conda environment '$CONDA_ENV_NAME'. Exiting..."
    exit 1
fi

# Activate the environment
echo "Activating the conda environment '$CONDA_ENV_NAME'..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $CONDA_ENV_NAME

# Use pip from the active conda environment to install JupyterHub and JupyterLab
echo "Installing JupyterHub and JupyterLab using pip from the conda environment..."
$CONDA_PREFIX/bin/pip install jupyterhub jupyterlab
if [ $? -eq 0 ]; then
    echo "JupyterHub and JupyterLab installed successfully."
else
    echo "Failed to install JupyterHub and JupyterLab. Exiting..."
    exit 1
fi
# ------------------------------------------------------------------------------------------
# Install Node.js and npm if they are not already installed
if ! command -v node &>/dev/null; then
    echo "Node.js is not installed. Installing Node.js and npm..."
    sudo apt-get update
    sudo apt-get install -y nodejs npm
    if [ $? -eq 0 ]; then
        echo "Node.js and npm installed successfully."
    else
        echo "Failed to install Node.js and npm. Exiting..."
        exit 1
    fi
else
    echo "Node.js is already installed."
fi

# Install configurable-http-proxy using npm
echo "Installing configurable-http-proxy using npm..."
npm install -g configurable-http-proxy
if [ $? -eq 0 ]; then
    echo "Configurable HTTP Proxy installed successfully."
else
    echo "Failed to install configurable HTTP Proxy. Exiting..."
    exit 1
fi
# ------------------------------------------------------------------------------------------
# Create the necessary directory for JupyterHub configuration
echo "Creating directory for JupyterHub configuration at $CONFIG_DIR..."
mkdir -p $CONFIG_DIR
if [ $? -eq 0 ]; then
    echo "Directory '$CONFIG_DIR' created successfully."
else
    echo "Failed to create directory '$CONFIG_DIR'. Exiting..."
    exit 1
fi

# Download configuration files
echo "Downloading JupyterHub configuration files..."
wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/jupyterhub_config.py -P $CONFIG_DIR
wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/start_jupyterhub.sh -P $CONFIG_DIR
chmod +x $CONFIG_DIR/start_jupyterhub.sh
if [ $? -eq 0 ]; then
    echo "Configuration files downloaded successfully."
else
    echo "Failed to download configuration files. Exiting..."
    exit 1
fi

# Prompt for admin_users and allowed_users
echo "Enter admin users (comma-separated):"
read ADMIN_USERS_INPUT
echo "Enter allowed users (comma-separated):"
read ALLOWED_USERS_INPUT

# Convert comma-separated input into Python set syntax
ADMIN_USERS_PYTHON_SET=$(echo $ADMIN_USERS_INPUT | sed "s/,/', '/g" | sed "s/^/{'/;s/$/'}/")
ALLOWED_USERS_PYTHON_SET=$(echo $ALLOWED_USERS_INPUT | sed "s/,/', '/g" | sed "s/^/{'/;s/$/'}/")

# Update the JupyterHub configuration file
echo "Updating JupyterHub configuration with admin and allowed users..."
cat <<EOL >> $CONFIG_DIR/jupyterhub_config.py
# Admin users
c.Authenticator.admin_users = $ADMIN_USERS_PYTHON_SET

# Allowed users
c.Authenticator.allowed_users = $ALLOWED_USERS_PYTHON_SET
EOL

if [ $? -eq 0 ]; then
    echo "Admin and allowed users added to JupyterHub configuration successfully."
else
    echo "Failed to update JupyterHub configuration. Exiting..."
    exit 1
fi
# ------------------------------------------------------------------------------------------
# Download systemd service file for JupyterHub (requires sudo)
echo "Downloading systemd service file for JupyterHub..."
if [ ! -f /etc/systemd/system/jupyterhub.service ]; then
    sudo wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/jupyterhub.service -O /etc/systemd/system/jupyterhub.service
    sudo systemctl daemon-reload
    sudo systemctl enable jupyterhub
    sudo systemctl start jupyterhub
    if [ $? -eq 0 ]; then
        echo "JupyterHub systemd service installed and started successfully."
    else
        echo "Failed to install or start JupyterHub systemd service. Exiting..."
        exit 1
    fi
else
    echo "JupyterHub service file already exists."
fi
# ------------------------------------------------------------------------------------------
# check JupyterHub service status
sudo systemctl status jupyterhub

# For service logs, use the following:
# journalctl -u jupyterhub -f

echo "JupyterHub installation and setup completed successfully."

# End of script
