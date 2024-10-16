#!/bin/bash

conda_dirpath="$HOME/miniconda3"
# Download and install Miniconda
mkdir -p $conda_dirpath
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $conda_dirpath/miniconda.sh
bash $conda_dirpath/miniconda.sh -b -u -p $conda_dirpath
rm -rf $conda_dirpath/miniconda.sh

# Initialize conda for bash
$conda_dirpath/bin/conda init bash
