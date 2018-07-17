#!/bin/bash

# Variables
# User

USER=ubuntu
# Directories
INSTALL_DIR=/opt
CONDA_DIR=${INSTALL_DIR}/conda
CONDA_BIN=${CONDA_DIR}/bin
H2O_DIR=${INSTALL_DIR}/h2o
JUPYTER_CFG_DIR=/home/${USER}/.jupyter
NOTEBOOKS_DIR=${CONDA_DIR}/notebooks
# Apt packages
APT_PKGS="openssl openjdk-8-jre python2.7-minimal python-pip unzip"
# Additional options
JUPYTER_PORT=8888
# Software
TINI_VERSION=v0.18.0
H2O_VERSION=3.20.0.3
CONDA=Anaconda3
CONDA_VERSION=5.2.0
CONDA_URL="https://repo.anaconda.com/archive"
# For Miniconda, uncomment these lines and delete the three lines above
#CONDA=Miniconda3
#CONDA_VERSION=latest
#CONDA_URL=https://repo.continuum.io/miniconda


sudo apt update
sudo apt upgrade -y
sudo apt install -y $APT_PKGS

# Install Anaconda3 to /opt/conda
sudo chown -R ${USER}:${USER} ${INSTALL_DIR}
sudo chmod -755 ${INSTALL_DIR}
wget -O ${INSTALL_DIR}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh ${CONDA_URL}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh 
bash ${INSTALL_DIR}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh -b -p $CONDA_DIR

# Install additional Anaconda packages and Jupyter kernels
${CONDA_BIN}/conda update conda -y
${CONDA_BIN}/conda update --all -y
wget -O ${INSTALL_DIR}/anaconda.txt https://raw.githubusercontent.com/stephenkrol/AWS/sparkmagic/cfg/anaconda.txt
${CONDA_BIN}/conda install --file ${INSTALL_DIR}/anaconda.txt
${CONDA_BIN}/jupyter nbextension enable beakerx --py --sys-prefix
${CONDA_BIN}/jupyter nbextension enable jupyter_dashboards --py --sys-prefix
${CONDA_BIN}/jupyter nbextensions_configurator enable --user

# Add Python 2 kernel
sudo -H python2 -m pip install --upgrade pip
sudo -H python2 -m pip install ipykernel
sudo python2 -m ipykernel install --user

# Add H2O jar
# To install R package, run the following in R:
# R CMD INSTALL -l ${H2O_DIR}/R/h2o_${H2O_VERSION}.tar.gz
wget -O ${INSTALL_DIR}/h2o-${H2O_VERSION}.zip http://h2o-release.s3.amazonaws.com/h2o/rel-wright/3/h2o-${H2O_VERSION}.zip
mkdir $H2O_DIR
unzip ${INSTALL_DIR}/h2o-${H2O_VERSION}.zip -d ${INSTALL_DIR}/
mv ${INSTALL_DIR}/h2o-${H2O_VERSION}/* $H2O_DIR
rm -rf ${INSTALL_DIR}/h2o-${H2O_VERSION}/

# Clean up Anaconda-related files and set permissions
${CONDA_BIN}/conda clean --all -y
rm ${INSTALL_DIR}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh 
rm ${INSTALL_DIR}/anaconda.txt
export PATH="/opt/conda/bin:$PATH" # change to add to bashrc
${CONDA_BIN}/jupyter nbextension disable _nb_ext_conf

# Enable Sparkmagic kernels
${CONDA_BIN}/jupyter nbextension enable --py --sys-prefix widgetsnbextension
# The following is a config file with a bunch of options. Uncomment to grab the example from GitHub
# wget -O /home/${USER}/.sparkmagic/config.json https://raw.githubusercontent.com/jupyter-incubator/sparkmagic/master/sparkmagic/example_config.json
# Uncomment to enable server extension so that clusters can be changed
# ${CONDA_BIN}/jupyter serverextension enable --py sparkmagic

# Set up Jupyter
mkdir $JUPYTER_CFG_DIR # if: doesnt exist, create
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${JUPYTER_CFG_DIR}/mykey.key" -out "${JUPYTER_CFG_DIR}/mycert.pem" -batch
wget -O ${JUPYTER_CFG_DIR}/jupyter_notebook_config.py https://raw.githubusercontent.com/stephenkrol/AWS/sparkmagic/cfg/jupyter_notebook_config.py
mkdir $NOTEBOOKS_DIR 
sudo chown -R ${USER}:${USER} /home/${USER}
sudo chmod -R 755 /home/${USER} # Installing with root breaks some permissions in .local