#!/bin/bash


# Check this is run by root
if [ 0 != $(id -u) ]; then 
	echo "this script must be run as root"; 
	exit 1; 
fi

# Get user for install if not given as argument
if [ "$1" = "" ]; then
	echo What is the name of the non-root user for installation?
	echo Parts of the install will be in his/her home directory
	echo and Jupyter will be usable by that user.
	read USERNAME
else
	USERNAME=$1
fi

if [ username = root ]; then
	HOMEDIR=/root
else
	HOMEDIR=/home/${USERNAME}
fi

# Variables: Feel free to change anything but CONDA_BIN.
# Directories
INSTALL_DIR=/opt
CONDA_DIR=${INSTALL_DIR}/conda
CONDA_BIN=${CONDA_DIR}/bin
H2O_DIR=${INSTALL_DIR}/h2o
JUPYTER_CFG_DIR=${HOMEDIR}/.jupyter
NOTEBOOKS_DIR=${CONDA_DIR}/notebooks
# Packages
APT_PKGS="openssl openjdk-8-jre python2.7-minimal python-pip unzip"
CONDA_PKGS_URL="https://raw.githubusercontent.com/stephenkrol/AWS/sparkmagic/cfg/anaconda.txt"
# Additional options
JUPYTER_PORT=8888
# Software
H2O_VERSION=3.20.0.3
CONDA=Anaconda3
CONDA_VERSION=5.2.0
CONDA_URL="https://repo.anaconda.com/archive"
# For Miniconda, uncomment these lines and delete the three lines above.
# You may also want to set your own CONDA_PKGS_URL file with a Miniconda packagelist.
#CONDA=Miniconda3
#CONDA_VERSION=latest
#CONDA_URL=https://repo.continuum.io/miniconda

apt update
apt upgrade -y
apt install -y $APT_PKGS

# Install Anaconda
wget -O ${INSTALL_DIR}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh ${CONDA_URL}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh
bash ${INSTALL_DIR}/${CONDA}-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh -b -p $CONDA_DIR

# Install additional Anaconda packages and Jupyter kernels
${CONDA_BIN}/conda update conda -y
${CONDA_BIN}/conda update --all -y
wget -O ${INSTALL_DIR}/anaconda.txt $CONDA_PKGS_URL
${CONDA_BIN}/conda install --file ${INSTALL_DIR}/anaconda.txt
${CONDA_BIN}/jupyter nbextension enable beakerx --py --sys-prefix
${CONDA_BIN}/jupyter nbextension enable jupyter_dashboards --py --sys-prefix
${CONDA_BIN}/jupyter nbextensions_configurator enable --user

# Add Python 2 kernel
python2 -m pip install --upgrade pip
python2 -m pip install ipykernel
python2 -m ipykernel install --user

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
# wget -O ${HOMEDIR}/.sparkmagic/config.json https://raw.githubusercontent.com/jupyter-incubator/sparkmagic/master/sparkmagic/example_config.json
# Uncomment to enable server extension so that clusters can be changed
# ${CONDA_BIN}/jupyter serverextension enable --py sparkmagic

# Set up Jupyter
mkdir $JUPYTER_CFG_DIR # if: doesnt exist, create
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${JUPYTER_CFG_DIR}/mykey.key" -out "${JUPYTER_CFG_DIR}/mycert.pem" -batch
wget -O ${JUPYTER_CFG_DIR}/jupyter_notebook_config.py https://raw.githubusercontent.com/stephenkrol/AWS/sparkmagic/cfg/jupyter_notebook_config.py
mkdir $NOTEBOOKS_DIR

# Fix permissions if not installing for root
if [ username = "root" ]; then
	chown -R ${USERNAME}:${USERNAME} $HOMEDIR
	chmod -R 755 $HOMEDIR # Installing with root breaks some permissions in ~/.local
	chown -R ${USERNAME}:${USERNAME} ${INSTALL_DIR}
	chmod -755 ${INSTALL_DIR}
fi