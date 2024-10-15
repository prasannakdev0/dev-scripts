#!/bin/bash
source /opt/conda/bin/activate jupyterhub
exec jupyterhub -f ~/.jupyterhub/jupyterhub_config.py