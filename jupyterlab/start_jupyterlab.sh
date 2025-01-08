#!/bin/bash
# Activate the conda environment for JupyterLab
source /opt/conda/bin/activate 
conda activate jupyterlab

# Start JupyterLab
exec jupyter lab --config ~/.jupyterlab/jupyterlab_config.py
