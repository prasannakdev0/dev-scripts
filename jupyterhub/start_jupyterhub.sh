#!/bin/bash
source /opt/conda/bin/activate jupyterhub
exec jupyterhub -f /root/.jupyterhub/jupyterhub_config.py